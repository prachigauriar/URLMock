//
//  UMKMockURLProtocolHTTPConvenienceMethodsTests.m
//  URLMock
//
//  Created by Prachi Gauriar on 2/1/2014.
//  Copyright (c) 2015 Ticketmaster Entertainment, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "UMKIntegrationTestCase.h"

#import "UMKURLConnectionVerifier.h"


@interface UMKMockURLProtocolHTTPConvenienceMethodsTests : UMKIntegrationTestCase

- (void)testExpectMockHTTPRequestWithMethodURLRequestJSONError;
- (void)testExpectMockHTTPGetRequestWithURLError;
- (void)testExpectMockHTTPPatchRequestWithURLRequestJSONError;
- (void)testExpectMockHTTPPostRequestWithURLRequestJSONError;
- (void)testExpectMockHTTPPutRequestWithURLRequestJSONError;

- (void)testExpectMockHTTPRequestWithMethodURLRequestJSONResponseStatusCodeResponseJSON;
- (void)testExpectMockHTTPGetRequestWithURLResponseStatusCodeResponseJSON;
- (void)testExpectMockHTTPPatchRequestWithURLRequestJSONResponseStatusCodeResponseJSON;

@end


@implementation UMKMockURLProtocolHTTPConvenienceMethodsTests

- (void)testExpectMockHTTPRequestWithMethodURLRequestJSONError
{
    for (NSString *method in @[ @"DELETE", @"GET", @"HEAD", @"PATCH", @"POST", @"PUT" ]) {
        NSURL *URL = UMKRandomHTTPURL();
        id requestJSON = UMKRandomJSONObject(3, 3);
        NSError *error = UMKRandomError();
        
        UMKMockHTTPRequest *mockRequest = [UMKMockURLProtocol expectMockHTTPRequestWithMethod:method URL:URL requestJSON:requestJSON responseError:error];
        XCTAssertNotNil(mockRequest, @"Returned nil");
        XCTAssertEqualObjects(mockRequest.HTTPMethod, method, @"Incorrect HTTP method");
        XCTAssertEqualObjects(mockRequest.URL, URL, @"Incorrect URL");
        XCTAssertEqualObjects([mockRequest JSONObjectFromBody] , requestJSON, @"Incorrect JSON body");
    
        XCTAssertEqualObjects([UMKMockURLProtocol expectedMockRequests], @[ mockRequest ], @"Expectation is not added");
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
        request.HTTPMethod = method;
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestJSON options:0 error:NULL];
        
        id verifier = [self verifierForConnectionWithURLRequest:request];
        XCTAssertTrue([verifier waitForCompletionWithTimeout:1.0], @"Request did not complete in time");
        
        XCTAssertEqualObjects([[verifier error] domain], error.domain, @"Error domain not set correctly");
        XCTAssertEqual([[verifier error] code], error.code, @"Error code not set correctly");
        
        [UMKMockURLProtocol reset];
    }
}


- (void)testExpectMockHTTPGetRequestWithURLError
{
    NSURL *URL = UMKRandomHTTPURL();
    NSError *error = UMKRandomError();
    
    UMKMockHTTPRequest *mockRequest = [UMKMockURLProtocol expectMockHTTPGetRequestWithURL:URL responseError:error];
    XCTAssertNotNil(mockRequest, @"Returned nil");
    XCTAssertEqualObjects(mockRequest.HTTPMethod, kUMKMockHTTPRequestGetMethod, @"Incorrect HTTP method");
    XCTAssertEqualObjects(mockRequest.URL, URL, @"Incorrect URL");
    XCTAssertNil(mockRequest.body, @"Incorrect body");
    
    XCTAssertEqualObjects([UMKMockURLProtocol expectedMockRequests], @[ mockRequest ], @"Expectation is not added");

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:URL];
    
    id verifier = [self verifierForConnectionWithURLRequest:request];
    XCTAssertTrue([verifier waitForCompletionWithTimeout:1.0], @"Request did not complete in time");

    XCTAssertEqualObjects([[verifier error] domain], error.domain, @"Error domain not set correctly");
    XCTAssertEqual([[verifier error] code], error.code, @"Error code not set correctly");
}


- (void)testExpectMockHTTPPatchRequestWithURLRequestJSONError
{
    NSURL *URL = UMKRandomHTTPURL();
    id requestJSON = UMKRandomJSONObject(3, 3);
    NSError *error = UMKRandomError();
    
    UMKMockHTTPRequest *mockRequest = [UMKMockURLProtocol expectMockHTTPPatchRequestWithURL:URL requestJSON:requestJSON responseError:error];
    XCTAssertNotNil(mockRequest, @"Returned nil");
    XCTAssertEqualObjects(mockRequest.HTTPMethod, kUMKMockHTTPRequestPatchMethod, @"Incorrect HTTP method");
    XCTAssertEqualObjects(mockRequest.URL, URL, @"Incorrect URL");
    XCTAssertEqualObjects([mockRequest JSONObjectFromBody] , requestJSON, @"Incorrect JSON body");
    
    XCTAssertEqualObjects([UMKMockURLProtocol expectedMockRequests], @[ mockRequest ], @"Expectation is not added");

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    request.HTTPMethod = kUMKMockHTTPRequestPatchMethod;
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestJSON options:0 error:NULL];
    
    id verifier = [self verifierForConnectionWithURLRequest:request];
    XCTAssertTrue([verifier waitForCompletionWithTimeout:1.0], @"Request did not complete in time");
    
    XCTAssertEqualObjects([[verifier error] domain], error.domain, @"Error domain not set correctly");
    XCTAssertEqual([[verifier error] code], error.code, @"Error code not set correctly");
}


- (void)testExpectMockHTTPPostRequestWithURLRequestJSONError
{
    NSURL *URL = UMKRandomHTTPURL();
    id requestJSON = UMKRandomJSONObject(3, 3);
    NSError *error = UMKRandomError();
    
    UMKMockHTTPRequest *mockRequest = [UMKMockURLProtocol expectMockHTTPPostRequestWithURL:URL requestJSON:requestJSON responseError:error];
    XCTAssertNotNil(mockRequest, @"Returned nil");
    XCTAssertEqualObjects(mockRequest.HTTPMethod, kUMKMockHTTPRequestPostMethod, @"Incorrect HTTP method");
    XCTAssertEqualObjects(mockRequest.URL, URL, @"Incorrect URL");
    XCTAssertEqualObjects([mockRequest JSONObjectFromBody] , requestJSON, @"Incorrect JSON body");
    
    XCTAssertEqualObjects([UMKMockURLProtocol expectedMockRequests], @[ mockRequest ], @"Expectation is not added");
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    request.HTTPMethod = kUMKMockHTTPRequestPostMethod;
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestJSON options:0 error:NULL];
    
    id verifier = [self verifierForConnectionWithURLRequest:request];
    XCTAssertTrue([verifier waitForCompletionWithTimeout:1.0], @"Request did not complete in time");
    
    XCTAssertEqualObjects([[verifier error] domain], error.domain, @"Error domain not set correctly");
    XCTAssertEqual([[verifier error] code], error.code, @"Error code not set correctly");
}


- (void)testExpectMockHTTPPutRequestWithURLRequestJSONError
{
    NSURL *URL = UMKRandomHTTPURL();
    id requestJSON = UMKRandomJSONObject(3, 3);
    NSError *error = UMKRandomError();
    
    UMKMockHTTPRequest *mockRequest = [UMKMockURLProtocol expectMockHTTPPutRequestWithURL:URL requestJSON:requestJSON responseError:error];
    XCTAssertNotNil(mockRequest, @"Returned nil");
    XCTAssertEqualObjects(mockRequest.HTTPMethod, kUMKMockHTTPRequestPutMethod, @"Incorrect HTTP method");
    XCTAssertEqualObjects(mockRequest.URL, URL, @"Incorrect URL");
    XCTAssertEqualObjects([mockRequest JSONObjectFromBody] , requestJSON, @"Incorrect JSON body");
    
    XCTAssertEqualObjects([UMKMockURLProtocol expectedMockRequests], @[ mockRequest ], @"Expectation is not added");
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    request.HTTPMethod = kUMKMockHTTPRequestPutMethod;
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestJSON options:0 error:NULL];
    
    id verifier = [self verifierForConnectionWithURLRequest:request];
    XCTAssertTrue([verifier waitForCompletionWithTimeout:1.0], @"Request did not complete in time");
    
    XCTAssertEqualObjects([[verifier error] domain], error.domain, @"Error domain not set correctly");
    XCTAssertEqual([[verifier error] code], error.code, @"Error code not set correctly");
}


- (void)testExpectMockHTTPRequestWithMethodURLRequestJSONResponseStatusCodeResponseJSON
{
    for (NSString *method in @[ @"DELETE", @"GET", @"HEAD", @"PATCH", @"POST", @"PUT" ]) {
        NSURL *URL = UMKRandomHTTPURL();
        id requestJSON = UMKRandomJSONObject(3, 3);
        NSInteger statusCode = random() % 400 + 100;
        id responseJSON = UMKRandomJSONObject(3, 3);
        
        UMKMockHTTPRequest *mockRequest = [UMKMockURLProtocol expectMockHTTPRequestWithMethod:method URL:URL requestJSON:requestJSON
                                                                           responseStatusCode:statusCode responseJSON:responseJSON];
        XCTAssertNotNil(mockRequest, @"Returned nil");
        XCTAssertEqualObjects(mockRequest.HTTPMethod, method, @"Incorrect HTTP method");
        XCTAssertEqualObjects(mockRequest.URL, URL, @"Incorrect URL");
        XCTAssertEqualObjects([mockRequest JSONObjectFromBody], requestJSON, @"Incorrect JSON body");
        
        XCTAssertEqualObjects([UMKMockURLProtocol expectedMockRequests], @[ mockRequest ], @"Expectation is not added");

        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
        request.HTTPMethod = method;
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestJSON options:0 error:NULL];
        
        id verifier = [self verifierForConnectionWithURLRequest:request];
        XCTAssertTrue([verifier waitForCompletionWithTimeout:1.0], @"Request did not complete in time");
    
        XCTAssertEqual([(NSHTTPURLResponse *)[verifier response] statusCode], statusCode, @"Received wrong status code");

        id actualResponseJSON = [NSJSONSerialization JSONObjectWithData:[verifier body] options:0 error:NULL];
        XCTAssertEqualObjects(actualResponseJSON, responseJSON, @"Received wrong body");
        
        [UMKMockURLProtocol reset];
    }
}


- (void)testExpectMockHTTPGetRequestWithURLResponseStatusCodeResponseJSON
{
    NSURL *URL = UMKRandomHTTPURL();
    NSInteger statusCode = random() % 400 + 100;
    id responseJSON = UMKRandomJSONObject(3, 3);
    
    UMKMockHTTPRequest *mockRequest = [UMKMockURLProtocol expectMockHTTPGetRequestWithURL:URL responseStatusCode:statusCode responseJSON:responseJSON];
    XCTAssertNotNil(mockRequest, @"Returned nil");
    XCTAssertEqualObjects(mockRequest.HTTPMethod, kUMKMockHTTPRequestGetMethod, @"Incorrect HTTP method");
    XCTAssertEqualObjects(mockRequest.URL, URL, @"Incorrect URL");
    XCTAssertNil(mockRequest.body, @"Incorrect body");
    
    XCTAssertEqualObjects([UMKMockURLProtocol expectedMockRequests], @[ mockRequest ], @"Expectation is not added");
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:URL];
    
    id verifier = [self verifierForConnectionWithURLRequest:request];
    XCTAssertTrue([verifier waitForCompletionWithTimeout:1.0], @"Request did not complete in time");
    
    XCTAssertEqual([(NSHTTPURLResponse *)[verifier response] statusCode], statusCode, @"Received wrong status code");
    
    id actualResponseJSON = [NSJSONSerialization JSONObjectWithData:[verifier body] options:0 error:NULL];
    XCTAssertEqualObjects(actualResponseJSON, responseJSON, @"Received wrong body");
}


- (void)testExpectMockHTTPPatchRequestWithURLRequestJSONResponseStatusCodeResponseJSON
{
    NSURL *URL = UMKRandomHTTPURL();
    id requestJSON = UMKRandomJSONObject(3, 3);
    NSInteger statusCode = random() % 400 + 100;
    id responseJSON = UMKRandomJSONObject(3, 3);
    
    UMKMockHTTPRequest *mockRequest = [UMKMockURLProtocol expectMockHTTPPatchRequestWithURL:URL requestJSON:requestJSON
                                                                         responseStatusCode:statusCode responseJSON:responseJSON];
    XCTAssertNotNil(mockRequest, @"Returned nil");
    XCTAssertEqualObjects(mockRequest.HTTPMethod, kUMKMockHTTPRequestPatchMethod, @"Incorrect HTTP method");
    XCTAssertEqualObjects(mockRequest.URL, URL, @"Incorrect URL");
    XCTAssertEqualObjects([mockRequest JSONObjectFromBody], requestJSON, @"Incorrect JSON body");
    
    XCTAssertEqualObjects([UMKMockURLProtocol expectedMockRequests], @[ mockRequest ], @"Expectation is not added");
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    request.HTTPMethod = kUMKMockHTTPRequestPatchMethod;
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestJSON options:0 error:NULL];
    
    id verifier = [self verifierForConnectionWithURLRequest:request];
    XCTAssertTrue([verifier waitForCompletionWithTimeout:1.0], @"Request did not complete in time");
    
    XCTAssertEqual([(NSHTTPURLResponse *)[verifier response] statusCode], statusCode, @"Received wrong status code");
    
    id actualResponseJSON = [NSJSONSerialization JSONObjectWithData:[verifier body] options:0 error:NULL];
    XCTAssertEqualObjects(actualResponseJSON, responseJSON, @"Received wrong body");
}


- (void)testExpectMockHTTPPostRequestWithURLRequestJSONResponseStatusCodeResponseJSON
{
    NSURL *URL = UMKRandomHTTPURL();
    id requestJSON = UMKRandomJSONObject(3, 3);
    NSInteger statusCode = random() % 400 + 100;
    id responseJSON = UMKRandomJSONObject(3, 3);
    
    UMKMockHTTPRequest *mockRequest = [UMKMockURLProtocol expectMockHTTPPostRequestWithURL:URL requestJSON:requestJSON
                                                                        responseStatusCode:statusCode responseJSON:responseJSON];
    XCTAssertNotNil(mockRequest, @"Returned nil");
    XCTAssertEqualObjects(mockRequest.HTTPMethod, kUMKMockHTTPRequestPostMethod, @"Incorrect HTTP method");
    XCTAssertEqualObjects(mockRequest.URL, URL, @"Incorrect URL");
    XCTAssertEqualObjects([mockRequest JSONObjectFromBody], requestJSON, @"Incorrect JSON body");
    
    XCTAssertEqualObjects([UMKMockURLProtocol expectedMockRequests], @[ mockRequest ], @"Expectation is not added");
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    request.HTTPMethod = kUMKMockHTTPRequestPostMethod;
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestJSON options:0 error:NULL];
    
    id verifier = [self verifierForConnectionWithURLRequest:request];
    XCTAssertTrue([verifier waitForCompletionWithTimeout:1.0], @"Request did not complete in time");
    
    XCTAssertEqual([(NSHTTPURLResponse *)[verifier response] statusCode], statusCode, @"Received wrong status code");
    
    id actualResponseJSON = [NSJSONSerialization JSONObjectWithData:[verifier body] options:0 error:NULL];
    XCTAssertEqualObjects(actualResponseJSON, responseJSON, @"Received wrong body");
}


- (void)testExpectMockHTTPPutRequestWithURLRequestJSONResponseStatusCodeResponseJSON
{
    NSURL *URL = UMKRandomHTTPURL();
    id requestJSON = UMKRandomJSONObject(3, 3);
    NSInteger statusCode = random() % 400 + 100;
    id responseJSON = UMKRandomJSONObject(3, 3);
    
    UMKMockHTTPRequest *mockRequest = [UMKMockURLProtocol expectMockHTTPPutRequestWithURL:URL requestJSON:requestJSON
                                                                       responseStatusCode:statusCode responseJSON:responseJSON];
    XCTAssertNotNil(mockRequest, @"Returned nil");
    XCTAssertEqualObjects(mockRequest.HTTPMethod, kUMKMockHTTPRequestPutMethod, @"Incorrect HTTP method");
    XCTAssertEqualObjects(mockRequest.URL, URL, @"Incorrect URL");
    XCTAssertEqualObjects([mockRequest JSONObjectFromBody], requestJSON, @"Incorrect JSON body");
    
    XCTAssertEqualObjects([UMKMockURLProtocol expectedMockRequests], @[ mockRequest ], @"Expectation is not added");
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    request.HTTPMethod = kUMKMockHTTPRequestPutMethod;
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestJSON options:0 error:NULL];
    
    id verifier = [self verifierForConnectionWithURLRequest:request];
    XCTAssertTrue([verifier waitForCompletionWithTimeout:1.0], @"Request did not complete in time");
    
    XCTAssertEqual([(NSHTTPURLResponse *)[verifier response] statusCode], statusCode, @"Received wrong status code");
    
    id actualResponseJSON = [NSJSONSerialization JSONObjectWithData:[verifier body] options:0 error:NULL];
    XCTAssertEqualObjects(actualResponseJSON, responseJSON, @"Received wrong body");
}

@end
