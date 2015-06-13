//
//  URLMockIntegrationTests.m
//  URLMock
//
//  Created by Prachi Gauriar on 11/12/2013.
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


@interface URLMockIntegrationTests : UMKIntegrationTestCase

- (void)testConnectionMockRequestsWithErrorResponse;
- (void)testConnectionMockRequestsWithStatusCodeResponse;
- (void)testConnectionMockRequestsWithDataResponseInOneChunk;
- (void)testConnectionMockRequestsWithDataResponseInMultipleChunks;

- (void)testSessionMockRequestsWithErrorResponse;
- (void)testSessionMockRequestsWithStatusCodeResponse;
- (void)testSessionMockRequestsWithDataResponseInOneChunk;
- (void)testSessionMockRequestsWithDataResponseInMultipleChunks;

- (void)testVerifyWithUnexpectedRequest;
- (void)testVerifyWithUnservicedRequest;
- (void)testVerifySuccess;
- (void)testVerify;

@end


@implementation URLMockIntegrationTests

#pragma mark - Static Responders

- (void)testConnectionMockRequestsWithErrorResponse
{
    for (NSString *method in @[ @"DELETE", @"GET", @"HEAD", @"PATCH", @"POST", @"PUT" ]) {
        NSURL *URL = UMKRandomHTTPURL();
        
        NSError *error = UMKRandomError();
        UMKMockHTTPRequest *mockRequest = [[UMKMockHTTPRequest alloc] initWithHTTPMethod:method URL:URL];
        mockRequest.responder = [UMKMockHTTPResponder mockHTTPResponderWithError:error];
        [UMKMockURLProtocol expectMockRequest:mockRequest];

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        request.HTTPMethod = method;
        id verifier = [self verifierForConnectionWithURLRequest:request];
        XCTAssertTrue([verifier waitForCompletionWithTimeout:1.0], @"Request did not complete in time");
        
        XCTAssertTrue([verifier receivedMessageCountForSelector:@selector(connection:didFailWithError:)] == 1,
                      @"Received -connection:didFailWithError: wrong number of times.");
        XCTAssertEqualObjects([[verifier error] domain], error.domain, @"Error domain was not set correctly");
        XCTAssertEqual([[verifier error] code], error.code, @"Error code was not set correctly");
        
        [UMKMockURLProtocol reset];
    }
}


- (void)testConnectionMockRequestsWithStatusCodeResponse
{
    for (NSString *method in @[ @"DELETE", @"GET", @"HEAD", @"PATCH", @"POST", @"PUT" ]) {
        NSURL *URL = UMKRandomHTTPURL();
        NSData *requestBody = [NSJSONSerialization dataWithJSONObject:UMKRandomJSONObject(5, 5) options:0 error:NULL];
        NSInteger responseStatusCode = random() % 500 + 1;
        
        UMKMockHTTPRequest *mockRequest = [[UMKMockHTTPRequest alloc] initWithHTTPMethod:method URL:URL];
        mockRequest.body = requestBody;
        [mockRequest setValue:kUMKMockHTTPMessageUTF8JSONContentTypeHeaderValue forHeaderField:kUMKMockHTTPMessageContentTypeHeaderField];
        mockRequest.responder = [UMKMockHTTPResponder mockHTTPResponderWithStatusCode:responseStatusCode];
        [UMKMockURLProtocol expectMockRequest:mockRequest];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
        request.HTTPMethod = method;
        request.HTTPBody = requestBody;
        [request setValue:kUMKMockHTTPMessageUTF8JSONContentTypeHeaderValue forHTTPHeaderField:kUMKMockHTTPMessageContentTypeHeaderField];
        
        id verifier = [self verifierForConnectionWithURLRequest:request];
        XCTAssertTrue([verifier waitForCompletionWithTimeout:1.0], @"Request did not complete in time");
        
        XCTAssertTrue([verifier receivedMessageCountForSelector:@selector(connection:didReceiveResponse:)] == 1,
                      @"Received -connection:didReceiveResponse: wrong number of times.");
        XCTAssertTrue([verifier receivedMessageCountForSelector:@selector(connection:didReceiveData:)] == 0,
                      @"Received -connection:didReceiveData: wrong number of times.");
        XCTAssertTrue([verifier receivedMessageCountForSelector:@selector(connectionDidFinishLoading:)] == 1,
                      @"Received -connectionDidFinishLoading: wrong number of times.");
        
        XCTAssertEqual([(NSHTTPURLResponse *)[verifier response] statusCode], responseStatusCode, @"Received wrong status code");
        XCTAssertNil([verifier body], @"Received wrong body");
        
        [UMKMockURLProtocol reset];
    }
}


- (void)testConnectionMockRequestsWithDataResponseInOneChunk
{
    for (NSString *method in @[ @"DELETE", @"GET", @"HEAD", @"PATCH", @"POST", @"PUT" ]) {
        NSURL *URL = UMKRandomHTTPURL();
        NSData *requestBody = [NSJSONSerialization dataWithJSONObject:UMKRandomJSONObject(5, 5) options:0 error:NULL];
        NSData *responseBody = [UMKRandomUnicodeString() dataUsingEncoding:NSUTF8StringEncoding];
        NSInteger responseStatusCode = random() % 500 + 1;
        
        UMKMockHTTPRequest *mockRequest = [[UMKMockHTTPRequest alloc] initWithHTTPMethod:method URL:URL];
        mockRequest.body = requestBody;
        [mockRequest setValue:kUMKMockHTTPMessageUTF8JSONContentTypeHeaderValue forHeaderField:kUMKMockHTTPMessageContentTypeHeaderField];
        mockRequest.responder = [UMKMockHTTPResponder mockHTTPResponderWithStatusCode:responseStatusCode body:responseBody];
        [UMKMockURLProtocol expectMockRequest:mockRequest];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
        request.HTTPMethod = method;
        request.HTTPBody = requestBody;
        [request setValue:kUMKMockHTTPMessageUTF8JSONContentTypeHeaderValue forHTTPHeaderField:kUMKMockHTTPMessageContentTypeHeaderField];
        
        id verifier = [self verifierForConnectionWithURLRequest:request];
        XCTAssertTrue([verifier waitForCompletionWithTimeout:1.0], @"Request did not complete in time");
        
        XCTAssertTrue([verifier receivedMessageCountForSelector:@selector(connection:didReceiveResponse:)] == 1,
                      @"Received -connection:didReceiveResponse: wrong number of times.");
        XCTAssertTrue([verifier receivedMessageCountForSelector:@selector(connection:didReceiveData:)] == 1,
                       @"Received -connection:didReceiveData: wrong number of times.");
        XCTAssertTrue([verifier receivedMessageCountForSelector:@selector(connectionDidFinishLoading:)] == 1,
                      @"Received -connectionDidFinishLoading: wrong number of times.");
        
        XCTAssertEqual([(NSHTTPURLResponse *)[verifier response] statusCode], responseStatusCode, @"Received wrong status code");
        XCTAssertEqualObjects([verifier body], responseBody, @"Received wrong body");
        
        [UMKMockURLProtocol reset];
    }
}


- (void)testConnectionMockRequestsWithDataResponseInMultipleChunks
{
    for (NSString *method in @[ @"DELETE", @"GET", @"HEAD", @"PATCH", @"POST", @"PUT" ]) {
        NSURL *URL = UMKRandomHTTPURL();
        NSData *requestBody = [NSJSONSerialization dataWithJSONObject:UMKRandomJSONObject(5, 5) options:0 error:NULL];
        NSData *responseBody = [UMKRandomAlphanumericStringWithLength(2048) dataUsingEncoding:NSUTF8StringEncoding];
        NSInteger responseStatusCode = random() % 500 + 1;
        
        UMKMockHTTPRequest *mockRequest = [[UMKMockHTTPRequest alloc] initWithHTTPMethod:method URL:URL];
        mockRequest.body = requestBody;
        [mockRequest setValue:kUMKMockHTTPMessageUTF8JSONContentTypeHeaderValue forHeaderField:kUMKMockHTTPMessageContentTypeHeaderField];
        mockRequest.responder = [UMKMockHTTPResponder mockHTTPResponderWithStatusCode:responseStatusCode headers:nil body:responseBody
                                                                                 chunkCountHint:4 delayBetweenChunks:0.1];
        [UMKMockURLProtocol expectMockRequest:mockRequest];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
        request.HTTPMethod = method;
        request.HTTPBody = requestBody;
        [request setValue:kUMKMockHTTPMessageUTF8JSONContentTypeHeaderValue forHTTPHeaderField:kUMKMockHTTPMessageContentTypeHeaderField];
        
        id verifier = [self verifierForConnectionWithURLRequest:request];
        XCTAssertTrue([verifier waitForCompletionWithTimeout:1.0], @"Request did not complete in time");

        XCTAssertTrue([verifier receivedMessageCountForSelector:@selector(connection:didReceiveResponse:)] == 1,
                      @"Received -connection:didReceiveResponse: wrong number of times.");
        XCTAssertTrue([verifier receivedMessageCountForSelector:@selector(connection:didReceiveData:)] > 1,
                       @"Received -connection:didReceiveData: wrong number of times.");
        XCTAssertTrue([verifier receivedMessageCountForSelector:@selector(connectionDidFinishLoading:)] == 1,
                      @"Received -connectionDidFinishLoading: wrong number of times.");
        
        XCTAssertEqual([(NSHTTPURLResponse *)[verifier response] statusCode], responseStatusCode, @"Received wrong status code");
        XCTAssertEqualObjects([verifier body], responseBody, @"Received wrong body");
        
        [UMKMockURLProtocol reset];
    }
}


#pragma mark - Generated Responders

- (void)testSessionMockRequestsWithErrorResponse
{
    for (NSString *method in @[ @"DELETE", @"GET", @"HEAD", @"PATCH", @"POST", @"PUT" ]) {
        NSURL *URL = UMKRandomHTTPURL();

        NSError *error = UMKRandomError();
        UMKMockHTTPRequest *mockRequest = [[UMKMockHTTPRequest alloc] initWithHTTPMethod:method URL:URL];
        mockRequest.responder = [UMKMockHTTPResponder mockHTTPResponderWithError:error];
        [UMKMockURLProtocol expectMockRequest:mockRequest];

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        request.HTTPMethod = method;

        id verifier = [self verifierForSessionDataTaskWithURLRequest:request];
        XCTAssertTrue([verifier waitForCompletionWithTimeout:1.0], @"Request did not complete in time");

        XCTAssertTrue([verifier receivedMessageCountForSelector:@selector(URLSession:task:didCompleteWithError:)] == 1,
                      @"Received -URLSession:task:didCompleteWithError: wrong number of times.");
        XCTAssertEqualObjects([[verifier error] domain], error.domain, @"Error domain was not set correctly");
        XCTAssertEqual([[verifier error] code], error.code, @"Error code was not set correctly");

        [UMKMockURLProtocol reset];
    }
}


- (void)testSessionMockRequestsWithStatusCodeResponse
{
    for (NSString *method in @[ @"DELETE", @"GET", @"HEAD", @"PATCH", @"POST", @"PUT" ]) {
        NSURL *URL = UMKRandomHTTPURL();
        NSData *requestBody = [NSJSONSerialization dataWithJSONObject:UMKRandomJSONObject(5, 5) options:0 error:NULL];
        NSInteger responseStatusCode = random() % 500 + 1;

        UMKMockHTTPRequest *mockRequest = [[UMKMockHTTPRequest alloc] initWithHTTPMethod:method URL:URL];
        mockRequest.body = requestBody;
        [mockRequest setValue:kUMKMockHTTPMessageUTF8JSONContentTypeHeaderValue forHeaderField:kUMKMockHTTPMessageContentTypeHeaderField];
        mockRequest.responder = [UMKMockHTTPResponder mockHTTPResponderWithStatusCode:responseStatusCode];
        [UMKMockURLProtocol expectMockRequest:mockRequest];

        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
        request.HTTPMethod = method;
        request.HTTPBody = requestBody;
        [request setValue:kUMKMockHTTPMessageUTF8JSONContentTypeHeaderValue forHTTPHeaderField:kUMKMockHTTPMessageContentTypeHeaderField];

        id verifier = [self verifierForSessionDataTaskWithURLRequest:request];
        XCTAssertTrue([verifier waitForCompletionWithTimeout:1.0], @"Request did not complete in time");

        XCTAssertTrue([verifier receivedMessageCountForSelector:@selector(URLSession:task:didCompleteWithError:)] == 1,
                      @"Received -URLSession:task:didCompleteWithError: wrong number of times.");
        XCTAssertTrue([verifier receivedMessageCountForSelector:@selector(URLSession:dataTask:didReceiveResponse:completionHandler:)] == 1,
                      @"Received -connection:didReceiveData: wrong number of times.");
        XCTAssertTrue([verifier receivedMessageCountForSelector:@selector(URLSession:dataTask:didReceiveData:)] == 0,
                      @"Received -connection:didReceiveData: wrong number of times.");

        XCTAssertEqual([(NSHTTPURLResponse *)[verifier response] statusCode], responseStatusCode, @"Received wrong status code");
        XCTAssertNil([verifier body], @"Received wrong body");

        [UMKMockURLProtocol reset];
    }
}


- (void)testSessionMockRequestsWithDataResponseInOneChunk
{
    for (NSString *method in @[ @"DELETE", @"GET", @"HEAD", @"PATCH", @"POST", @"PUT" ]) {
        NSURL *URL = UMKRandomHTTPURL();
        NSData *requestBody = [NSJSONSerialization dataWithJSONObject:UMKRandomJSONObject(5, 5) options:0 error:NULL];
        NSInteger responseStatusCode = random() % 500 + 1;
        NSData *responseBody = [UMKRandomUnicodeString() dataUsingEncoding:NSUTF8StringEncoding];

        UMKMockHTTPRequest *mockRequest = [[UMKMockHTTPRequest alloc] initWithHTTPMethod:method URL:URL];
        mockRequest.body = requestBody;
        [mockRequest setValue:kUMKMockHTTPMessageUTF8JSONContentTypeHeaderValue forHeaderField:kUMKMockHTTPMessageContentTypeHeaderField];
        mockRequest.responder = [UMKMockHTTPResponder mockHTTPResponderWithStatusCode:responseStatusCode body:responseBody];
        [UMKMockURLProtocol expectMockRequest:mockRequest];

        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
        request.HTTPMethod = method;
        request.HTTPBody = requestBody;
        [request setValue:kUMKMockHTTPMessageUTF8JSONContentTypeHeaderValue forHTTPHeaderField:kUMKMockHTTPMessageContentTypeHeaderField];

        id verifier = [self verifierForSessionDataTaskWithURLRequest:request];
        XCTAssertTrue([verifier waitForCompletionWithTimeout:1.0], @"Request did not complete in time");

        XCTAssertTrue([verifier receivedMessageCountForSelector:@selector(URLSession:task:didCompleteWithError:)] == 1,
                      @"Received -URLSession:task:didCompleteWithError: wrong number of times.");
        XCTAssertTrue([verifier receivedMessageCountForSelector:@selector(URLSession:dataTask:didReceiveResponse:completionHandler:)] == 1,
                      @"Received -connection:didReceiveData: wrong number of times.");
        XCTAssertTrue([verifier receivedMessageCountForSelector:@selector(URLSession:dataTask:didReceiveData:)] == 1,
                      @"Received -connection:didReceiveData: wrong number of times for method %@.", method);

        XCTAssertEqual([(NSHTTPURLResponse *)[verifier response] statusCode], responseStatusCode, @"Received wrong status code");
        XCTAssertEqualObjects([verifier body], responseBody, @"Received wrong body");

        [UMKMockURLProtocol reset];
    }
}


- (void)testSessionMockRequestsWithDataResponseInMultipleChunks
{
    for (NSString *method in @[ @"DELETE", @"GET", @"HEAD", @"PATCH", @"POST", @"PUT" ]) {
        NSURL *URL = UMKRandomHTTPURL();
        NSData *requestBody = [NSJSONSerialization dataWithJSONObject:UMKRandomJSONObject(5, 5) options:0 error:NULL];
        NSData *responseBody = [UMKRandomAlphanumericStringWithLength(2048) dataUsingEncoding:NSUTF8StringEncoding];
        NSInteger responseStatusCode = random() % 500 + 1;

        UMKMockHTTPRequest *mockRequest = [[UMKMockHTTPRequest alloc] initWithHTTPMethod:method URL:URL];
        mockRequest.body = requestBody;
        [mockRequest setValue:kUMKMockHTTPMessageUTF8JSONContentTypeHeaderValue forHeaderField:kUMKMockHTTPMessageContentTypeHeaderField];
        mockRequest.responder = [UMKMockHTTPResponder mockHTTPResponderWithStatusCode:responseStatusCode headers:nil body:responseBody
                                                                       chunkCountHint:4 delayBetweenChunks:0.1];
        [UMKMockURLProtocol expectMockRequest:mockRequest];

        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
        request.HTTPMethod = method;
        request.HTTPBody = requestBody;

        id verifier = [self verifierForSessionDataTaskWithURLRequest:request];
        XCTAssertTrue([verifier waitForCompletionWithTimeout:1.0], @"Request did not complete in time");

        XCTAssertTrue([verifier receivedMessageCountForSelector:@selector(URLSession:task:didCompleteWithError:)] == 1,
                      @"Received -URLSession:task:didCompleteWithError: wrong number of times.");
        XCTAssertTrue([verifier receivedMessageCountForSelector:@selector(URLSession:dataTask:didReceiveResponse:completionHandler:)] == 1,
                      @"Received -connection:didReceiveData: wrong number of times.");
        XCTAssertTrue([verifier receivedMessageCountForSelector:@selector(URLSession:dataTask:didReceiveData:)] > 1,
                      @"Received -connection:didReceiveData: wrong number of times for method %@.", method);

        XCTAssertEqual([(NSHTTPURLResponse *)[verifier response] statusCode], responseStatusCode, @"Received wrong status code");
        XCTAssertEqualObjects([verifier body], responseBody, @"Received wrong body");
        
        [UMKMockURLProtocol reset];
    }
}


#pragma mark - Verify

- (void)testVerifyWithUnexpectedRequest
{
    [UMKMockURLProtocol setVerificationEnabled:YES];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:UMKRandomHTTPURL()];
    request.HTTPMethod = UMKRandomHTTPMethod();
    request.HTTPBody = [UMKRandomAlphanumericString() dataUsingEncoding:NSUTF8StringEncoding];
    
    id verifier = [self verifierForConnectionWithURLRequest:request];
    XCTAssertTrue([verifier waitForCompletionWithTimeout:1.0], @"Request did not complete in time");

    NSError *error = nil;
    XCTAssertFalse([UMKMockURLProtocol verifyWithError:&error], @"Returned YES despite unexpected request");
    XCTAssertEqual([error code], kUMKUnexpectedRequestErrorCode, @"Incorrect error code");

    NSArray *unexpectedRequests = [[error userInfo] objectForKey:kUMKUnexpectedRequestsKey];
    XCTAssertNotNil(unexpectedRequests, @"Unexpected requests not included in error userInfo dictionary");
    XCTAssertEqual(unexpectedRequests.count, (NSUInteger)1, @"Unexpected requests contains wrong number of requests");
    
    NSURLRequest *unexpectedRequest = [unexpectedRequests firstObject];
    NSURL *canonicalRequestURL = [UMKMockURLProtocol canonicalURLForURL:request.URL];
    NSURL *canonicalUnexpectedRequestURL = [UMKMockURLProtocol canonicalURLForURL:unexpectedRequest.URL];

    XCTAssertEqualObjects(canonicalRequestURL, canonicalUnexpectedRequestURL, @"Unexpected request has wrong URL");
    XCTAssertEqualObjects(unexpectedRequest.HTTPMethod, request.HTTPMethod, @"Unexpected request has wrong HTTP method");
    XCTAssertEqualObjects(unexpectedRequest.HTTPBody, request.HTTPBody, @"Unexpected request has wrong HTTP body");
    
    [UMKMockURLProtocol setVerificationEnabled:NO];
}


- (void)testVerifyWithUnservicedRequest
{
    [UMKMockURLProtocol setVerificationEnabled:YES];

    UMKPatternMatchingMockRequest *mockRequest = [[UMKPatternMatchingMockRequest alloc] initWithURLPattern:@"https://domain.com/subdomain/:resource"];
    mockRequest.responderGenerationBlock = ^id<UMKMockURLResponder>(NSURLRequest *request, NSDictionary *parameters) {
        return [UMKMockHTTPResponder mockHTTPResponderWithStatusCode:random() % 500];
    };

    [UMKMockURLProtocol expectMockRequest:mockRequest];

    NSError *error = nil;
    XCTAssertFalse([UMKMockURLProtocol verifyWithError:&error], @"Returned YES despite un-serviced request");
    XCTAssertEqual([error code], kUMKUnservicedMockRequestErrorCode, @"Incorrect error code");
    XCTAssertEqualObjects([[error userInfo] objectForKey:kUMKUnservicedMockRequestsKey], @[ mockRequest ], @"Incorrect unserviced requests returned");
    
    [UMKMockURLProtocol setVerificationEnabled:NO];
}


- (void)testVerifySuccess
{
    [UMKMockURLProtocol setVerificationEnabled:YES];

    NSString *pattern = @"https://domain.com/subdomain/:resource";
    NSURL *URL = [NSURL URLWithString:[pattern stringByReplacingOccurrencesOfString:@":resource" withString:@"users"]];
    NSData *body = [UMKRandomUnicodeString() dataUsingEncoding:NSUTF8StringEncoding];

    UMKPatternMatchingMockRequest *mockRequest = [[UMKPatternMatchingMockRequest alloc] initWithURLPattern:pattern];
    mockRequest.responderGenerationBlock = ^id<UMKMockURLResponder>(NSURLRequest *request, NSDictionary *parameters) {
        UMKMockHTTPResponder *responder = [UMKMockHTTPResponder mockHTTPResponderWithStatusCode:random() % 500];
        responder.body = [request umk_HTTPBodyData];
        return responder;
    };

    [UMKMockURLProtocol expectMockRequest:mockRequest];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPBodyStream = [NSInputStream inputStreamWithData:body];

    id verifier = [self verifierForConnectionWithURLRequest:request];
    XCTAssertTrue([verifier waitForCompletionWithTimeout:1.0], @"Request did not complete in time");

    XCTAssertTrue([UMKMockURLProtocol verifyWithError:NULL], @"Returned NO despite no unexpected or un-serviced requests");
    XCTAssertEqualObjects([UMKMockURLProtocol expectedMockRequests], @[ mockRequest ], @"Mock request was removed after being serviced");
    XCTAssertEqualObjects([verifier body], body, @"Received wrong body");

    [UMKMockURLProtocol setVerificationEnabled:NO];
}


- (void)testVerify
{
    // This tests mulitple failures in a single test case
    [UMKMockURLProtocol setVerificationEnabled:YES];
    
    // We use localhost because we want this to fail fast
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:1"]];
    id verifier = [self verifierForConnectionWithURLRequest:request];
    XCTAssertTrue([verifier waitForCompletionWithTimeout:1.0], @"Request did not complete in time");

    NSError *error = nil;
    XCTAssertFalse([UMKMockURLProtocol verifyWithError:&error], @"Returned YES despite unexpected request");
    XCTAssertEqual([error code], kUMKUnexpectedRequestErrorCode, @"Incorrect error code");

    [UMKMockURLProtocol reset];
    
    NSURL *URL = UMKRandomHTTPURL();
    UMKMockHTTPRequest *mockRequest = [UMKMockHTTPRequest mockHTTPGetRequestWithURL:URL];
    mockRequest.responder = [UMKMockHTTPResponder mockHTTPResponderWithStatusCode:random() % 500];
    [UMKMockURLProtocol expectMockRequest:mockRequest];
    XCTAssertFalse([UMKMockURLProtocol verifyWithError:&error], @"Returned YES despite un-serviced request");
    XCTAssertEqual([error code], kUMKUnservicedMockRequestErrorCode, @"Incorrect error code");
    XCTAssertEqualObjects([[error userInfo] objectForKey:kUMKUnservicedMockRequestsKey], @[ mockRequest ], @"Incorrect unserviced requests returned");

    verifier = [self verifierForConnectionWithURLRequest:[NSURLRequest requestWithURL:URL]];
    XCTAssertTrue([verifier waitForCompletionWithTimeout:1.0], @"Request did not complete in time");
    XCTAssertTrue([UMKMockURLProtocol verifyWithError:NULL], @"Returned NO despite no unexpected or un-serviced requests");

    [UMKMockURLProtocol setVerificationEnabled:NO];
}

@end
