# URLMock

URLMock is an Objective-C framework for mocking and stubbing URL requests and
responses. It works with APIs built on the Foundation NSURL loading
system—NSURLConnection and AFNetworking, for example—without any changes to
your code.


## Features

* Simple, well-documented Objective-C API
* Minimal setup necessary
* Works with APIs built atop the Foundation NSURL loading system
* Designed with both response stubbing and unit testing in mind
* Can be used for some or all of your project’s URL requests
* Well-tested and includes lots of helpful testing utilities
* Works on both Mac OS X and iOS


## What’s New in URLMock 1.1.2

URLMock 1.1.2 is a minor bug fix update. URLMock 1.1 introduced the following
new functionality:

* Better unexpected request detection when verification is enabled
* Better request/response description methods to aid in debugging failures
* New convenience methods for adding mock HTTP requests and responses with 
  JSON bodies.
* New test utility functions for generating arrays, dictionaries, and sets with
  blocks. These are great for randomly generating data for use in unit tests.
  These and other test utilities are available in the `TestHelpers` Pod subspec.
* New `SubclassResponsibilty` Pod subspec for easily throwing NSException
  instances when a subclass failed to override an abstract method. 


## Known Issues and Limitations

* URLMock does not support stream-based requests, which means that it is
  currently incompatible with NSURLSession. We are tracking this as a [GitHub 
  issue][Issue-StreamBasedRequests] and hope to have it fixed soon. In the 
  meantime, both NSURLConnection and AFNetworking 2.0 work.
* URLMock can’t currently match requests and generate responses based on a
  pattern or block. We plan to add a mechanism for doing this in the near
  future. ([GitHub issue][Issue-PatternBasedRequests])

[Issue-StreamBasedRequests]: https://github.com/twotoasters/URLMock/issues/3
[Issue-PatternBasedRequests]: https://github.com/twotoasters/URLMock/issues/4


## Installation

The easiest way to start using URLMock is to install it with CocoaPods. 

    pod 'URLMock', '~> 1.1.1'

You can also build it and include the built products in your project. For OS X,
just add URLMock.framework to your project. For iOS, add URLMock’s public
headers to your header search path and link in libURLMock.a.


## Using URLMock

URLMock is designed with both response stubbing and unit testing in mind. Both
work very similarly.

### Response stubbing

Using URLMock for response stubbing is simple:

1. Enable URLMock.

        [UMKMockURLProtocol enable];

2. Add an expected mock request and response.

        // The request is a POST with some JSON data
        NSURL *URL = [NSURL URLWithString:@"http://host.com/api/v1/person"];
        id requestJSON = @{ @"person" : @{ @"name" : @"John Doe", 
                                           @"age" : @47 } };
        id responseJSON = @{ @"person" : @{ @"id" : @1, 
                                            @"name" : @"John Doe", 
                                            @"age" : @47 } };

        [UMKMockURLProtocol expectMockHTTPPostRequestWithURL:URL 
                                                 requestJSON:requestJSON
                                          responseStatusCode:200
                                                responseJSON:responseJSON];
   
   Mock requests and responses are not limited to having JSON bodies; they can 
   also have bodies with strings, WWW form-encoded parameter dictionaries, or
   arbitrary NSData instances. There are also mock responders for responding
   with an error or returning data in chunks with a delay between each chunk,
   and we’ll be adding more responders in the future.

3. Execute your real request to get the stubbed response back. You don’t have to 
   make any changes to your code when using URLMock. Things should just work. 
   For example, the following URLConnection code will receive the mock response 
   above:
   
        NSURL *URL = [NSURL URLWithString:@"http://host.com/api/v1/person"];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
        request.HTTPMethod = @"POST";
        id bodyJSON = @{ @"person" : @{ @"name" : @"John Doe", @"age" : @47 } };
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:bodyJSON
                                                           options:0 
                                                             error:NULL];
        
        // Create the connection as usual
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:…];
   
   
   The following AFNetworking code would accomplish the same thing:
   
        NSURL *base = [NSURL URLWithString:@"http://host.com/api/v1/"];
        id params = @{ @"person" : @{ @"name" : @"John Doe", @"age" : @47 } };

        // Send a POST as usual
        AFHTTPRequestOperationManager *om = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:base];
        om.requestSerializer = [AFJSONRequestSerializer serializer];
        [om POST:@"person" parameters:params success:^(AFHTTPRequestOperation *op, id object) {
            …
        } failure:^(AFHTTPRequestOperation *op, NSError *error) {
            …
        }];    

        
### Unit testing

Unit testing with URLMock is very similar to response stubbing, but you can use 
a few additional APIs to make unit testing easier.

1. Enable verification in UMKMockURLProtocol using `+setVerificationEnabled:`. 
   This enables tracking whether any unexpected requests were received. It makes
   sense to do this in your XCTestCase’s `+setUp` method. You can also disable 
   verification in your `+tearDown` method.
   
        + (void)setUp
        {
            [super setUp];
            [UMKMockURLProtocol enable];
            [UMKMockURLProtocol setVerificationEnabled:YES];
        }
        
        + (void)tearDown
        {
            [UMKMockURLProtocol setVerificationEnabled:NO];
            [UMKMockURLProtocol disable];
            [super tearDown];
        }
   
2. Before (or after) each test, invoke `+[UMKMockURLProtocol reset]`. This 
   resets UMKMockURLProtocol’s expectations to their original state. It does not
   change whether verification is enabled. 
   
   If you’re using XCTest, the ideal place to do this is in your test case’s
   `-setUp` (or `-tearDown`) method.
   
        - (void)setUp
        {
           [super setUp];
           [UMKMockURLProtocol reset];
        }


3. After you’ve executed the code you’re testing, send UMKMockURLProtocol the 
   `+verifyWithError:` message. It will return YES if all expected mock requests
   were serviced and no unexpected mock requests were received.

        NSError *error = nil;
        XCTAssertTrue([UMKMockURLProtocol verifyWithError:&error], @"…");

4. For the strictest testing, enable header checking on your UMKMockHTTPRequest 
   instances. When enabled, mock requests only match URL requests that have
   equivalent headers. You can enable header checking on mock HTTP request by
   setting its `checksHeadersWhenMatching` to YES or by using
   `initWithHTTPMethod:URL:checksHeadersWhenMatching:`.
   
        UMKMockHTTPRequest *request = [UMKMockHTTPRequest mockHTTPGetRequestWithURL:URL];
        request.checksHeadersWhenMatching = YES;
   
   Note that some networking APIs—most notably AFNetworking—send headers that
   you didn’t explicitly set, so you should determine what those are before
   creating your mock requests. To make things a little easier, you can use
   `+[UMKMockHTTPRequest setDefaultHeaders:]` to set the default headers for new
   UMKMockHTTPRequest instances. For example, if you’re using AFNetworking’s 
   default HTTP request serializer, you can set default headers this way:
   
        [UMKMockHTTPRequest setDefaultHeaders:[[AFHTTPRequestSerializer serializer] HTTPRequestHeaders]];


### Non-HTTP Protocols

Out of the box, URLMock only supports HTTP and HTTPS. However, it is designed to 
work with any URL protocol that the NSURL loading system can support. If you are 
using a custom scheme or URL protocol and would like to add support for mocking 
requests and responses, you need only create classes that conform to the 
UMKMockURLRequest and UMKMockURLResponder protocols. See the implementations of
UMKMockHTTPRequest and UMKMockHTTPResponder for examples.


## Contributing, Filing Bugs, and Requesting Enhancements

URLMock is very usable in its current state, but there’s still a lot that could
be done. If you would like to help fix bugs or add features, send us a pull 
request!

We use GitHub issues for bugs, enhancement requests, and the limited support we
provide, so open an issue for any of those.

 
## License

All code is licensed under the MIT license. Do with it as you will.
