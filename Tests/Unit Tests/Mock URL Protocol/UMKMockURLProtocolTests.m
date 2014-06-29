//
//  UMKUMKMockURLProtocolTests.m
//  URLMock
//
//  Created by Prachi Gauriar on 12/17/2013.
//  Copyright (c) 2013–2014 Two Toasters, LLC.
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

#import "UMKRandomizedTestCase.h"

#import <OCMock/OCMock.h>


@interface UMKMockURLProtocolTests : UMKRandomizedTestCase

- (void)testReset;
- (void)testVerificationEnabledAccessors;
- (void)testExpectedMockRequestsAccessors;

@end


@implementation UMKMockURLProtocolTests

- (void)setUp
{
    [super setUp];
    [UMKMockURLProtocol reset];
}


- (void)testReset
{
    id<UMKMockURLRequest> mockRequest1 = [OCMockObject mockForProtocol:@protocol(UMKMockURLRequest)];
    id<UMKMockURLRequest> mockRequest2 = [OCMockObject mockForProtocol:@protocol(UMKMockURLRequest)];
    
    [UMKMockURLProtocol expectMockRequest:mockRequest1];
    [UMKMockURLProtocol expectMockRequest:mockRequest2];
    
    XCTAssertEqualObjects([UMKMockURLProtocol expectedMockRequests], (@[ mockRequest1, mockRequest2 ]), @"Mock requests not added");

    [UMKMockURLProtocol reset];
    XCTAssertEqualObjects([UMKMockURLProtocol expectedMockRequests], @[], @"Mock requests not removed");
}


- (void)testVerificationEnabledAccessors
{
    XCTAssertFalse([UMKMockURLProtocol isVerificationEnabled], @"Initial value is YES");
    
    XCTAssertThrowsSpecificNamed([UMKMockURLProtocol verifyWithError:NULL], NSException, NSInternalInconsistencyException,
                                 @"Does not throw exception when verification is not enabled.");
    
    [UMKMockURLProtocol setVerificationEnabled:YES];
    XCTAssertTrue([UMKMockURLProtocol isVerificationEnabled], @"Value is not set correctly");
    [UMKMockURLProtocol setVerificationEnabled:NO];
    XCTAssertFalse([UMKMockURLProtocol isVerificationEnabled], @"Value is not set correctly");
}


- (void)testExpectedMockRequestsAccessors
{
    XCTAssertEqualObjects([UMKMockURLProtocol expectedMockRequests], @[], @"Expected mock requests isn't empty");

    id<UMKMockURLRequest> mockRequest1 = [OCMockObject mockForProtocol:@protocol(UMKMockURLRequest)];
    [UMKMockURLProtocol expectMockRequest:mockRequest1];
    XCTAssertEqualObjects([UMKMockURLProtocol expectedMockRequests], @[ mockRequest1 ], @"Mock request not added");
    
    id<UMKMockURLRequest> mockRequest2 = [OCMockObject mockForProtocol:@protocol(UMKMockURLRequest)];
    [UMKMockURLProtocol expectMockRequest:mockRequest2];
    XCTAssertEqualObjects([UMKMockURLProtocol expectedMockRequests], (@[ mockRequest1, mockRequest2 ]), @"Mock request not added");

    [UMKMockURLProtocol removeExpectedMockRequest:mockRequest1];
    XCTAssertEqualObjects([UMKMockURLProtocol expectedMockRequests], @[ mockRequest2 ], @"Mock request not removed");

    [UMKMockURLProtocol removeExpectedMockRequest:mockRequest2];
    XCTAssertEqualObjects([UMKMockURLProtocol expectedMockRequests], @[], @"Mock request not removed");
}


@end
