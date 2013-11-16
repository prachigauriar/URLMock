//
//  URLMock_Tests.m
//  URLMock Tests
//
//  Created by Prachi Gauriar on 11/12/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <URLMock/URLMock.h>

#import <URLMock/UMKErrorUtilities.h>
#import <URLMock/UMKMessageCountingProxy.h>
#import <URLMock/UMKTestUtilities.h>
#import <URLMock/UMKURLConnectionDelegateValidator.h>


@interface URLMock_Tests : XCTestCase
@property (strong, nonatomic) id validator;
@end


@implementation URLMock_Tests

+ (void)setUp
{
    [UMKMockURLProtocol enable];
}


- (void)setUp
{
    self.validator = [[[UMKURLConnectionDelegateValidator alloc] init] messageCountingProxy];
}


- (void)tearDown
{
    self.validator = nil;
    [UMKMockURLProtocol reset];
}


+ (void)tearDown
{
    [UMKMockURLProtocol disable];
}


- (void)testMockGetRequestWithErrorResponse
{
    NSURL *requestURL = UMKRandomHTTPURL();
    UMKMockHTTPRequest *getRequest = [UMKMockHTTPRequest mockHTTPGetRequestWithURLString:[requestURL description]];

    NSError *error = [NSError errorWithDomain:@"UMKError" code:1234 userInfo:nil];
    getRequest.responder = [UMKMockHTTPResponder mockHTTPResponderWithError:error];
    [UMKMockURLProtocol expectMockRequest:getRequest];

    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:requestURL] delegate:self.validator];
    
    UMKAssertTrueBeforeTimeout(1, [self.validator receivedMessageCountForSelector:@selector(connection:didFailWithError:)] == 1,
                               @"Delegate received -connection:didFailWithError: wrong number of times.");
    XCTAssertEqualObjects([[self.validator error] domain], error.domain, @"Error domain was not set correctly");
    XCTAssertEqual([[self.validator error] code], error.code, @"Error code was not set correctly");
}


- (void)testMockGetRequestWithDataResponseInOneChunk
{
    NSURL *requestURL = UMKRandomHTTPURL();
    NSString *bodyString = UMKRandomAlphanumericString();

    UMKMockHTTPRequest *getRequest = [UMKMockHTTPRequest mockHTTPGetRequestWithURLString:[requestURL description]];
    UMKMockHTTPResponder *responder = [UMKMockHTTPResponder mockHTTPResponderWithStatusCode:200];
    [responder setBodyWithString:bodyString];
    getRequest.responder = responder;

    [UMKMockURLProtocol expectMockRequest:getRequest];

    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:requestURL] delegate:self.validator];

    UMKAssertTrueBeforeTimeout(1, [self.validator receivedMessageCountForSelector:@selector(connection:didReceiveResponse:)] == 1,
                               @"Validator received -connection:didReceiveResponse: wrong number of times.");
    UMKAssertTrueBeforeTimeout(1, [self.validator receivedMessageCountForSelector:@selector(connection:didReceiveData:)] == 1,
                               @"Validator received -connection:didReceiveData: wrong number of times.");
    UMKAssertTrueBeforeTimeout(1, [self.validator receivedMessageCountForSelector:@selector(connectionDidFinishLoading:)] == 1,
                               @"Validator received -connectionDidFinishLoading: wrong number of times.");

    XCTAssertTrue([(NSHTTPURLResponse *)[self.validator response] statusCode] == 200, @"Validator received wrong status code");
    XCTAssertEqualObjects([self.validator body], [bodyString dataUsingEncoding:NSUTF8StringEncoding], @"Validator received wrong body");
}


- (void)testMockGetRequestWithDataResponseInMultipleChunks
{
    NSURL *requestURL = UMKRandomHTTPURL();

    UMKMockHTTPRequest *getRequest = [UMKMockHTTPRequest mockHTTPGetRequestWithURLString:[requestURL description]];
    NSString *bodyString = UMKRandomAlphanumericStringWithLength(2048);

    UMKMockHTTPResponder *responder = [UMKMockHTTPResponder mockHTTPResponderWithStatusCode:200 headers:nil body:nil chunkCountHint:4 delayBetweenChunks:1.0];
    [responder setBodyWithString:bodyString];
    getRequest.responder = responder;
    [UMKMockURLProtocol expectMockRequest:getRequest];

    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:requestURL] delegate:self.validator];

    UMKAssertTrueBeforeTimeout(1, [self.validator receivedMessageCountForSelector:@selector(connection:didReceiveResponse:)] == 1,
                               @"Validator received -connection:didReceiveResponse: wrong number of times.");
    UMKAssertTrueBeforeTimeout(10, [self.validator receivedMessageCountForSelector:@selector(connection:didReceiveData:)] == 4,
                               @"Validator received -connection:didReceiveData: wrong number of times.");
    UMKAssertTrueBeforeTimeout(1, [self.validator receivedMessageCountForSelector:@selector(connectionDidFinishLoading:)] == 1,
                               @"Validator received -connectionDidFinishLoading: wrong number of times.");

    XCTAssertTrue([(NSHTTPURLResponse *)[self.validator response] statusCode] == 200, @"Validator received wrong status code");
    XCTAssertEqualObjects([self.validator body], [bodyString dataUsingEncoding:NSUTF8StringEncoding], @"Validator received wrong body");
}


- (void)testMockPostRequestWithNoResponse
{
    NSURL *requestURL = UMKRandomHTTPURL();
    id bodyJSON = @[@1, @2, @3];

    UMKMockHTTPRequest *postRequest = [UMKMockHTTPRequest mockHTTPPostRequestWithURLString:[requestURL description]];
    [postRequest setBodyWithJSONObject:bodyJSON];
    postRequest.responder = [UMKMockHTTPResponder mockHTTPResponderWithStatusCode:200];
    [UMKMockURLProtocol expectMockRequest:postRequest];


    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:bodyJSON options:0 error:NULL];
    [request setValue:kUMKMockHTTPMessageUTF8JSONContentTypeHeaderValue forHTTPHeaderField:kUMKMockHTTPMessageContentTypeHeaderField];

    [NSURLConnection connectionWithRequest:request delegate:self.validator];

    UMKAssertTrueBeforeTimeout(1, [self.validator receivedMessageCountForSelector:@selector(connection:didReceiveResponse:)] == 1,
                               @"Validator received -connection:didReceiveResponse: wrong number of times.");
    UMKAssertTrueBeforeTimeout(1, [self.validator receivedMessageCountForSelector:@selector(connection:didReceiveData:)] == 0,
                               @"Validator received -connection:didReceiveData: wrong number of times.");
    UMKAssertTrueBeforeTimeout(1, [self.validator receivedMessageCountForSelector:@selector(connectionDidFinishLoading:)] == 1,
                               @"Validator received -connectionDidFinishLoading: wrong number of times.");

    XCTAssertTrue([(NSHTTPURLResponse *)[self.validator response] statusCode] == 200, @"Validator received wrong status code");
    XCTAssertNil([self.validator body], @"Validator received wrong body");
}


@end
