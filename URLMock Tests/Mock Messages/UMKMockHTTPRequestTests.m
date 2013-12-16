//
//  UMKMockHTTPRequestTests.m
//  URLMock
//
//  Created by Prachi Gauriar on 11/16/2013.
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

@interface UMKMockHTTPRequestTests : UMKRandomizedTestCase

- (void)testInit;
- (void)testConvenienceFactoryMethods;
- (void)testMatchesURLRequest;
- (void)testResponderAccessors;

@end


@implementation UMKMockHTTPRequestTests

- (void)testInit
{
    NSString *HTTPMethod = UMKRandomAlphanumericStringWithLength(10);
    NSURL *URL = UMKRandomHTTPURL();
    
    UMKMockHTTPRequest *mockRequest = [[UMKMockHTTPRequest alloc] initWithHTTPMethod:HTTPMethod URL:URL];
    XCTAssertNotNil(mockRequest, "Returns nil");
    XCTAssertEqualObjects(mockRequest.HTTPMethod, HTTPMethod, @"HTTP Method not set correctly");
    XCTAssertEqualObjects(mockRequest.URL, URL, @"URL not set correctly");
    XCTAssertTrue([mockRequest conformsToProtocol:@protocol(UMKMockURLRequest)], @"Does not conform to UMKMockURLRequest protocol");
}


- (void)testConvenienceFactoryMethods
{
    NSURL *URL = UMKRandomHTTPURL();
    NSString *URLString = [URL description];

    for (NSString *method in @[ @"DELETE", @"GET", @"HEAD", @"PATCH", @"POST", @"PUT" ]) {
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"mockHTTP%@RequestWithURLString:", method.capitalizedString]);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        UMKMockHTTPRequest *mockRequest = [[UMKMockHTTPRequest class] performSelector:selector withObject:URLString];
#pragma clang diagnostic pop
        
        XCTAssertNotNil(mockRequest, @"Returns nil");
        XCTAssertEqual([mockRequest.HTTPMethod caseInsensitiveCompare:method], NSOrderedSame, @"HTTP method is not %@", method);
        XCTAssertEqualObjects(mockRequest.URL, URL, @"URL not set correctly");
    }
}


- (void)testMatchesURLRequest
{
    NSURL *URL = UMKRandomHTTPURL();
    NSString *URLString = [URL description];

    UMKMockHTTPRequest *mockRequest = [UMKMockHTTPRequest mockHTTPPostRequestWithURLString:URLString];
    NSDictionary *headers = UMKRandomDictionaryOfStringsWithElementCount(12);
    mockRequest.headers = headers;

    NSString *bodyString = UMKRandomUnicodeStringWithLength(1024);
    [mockRequest setBodyWithString:bodyString encoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:UMKRandomHTTPURL()];
    XCTAssertFalse([mockRequest matchesURLRequest:request], @"Matches request with incorrect URL, HTTP method, headers, and body.");

    request.URL = URL;
    XCTAssertFalse([mockRequest matchesURLRequest:request], @"Matches request with incorrect HTTP method, headers, and body.");

    request.HTTPMethod = @"POST";
    XCTAssertFalse([mockRequest matchesURLRequest:request], @"Matches request with incorrect headers and body.");
    
    for (NSString *key in headers) {
        [request setValue:headers[key] forHTTPHeaderField:key];
    }

    XCTAssertFalse([mockRequest matchesURLRequest:request], @"Matches request with incorrect body.");
    
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertTrue([mockRequest matchesURLRequest:request], @"Does not match equivalent request.");

    id JSONObject = UMKRandomJSONObject(3, 3);
    [mockRequest setBodyWithJSONObject:JSONObject];
    XCTAssertFalse([mockRequest matchesURLRequest:request], @"Matches request with incorrect headers and body.");

    [request setValue:kUMKMockHTTPMessageUTF8JSONContentTypeHeaderValue forHTTPHeaderField:kUMKMockHTTPMessageContentTypeHeaderField];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:JSONObject options:0 error:NULL];
    XCTAssertTrue([mockRequest matchesURLRequest:request], @"Does not match equivalent request.");
    
    NSDictionary *parameters = UMKRandomDictionaryOfStringsWithElementCount(4);
    [mockRequest setBodyByURLEncodingParameters:parameters];
    [mockRequest setValue:kUMKMockHTTPMessageUTF8WWWFormURLEncodedContentTypeHeaderValue forHeaderField:kUMKMockHTTPMessageContentTypeHeaderField];
    XCTAssertFalse([mockRequest matchesURLRequest:request], @"Matches request with incorrect headers and body.");
    
    [request setValue:kUMKMockHTTPMessageUTF8WWWFormURLEncodedContentTypeHeaderValue forHTTPHeaderField:kUMKMockHTTPMessageContentTypeHeaderField];
    request.HTTPBody = [UMKURLEncodedStringForParameters(parameters) dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertTrue([mockRequest matchesURLRequest:request], @"Does not match equivalent request.");
}


- (void)testResponderAccessors
{
    NSURL *URL = UMKRandomHTTPURL();
    NSString *URLString = [URL description];

    UMKMockHTTPRequest *mockRequest = [UMKMockHTTPRequest mockHTTPGetRequestWithURLString:URLString];
    UMKMockHTTPResponder *responder = [UMKMockHTTPResponder mockHTTPResponderWithStatusCode:200];
    mockRequest.responder = responder;
    
    XCTAssertEqualObjects(responder, mockRequest.responder, @"Responder is not set correctly.");
    XCTAssertEqualObjects(responder, [mockRequest responderForURLRequest:nil], @"Incorrect responder returned");

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:URL];
    XCTAssertEqualObjects(responder, [mockRequest responderForURLRequest:request], @"Incorrect responder returned");
}

@end
