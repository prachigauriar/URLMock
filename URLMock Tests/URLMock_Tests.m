//
//  URLMock_Tests.m
//  URLMock Tests
//
//  Created by Prachi Gauriar on 11/12/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <URLMock/URLMock.h>
#import "UMOMessageCountingProxy.h"
#import "UMOURLConnectionDelegateValidator.h"
#import "PGUtilities.h"

#pragma mark - Constants, Functions, and Macros

static NSString *const kURLMockTestsURLString = @"http://api.twotoasters.com/v1/path/to/resource/1";

BOOL UMOWaitForCondition(NSTimeInterval timeoutInterval, BOOL(^condition)(void))
{
    NSTimeInterval start = [[NSProcessInfo processInfo] systemUptime];

    while(!condition() && [[NSProcessInfo processInfo] systemUptime] - start <= timeoutInterval) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
    }

    return condition();
}


#define UMOAssertTrueBeforeTimeout(timeoutInterval, expression, message) \
    XCTAssertTrue(UMOWaitForCondition((timeoutInterval), ^BOOL{ return (expression); }), message)


@interface URLMock_Tests : XCTestCase
@end


@implementation URLMock_Tests

+ (void)setUp
{
    [UMOMockURLProtocol enable];
}


- (void)tearDown
{
    [UMOMockURLProtocol reset];
}


+ (void)tearDown
{
    [UMOMockURLProtocol disable];
}



- (void)testMockGetRequestWithErrorResponse
{
    UMOMockHTTPRequest *getRequest = [UMOMockHTTPRequest mockGetRequestWithURLString:kURLMockTestsURLString];

    NSError *error = [NSError errorWithDomain:UMOErrorDomain code:1234 userInfo:nil];
    getRequest.response = [UMOMockHTTPResponse mockResponseWithError:error];
    [UMOMockURLProtocol expectMockRequest:getRequest];

    id validator = [[[UMOURLConnectionDelegateValidator alloc] init] messageCountingProxy];
    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kURLMockTestsURLString]]
                                  delegate:validator];
    
    UMOAssertTrueBeforeTimeout(1, [validator receivedMessageCountForSelector:@selector(connection:didFailWithError:)] == 1,
                               @"Delegate received -connection:didFailWithError: wrong number of times.");
    XCTAssertEqualObjects([[validator error] domain], error.domain, @"Error domain was not set correctly");
    XCTAssertEqual([[validator error] code], error.code, @"Error code was not set correctly");
}


- (void)testMockGetRequestWithDataResponseInOneChunk
{
    UMOMockHTTPRequest *getRequest = [UMOMockHTTPRequest mockGetRequestWithURLString:kURLMockTestsURLString];
    getRequest.response = [UMOMockHTTPResponse mockResponseWithStatusCode:200];
    [getRequest.response setBodyWithString:@"1234"];

    [UMOMockURLProtocol expectMockRequest:getRequest];

    id validator = [[[UMOURLConnectionDelegateValidator alloc] init] messageCountingProxy];
    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kURLMockTestsURLString]]
                                  delegate:validator];

    UMOAssertTrueBeforeTimeout(1, [validator receivedMessageCountForSelector:@selector(connection:didReceiveResponse:)] == 1,
                               @"Validator received -connection:didReceiveResponse: wrong number of times.");
    UMOAssertTrueBeforeTimeout(1, [validator receivedMessageCountForSelector:@selector(connection:didReceiveData:)] == 1,
                               @"Validator received -connection:didReceiveData: wrong number of times.");
    UMOAssertTrueBeforeTimeout(1, [validator receivedMessageCountForSelector:@selector(connectionDidFinishLoading:)] == 1,
                               @"Validator received -connectionDidFinishLoading: wrong number of times.");

    XCTAssertEqualObjects([[NSString alloc] initWithData:[validator body] encoding:NSUTF8StringEncoding], @"1234", @"Validator received wrong body");
}


- (void)testMockGetRequestWithDataResponseInMultipleChunks
{
    UMOMockHTTPRequest *getRequest = [UMOMockHTTPRequest mockGetRequestWithURLString:kURLMockTestsURLString];

    NSMutableData *data = [[NSMutableData alloc] init];
    [data setLength:2048];

    getRequest.response = [UMOMockHTTPResponse mockResponseWithStatusCode:200 headers:nil body:data chunkCountHint:4 delayBetweenChunks:1.0];
    [UMOMockURLProtocol expectMockRequest:getRequest];

    id validator = [[[UMOURLConnectionDelegateValidator alloc] init] messageCountingProxy];
    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kURLMockTestsURLString]]
                                  delegate:validator];

    UMOAssertTrueBeforeTimeout(1, [validator receivedMessageCountForSelector:@selector(connection:didReceiveResponse:)] == 1,
                               @"Validator received -connection:didReceiveResponse: wrong number of times.");
    UMOAssertTrueBeforeTimeout(4, [validator receivedMessageCountForSelector:@selector(connection:didReceiveData:)] == 4,
                               @"Validator received -connection:didReceiveData: wrong number of times.");
    UMOAssertTrueBeforeTimeout(1, [validator receivedMessageCountForSelector:@selector(connectionDidFinishLoading:)] == 1,
                               @"Validator received -connectionDidFinishLoading: wrong number of times.");

    XCTAssertEqualObjects([validator body], data, @"Validator received wrong body");
}




@end
