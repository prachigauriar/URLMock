//
//  UMKMockHTTPRequestTests.m
//  URLMock
//
//  Created by Prachi Gauriar on 11/16/2013.
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

#import "UMKRandomizedTestCase.h"


@interface UMKMockHTTPRequestTests : UMKRandomizedTestCase

- (void)testInit;
- (void)testConvenienceFactoryMethods;
- (void)testDefaultHeaders;
- (void)testMatchesURLRequest;
- (void)testResponderAccessors;

@end


@implementation UMKMockHTTPRequestTests

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


- (void)testConvenienceFactoryMethods
{
    NSURL *URL = UMKRandomHTTPURL();

    for (NSString *method in @[ @"DELETE", @"GET", @"HEAD", @"PATCH", @"POST", @"PUT" ]) {
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"mockHTTP%@RequestWithURL:", method.capitalizedString]);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        UMKMockHTTPRequest *mockRequest = [[UMKMockHTTPRequest class] performSelector:selector withObject:URL];
#pragma clang diagnostic pop
        
        XCTAssertNotNil(mockRequest, @"Returns nil");
        XCTAssertEqual([mockRequest.HTTPMethod caseInsensitiveCompare:method], NSOrderedSame, @"HTTP method is not %@", method);
        XCTAssertEqualObjects(mockRequest.URL, URL, @"URL not set correctly");
    }
}


- (void)testDefaultHeaders
{
    XCTAssertNil([UMKMockHTTPRequest defaultHeaders], @"Not initially nil");
    
    NSDictionary *defaultHeaders = UMKRandomDictionaryOfStringsWithElementCount(random() % 10 + 1);
    [UMKMockHTTPRequest setDefaultHeaders:defaultHeaders];
    XCTAssertEqualObjects([UMKMockHTTPRequest defaultHeaders], defaultHeaders, @"Not set correctly");

    UMKMockHTTPRequest *request = [[UMKMockHTTPRequest alloc] initWithHTTPMethod:UMKRandomHTTPMethod() URL:UMKRandomHTTPURL()];
    XCTAssertEqualObjects([UMKMockHTTPRequest defaultHeaders], request.headers, @"Headers not set correctly on new instances");
    
    [UMKMockHTTPRequest setDefaultHeaders:nil];
    XCTAssertNil([UMKMockHTTPRequest defaultHeaders], @"Not set back to nil");
    request = [[UMKMockHTTPRequest alloc] initWithHTTPMethod:UMKRandomHTTPMethod() URL:UMKRandomHTTPURL()];
    XCTAssertNotNil(request.headers, @"Nil headers");
    XCTAssertEqual(request.headers.count, (NSUInteger)0, @"Headers are not empty");
}


- (void)testMatchesURLRequest
{
    NSURL *URL = UMKRandomHTTPURL();

    UMKMockHTTPRequest *mockRequest = [UMKMockHTTPRequest mockHTTPPostRequestWithURL:URL];
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
    mockRequest.checksBodyWhenMatching = NO;
    XCTAssertTrue([mockRequest matchesURLRequest:request], @"Does not match request when body matching is off.");

    mockRequest.checksBodyWhenMatching = YES;
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
    request.HTTPBody = [[parameters umk_URLEncodedParameterString] dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertTrue([mockRequest matchesURLRequest:request], @"Does not match equivalent request.");
}


- (void)testResponderAccessors
{
    NSURL *URL = UMKRandomHTTPURL();

    UMKMockHTTPRequest *mockRequest = [UMKMockHTTPRequest mockHTTPGetRequestWithURL:URL];
    UMKMockHTTPResponder *responder = [UMKMockHTTPResponder mockHTTPResponderWithStatusCode:200];
    mockRequest.responder = responder;
    
    XCTAssertEqualObjects(responder, mockRequest.responder, @"Responder is not set correctly.");
    XCTAssertEqualObjects(responder, [mockRequest responderForURLRequest:nil], @"Incorrect responder returned");

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:URL];
    XCTAssertEqualObjects(responder, [mockRequest responderForURLRequest:request], @"Incorrect responder returned");
}

@end
