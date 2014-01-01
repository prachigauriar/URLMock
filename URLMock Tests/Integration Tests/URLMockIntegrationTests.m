//
//  URLMockIntegrationTests.m
//  URLMock Tests
//
//  Created by Prachi Gauriar on 11/12/2013.
//  Copyright (c) 2013 Prachi Gauriar.
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

#import <XCTest/XCTest.h>

#import "UMKRandomizedTestCase.h"
#import "UMKURLConnectionVerifier.h"
#import <URLMock/URLMock.h>
#import <URLMock/URLMockUtilities.h>

@interface URLMockIntegrationTests : UMKRandomizedTestCase

- (void)testMockRequestsWithErrorResponse;
- (void)testMockRequestsWithNoResponse;
- (void)testMockRequestsWithDataResponseInOneChunk;
- (void)testMockRequestsWithDataResponseInMultipleChunks;

@end


@implementation URLMockIntegrationTests

+ (void)setUp
{
    [super setUp];
    [UMKMockURLProtocol enable];
}


- (void)tearDown
{
    [UMKMockURLProtocol reset];
    [super tearDown];
}


+ (void)tearDown
{
    [UMKMockURLProtocol disable];
    [super tearDown];
}


+ (NSOperationQueue *)connectionOperationQueue
{
    static NSOperationQueue *connectionOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        connectionOperationQueue = [[NSOperationQueue alloc] init];
        connectionOperationQueue.name = @"com.quantumlenscap.URLMockIntegrationTests.connectionOperationQueue";
    });
    
    return connectionOperationQueue;
}


- (id)verifierForConnectionWithURLRequest:(NSURLRequest *)request
{
    id verifier = [UMKMessageCountingProxy messageCountingProxyWithObject:[[UMKURLConnectionVerifier alloc] init]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:verifier startImmediately:NO];
    connection.delegateQueue = [[self class] connectionOperationQueue];
    [connection start];
    return verifier;
}


- (void)testMockRequestsWithErrorResponse
{
    for (NSString *method in @[ @"DELETE", @"GET", @"HEAD", @"PATCH", @"POST", @"PUT" ]) {
        NSURL *URL = UMKRandomHTTPURL();
        
        NSError *error = [NSError errorWithDomain:@"UMKError" code:1234 userInfo:nil];
        UMKMockHTTPRequest *mockRequest = [UMKMockHTTPRequest mockHTTPGetRequestWithURLString:URL.description];
        mockRequest.responder = [UMKMockHTTPResponder mockHTTPResponderWithError:error];
        [UMKMockURLProtocol expectMockRequest:mockRequest];

        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        id verifier = [self verifierForConnectionWithURLRequest:request];
        XCTAssertTrue([verifier waitForCompletionWithTimeout:1.0], @"Request did not complete in time");
        
        XCTAssertTrue([verifier receivedMessageCountForSelector:@selector(connection:didFailWithError:)] == 1,
                      @"Received -connection:didFailWithError: wrong number of times.");
        XCTAssertEqualObjects([[verifier error] domain], error.domain, @"Error domain was not set correctly");
        XCTAssertEqual([[verifier error] code], error.code, @"Error code was not set correctly");
        
        [UMKMockURLProtocol reset];
    }
}


- (void)testMockRequestsWithNoResponse
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


- (void)testMockRequestsWithDataResponseInOneChunk
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


- (void)testMockRequestsWithDataResponseInMultipleChunks
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


- (void)testVerifyWithUnexpectedRequest
{
    [UMKMockURLProtocol setVerificationEnabled:YES];

    // We use localhost because we want this to fail fast
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:1"]];
    id verifier = [self verifierForConnectionWithURLRequest:request];
    XCTAssertTrue([verifier waitForCompletionWithTimeout:1.0], @"Request did not complete in time");

    XCTAssertFalse([UMKMockURLProtocol verify], @"Returned YES despite unexpected request");
    
    [UMKMockURLProtocol setVerificationEnabled:NO];
}


- (void)testVerifyWithUnservicedRequest
{
    [UMKMockURLProtocol setVerificationEnabled:YES];

    UMKMockHTTPRequest *mockRequest = [UMKMockHTTPRequest mockHTTPGetRequestWithURLString:[UMKRandomHTTPURL() description]];
    mockRequest.responder = [UMKMockHTTPResponder mockHTTPResponderWithStatusCode:random() % 500];
    [UMKMockURLProtocol expectMockRequest:mockRequest];

    XCTAssertFalse([UMKMockURLProtocol verify], @"Returned YES despite un-serviced request");
    
    [UMKMockURLProtocol setVerificationEnabled:NO];
}


- (void)testVerifySuccess
{
    [UMKMockURLProtocol setVerificationEnabled:YES];
    
    NSURL *URL = UMKRandomHTTPURL();
    UMKMockHTTPRequest *mockRequest = [UMKMockHTTPRequest mockHTTPGetRequestWithURLString:URL.description];
    mockRequest.responder = [UMKMockHTTPResponder mockHTTPResponderWithStatusCode:random() % 500];
    [UMKMockURLProtocol expectMockRequest:mockRequest];

    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    id verifier = [self verifierForConnectionWithURLRequest:request];
    XCTAssertTrue([verifier waitForCompletionWithTimeout:1.0], @"Request did not complete in time");

    XCTAssertTrue([UMKMockURLProtocol verify], @"Returned NO despite no unexpected or un-serviced requests");

    [UMKMockURLProtocol setVerificationEnabled:NO];
}


- (void)testVerify
{
    [UMKMockURLProtocol setVerificationEnabled:YES];
    
    // We use localhost because we want this to fail fast
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:1"]];
    id verifier = [self verifierForConnectionWithURLRequest:request];
    XCTAssertTrue([verifier waitForCompletionWithTimeout:1.0], @"Request did not complete in time");
    XCTAssertFalse([UMKMockURLProtocol verify], @"Returned YES despite unexpected request");

    [UMKMockURLProtocol reset];
    
    NSURL *URL = UMKRandomHTTPURL();
    UMKMockHTTPRequest *mockRequest = [UMKMockHTTPRequest mockHTTPGetRequestWithURLString:[URL description]];
    mockRequest.responder = [UMKMockHTTPResponder mockHTTPResponderWithStatusCode:random() % 500];
    [UMKMockURLProtocol expectMockRequest:mockRequest];
    XCTAssertFalse([UMKMockURLProtocol verify], @"Returned YES despite un-serviced request");

    verifier = [self verifierForConnectionWithURLRequest:[NSURLRequest requestWithURL:URL]];
    XCTAssertTrue([verifier waitForCompletionWithTimeout:1.0], @"Request did not complete in time");
    XCTAssertTrue([UMKMockURLProtocol verify], @"Returned NO despite no unexpected or un-serviced requests");

    [UMKMockURLProtocol setVerificationEnabled:NO];
}

@end
