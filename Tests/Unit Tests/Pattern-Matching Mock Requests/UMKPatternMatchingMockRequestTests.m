//
//  UMKPatternMatchingMockRequestTests.m
//  URLMock
//
//  Created by Prachi Gauriar on 6/28/2014.
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


@interface UMKPatternMatchingMockRequestTests : UMKRandomizedTestCase

- (void)testInit;
- (void)testHTTPMethods;
- (void)testMatchesURLRequest;
- (void)testResponderForURLRequest;

@end


@implementation UMKPatternMatchingMockRequestTests

- (void)testInit
{
    NSString *pattern = UMKRandomAlphanumericString();

    XCTAssertThrowsSpecificNamed([[UMKPatternMatchingMockRequest alloc] init], NSException, NSInternalInconsistencyException, @"does not raise assertion");
    XCTAssertThrowsSpecificNamed([[UMKPatternMatchingMockRequest alloc] initWithURLPattern:nil], NSException, NSInternalInconsistencyException,
                                 @"does not raise assertion");
    UMKPatternMatchingMockRequest *mockRequest = [[UMKPatternMatchingMockRequest alloc] initWithURLPattern:pattern];
    XCTAssertNotNil(mockRequest, "Returns nil");
    XCTAssertEqualObjects(mockRequest.URLPattern, pattern, @"URL pattern is set incorrectly");
    XCTAssertNil(mockRequest.responderGenerationBlock, @"Responder generator block is not initially nil");
    XCTAssertNil(mockRequest.HTTPMethods, @"HTTP methods is not initially nil");
    XCTAssertNil(mockRequest.requestMatchingBlock, @"Request matching block is not initially nil");
    XCTAssertTrue([mockRequest conformsToProtocol:@protocol(UMKMockURLRequest)], @"Does not conform to UMKMockURLRequest protocol");

    XCTAssertTrue([mockRequest respondsToSelector:@selector(shouldRemoveAfterServicingRequest:)], @"Does not implement -shouldRemoveAfterServicingRequest:");
    XCTAssertFalse([mockRequest shouldRemoveAfterServicingRequest:nil], @"Returns NO for -shouldRemoveAfterServicingRequest:");
}


- (void)testHTTPMethods
{
    NSSet *HTTPMethods = UMKGeneratedSetWithElementCount(random() % 5 + 2, ^id{
        return [UMKRandomAlphanumericStringWithLength(7) uppercaseString];
    });

    NSSet *HTTPMethodsWithDuplicate = [HTTPMethods setByAddingObject:[[HTTPMethods anyObject] lowercaseString]];

    UMKPatternMatchingMockRequest *mockRequest = [[UMKPatternMatchingMockRequest alloc] initWithURLPattern:UMKRandomAlphanumericString()];
    mockRequest.HTTPMethods = HTTPMethodsWithDuplicate;

    NSSet *uppercaseActualHTTPMethods = [mockRequest.HTTPMethods valueForKey:@"uppercaseString"];
    XCTAssertEqualObjects(uppercaseActualHTTPMethods, HTTPMethods, @"HTTP methods is set incorrectly");
}


- (void)testMatchesURLRequest
{
    NSString *pattern = @"https://api.hostname.com/:resource/:resourceID/search";
    NSSet *HTTPMethods = UMKGeneratedSetWithElementCount(random() % 3 + 2, ^id{
        return UMKRandomHTTPMethod();
    });

    UMKPatternMatchingMockRequest *mockRequest = [[UMKPatternMatchingMockRequest alloc] initWithURLPattern:pattern];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:UMKRandomHTTPURL()];
    XCTAssertFalse([mockRequest matchesURLRequest:request], @"Matches request with incorrect URL");

    request.URL = [NSURL URLWithString:@"https://api.hostname.com/users/1234/search?a=b&c=d"];
    XCTAssertTrue([mockRequest matchesURLRequest:request], @"Does not match request with correct URL pattern");

    request.HTTPMethod = UMKRandomUnicodeStringWithLength(10);
    XCTAssertTrue([mockRequest matchesURLRequest:request], @"Does not match request with correct URL pattern and any HTTP method");

    mockRequest.HTTPMethods = HTTPMethods;
    XCTAssertFalse([mockRequest matchesURLRequest:request], @"Matches request with correct URL pattern and incorrect HTTP method");

    request.HTTPMethod = [HTTPMethods anyObject];
    XCTAssertTrue([mockRequest matchesURLRequest:request], @"Does not match request with correct URL pattern and HTTP method");

    mockRequest.requestMatchingBlock = ^BOOL(NSURLRequest *request, NSDictionary *parameters) {
        return NO;
    };

    XCTAssertFalse([mockRequest matchesURLRequest:request], @"Matches request with failing request-matching block");

    mockRequest.requestMatchingBlock = ^BOOL(NSURLRequest *request, NSDictionary *parameters) {
        NSDictionary *queryParameters = [NSDictionary umk_dictionaryWithURLEncodedParameterString:request.URL.query];
        return [parameters[@"resource"] isEqualToString:@"users"] && [queryParameters[@"a"] isEqualToString:@"b"];
    };

    XCTAssertTrue([mockRequest matchesURLRequest:request], @"Does not match request with passing request-matching block ");

    request.URL = [NSURL URLWithString:@"https://api.hostname.com/users/1234/search?a=c&b=d"];
    XCTAssertFalse([mockRequest matchesURLRequest:request], @"Matches request with failing request-matching block ");
}


- (void)testResponderForURLRequest
{
    NSString *pattern = @"http://api.hostname.com/accounts/:accountID/followers";

    UMKPatternMatchingMockRequest *mockRequest = [[UMKPatternMatchingMockRequest alloc] initWithURLPattern:pattern];

    mockRequest.responderGenerationBlock = ^id<UMKMockURLResponder>(NSURLRequest *request, NSDictionary *parameters) {
        NSMutableDictionary *responseJSON = [[request umk_JSONObjectFromHTTPBody] mutableCopy];
        responseJSON[@"following"] = @[ @([parameters[@"accountID"] integerValue]) ];
        UMKMockHTTPResponder *responder = [UMKMockHTTPResponder mockHTTPResponderWithStatusCode:200];
        [responder setBodyWithJSONObject:responseJSON];
        return responder;
    };

    NSNumber *accountID = UMKRandomUnsignedNumber();
    NSNumber *followerID = UMKRandomUnsignedNumber();
    NSString *URLString = [NSString stringWithFormat:@"http://api.hostname.com/accounts/%@/followers", accountID];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URLString]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:@{ @"accountID" : followerID } options:0 error:NULL];

    UMKMockHTTPResponder *responder = [mockRequest responderForURLRequest:request];
    NSDictionary *expectedResponseJSON = @{ @"accountID" : followerID, @"following" : @[ accountID ] };

    XCTAssertNotNil(responder, @"returns nil responder");
    XCTAssertEqualObjects([responder JSONObjectFromBody], expectedResponseJSON, @"JSON response is incorrect");
}

@end
