//
//  UMKPatternMatchingMockRequestTests.m
//  URLMock
//
//  Created by Prachi Gauriar on 6/28/2014.
//  Copyright (c) 2014 Two Toasters, LLC.
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


@interface UMKPatternMatchingMockRequestTests : UMKRandomizedTestCase

- (void)testInit;

@end


@implementation UMKPatternMatchingMockRequestTests

- (void)testInit
{
    NSString *HTTPMethod = UMKRandomAlphanumericStringWithLength(10);
    NSURL *URL = UMKRandomHTTPURL();
    BOOL checksHeaders = UMKRandomBoolean();
    BOOL checksBody = UMKRandomBoolean();

    UMKMockHTTPRequest *mockRequest = [[UMKMockHTTPRequest alloc] initWithHTTPMethod:HTTPMethod URL:URL];
    XCTAssertNotNil(mockRequest, "Returns nil");
    XCTAssertEqualObjects(mockRequest.HTTPMethod, HTTPMethod, @"HTTP Method not set correctly");
    XCTAssertEqualObjects(mockRequest.URL, URL, @"URL not set correctly");
    XCTAssertFalse(mockRequest.checksHeadersWhenMatching, @"Header checking is initially YES");
    XCTAssertTrue(mockRequest.checksBodyWhenMatching, @"Body checking is initially NO");
    XCTAssertNil(mockRequest.responder, @"Responder is initially non-nil");
    XCTAssertTrue([mockRequest conformsToProtocol:@protocol(UMKMockURLRequest)], @"Does not conform to UMKMockURLRequest protocol");

    mockRequest = [[UMKMockHTTPRequest alloc] initWithHTTPMethod:HTTPMethod URL:URL checksHeadersWhenMatching:checksHeaders];
    XCTAssertNotNil(mockRequest, "Returns nil");
    XCTAssertEqualObjects(mockRequest.HTTPMethod, HTTPMethod, @"HTTP Method not set correctly");
    XCTAssertEqualObjects(mockRequest.URL, URL, @"URL not set correctly");
    XCTAssertEqual(mockRequest.checksHeadersWhenMatching, checksHeaders, @"Header checking not set correctly");
    XCTAssertTrue(mockRequest.checksBodyWhenMatching, @"Body checking is initially NO");
    XCTAssertNil(mockRequest.responder, @"Responder is initially non-nil");
    XCTAssertTrue([mockRequest conformsToProtocol:@protocol(UMKMockURLRequest)], @"Does not conform to UMKMockURLRequest protocol");

    mockRequest = [[UMKMockHTTPRequest alloc] initWithHTTPMethod:HTTPMethod URL:URL checksHeadersWhenMatching:checksHeaders checksBodyWhenMatching:checksBody];
    XCTAssertNotNil(mockRequest, "Returns nil");
    XCTAssertEqualObjects(mockRequest.HTTPMethod, HTTPMethod, @"HTTP Method not set correctly");
    XCTAssertEqualObjects(mockRequest.URL, URL, @"URL not set correctly");
    XCTAssertEqual(mockRequest.checksHeadersWhenMatching, checksHeaders, @"Header checking not set correctly");
    XCTAssertEqual(mockRequest.checksBodyWhenMatching, checksBody, @"Body checking not set correctly");
    XCTAssertNil(mockRequest.responder, @"Responder is initially non-nil");
    XCTAssertTrue([mockRequest conformsToProtocol:@protocol(UMKMockURLRequest)], @"Does not conform to UMKMockURLRequest protocol");
}

@end
