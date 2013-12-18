//
//  UMKUMKMockURLProtocolTests.m
//  URLMock
//
//  Created by Prachi Gauriar on 12/17/2013.
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
#import <URLMock/URLMock.h>
#import <URLMock/URLMockUtilities.h>

@interface UMKUMKMockURLProtocolTests : UMKRandomizedTestCase

- (void)testInterceptsAllRequestsAccessors;
- (void)testAutomaticallyRemovesServicedMockRequestsAccessors;

@end


@implementation UMKUMKMockURLProtocolTests

- (void)testInterceptsAllRequestsAccessors
{
    XCTAssertFalse([UMKMockURLProtocol interceptsAllRequests], @"Initial value is YES");
    [UMKMockURLProtocol setInterceptsAllRequests:YES];
    XCTAssertTrue([UMKMockURLProtocol interceptsAllRequests], @"Value is not set correctly");
    [UMKMockURLProtocol setInterceptsAllRequests:NO];
    XCTAssertFalse([UMKMockURLProtocol interceptsAllRequests], @"Value is not set correctly");
}


- (void)testAutomaticallyRemovesServicedMockRequestsAccessors
{
    XCTAssertFalse([UMKMockURLProtocol automaticallyRemovesServicedMockRequests], @"Initial value is YES");
    [UMKMockURLProtocol setAutomaticallyRemovesServicedMockRequests:YES];
    XCTAssertTrue([UMKMockURLProtocol automaticallyRemovesServicedMockRequests], @"Value is not set correctly");
    [UMKMockURLProtocol setAutomaticallyRemovesServicedMockRequests:NO];
    XCTAssertFalse([UMKMockURLProtocol automaticallyRemovesServicedMockRequests], @"Value is not set correctly");
}

@end
