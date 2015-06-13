//
//  UMKMockHTTPResponderTests.m
//  URLMock
//
//  Created by Prachi Gauriar on 12/15/2013.
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

#import <OCMock/OCMock.h>


@interface UMKMockHTTPResponderTests : UMKRandomizedTestCase

@property (nonatomic, strong) UMKMockHTTPRequest *mockRequest;
@property (nonatomic, strong) id URLProtocolClient;
@property (nonatomic, strong) id URLProtocol;

- (void)testMockHTTPResponderWithError;
- (void)testMockHTTPResponderWithStatusCode;
- (void)testMockHTTPResponderWithStatusCodeHeaders;
- (void)testMockHTTPResponderWithStatusCodeBody;
- (void)testMockHTTPResponderWithStatusCodeHeadersBody;
- (void)testMockHTTPResponderWithStatusCodeHeadersBodyChunkCountHintDelayBetweenChunks;

@end


@implementation UMKMockHTTPResponderTests

- (void)setUp
{
    [super setUp];
    
    NSURL *URL = UMKRandomHTTPURL();
    
    self.mockRequest = [[UMKMockHTTPRequest alloc] initWithHTTPMethod:UMKRandomAlphanumericString() URL:URL];
    self.URLProtocolClient = [OCMockObject mockForProtocol:@protocol(NSURLProtocolClient)];
    [self.URLProtocolClient setExpectationOrderMatters:YES];

    self.URLProtocol = [OCMockObject mockForClass:[NSURLProtocol class]];
    
    [[[self.URLProtocol stub] andReturn:[[NSURLRequest alloc] initWithURL:URL]] request];    
}


- (void)testMockHTTPResponderWithError
{
    NSError *error = UMKRandomError();
    
    UMKMockHTTPResponder *responder = [UMKMockHTTPResponder mockHTTPResponderWithError:error];

    XCTAssertTrue([responder conformsToProtocol:@protocol(UMKMockURLResponder)], @"Does not conform to UMKMockURLResponder protocol");
    XCTAssertNil(responder.body, @"Body is not nil");
    XCTAssertEqual(responder.headers.count, (NSUInteger)0, @"Headers is not empty");

    self.mockRequest.responder = responder;

    [[self.URLProtocolClient expect] URLProtocol:self.URLProtocol didFailWithError:error];
    [responder respondToMockRequest:self.mockRequest client:self.URLProtocolClient protocol:self.URLProtocol];
    XCTAssertNoThrow([self.URLProtocolClient verify], @"Mock protocol client did not receive URLProtocol:didFailWithError:");
}


- (void)testMockHTTPResponderWithStatusCode
{
    NSUInteger statusCode = random() % 500 + 100;

    UMKMockHTTPResponder *responder = [UMKMockHTTPResponder mockHTTPResponderWithStatusCode:statusCode];

    XCTAssertTrue([responder conformsToProtocol:@protocol(UMKMockURLResponder)], @"Does not conform to UMKMockURLResponder protocol");
    XCTAssertNil(responder.body, @"Body is not nil");
    XCTAssertEqual(responder.headers.count, (NSUInteger)0, @"Headers is not empty");

    self.mockRequest.responder = responder;
    
    // Can't check value of response because NSHTTPURLResponse does not override isEqual:. We have to check this using
    // integration tests. This makes these tests sort of dumb, but some is better than none, right?
    [[self.URLProtocolClient expect] URLProtocol:self.URLProtocol didReceiveResponse:[OCMArg any] cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [[self.URLProtocolClient expect] URLProtocolDidFinishLoading:self.URLProtocol];
    [responder respondToMockRequest:self.mockRequest client:self.URLProtocolClient protocol:self.URLProtocol];
    XCTAssertNoThrow([self.URLProtocolClient verify], @"Mock protocol client did not receive the correct messages");
}


- (void)testMockHTTPResponderWithStatusCodeHeaders
{
    NSUInteger statusCode = random() % 500 + 100;
    NSDictionary *headers = UMKRandomDictionaryOfStringsWithElementCount(10);

    UMKMockHTTPResponder *responder = [UMKMockHTTPResponder mockHTTPResponderWithStatusCode:statusCode headers:headers];

    XCTAssertTrue([responder conformsToProtocol:@protocol(UMKMockURLResponder)], @"Does not conform to UMKMockURLResponder protocol");
    XCTAssertNil(responder.body, @"Body is not nil");
    XCTAssertEqualObjects(headers, responder.headers, @"Headers is not set correctly");

    self.mockRequest.responder = responder;

    // Can't check value of response because NSHTTPURLResponse does not override isEqual:. We have to check this using
    // integration tests. This makes these tests sort of dumb, but some is better than none, right?
    [[self.URLProtocolClient expect] URLProtocol:self.URLProtocol didReceiveResponse:[OCMArg any] cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [[self.URLProtocolClient expect] URLProtocolDidFinishLoading:self.URLProtocol];
    [responder respondToMockRequest:self.mockRequest client:self.URLProtocolClient protocol:self.URLProtocol];
    XCTAssertNoThrow([self.URLProtocolClient verify], @"Mock protocol client did not receive the correct messages");
}


- (void)testMockHTTPResponderWithStatusCodeBody
{
    NSUInteger statusCode = random() % 500 + 100;
    NSData *body = [UMKRandomUnicodeStringWithLength(1024) dataUsingEncoding:NSUTF8StringEncoding];

    UMKMockHTTPResponder *responder = [UMKMockHTTPResponder mockHTTPResponderWithStatusCode:statusCode body:body];

    XCTAssertTrue([responder conformsToProtocol:@protocol(UMKMockURLResponder)], @"Does not conform to UMKMockURLResponder protocol");
    XCTAssertEqualObjects(responder.body, body, @"Body is not set correctly");
    XCTAssertEqual(responder.headers.count, (NSUInteger)0, @"Headers is not empty");

    self.mockRequest.responder = responder;

    // Can't check value of response because NSHTTPURLResponse does not override isEqual:. We have to check this using
    // integration tests. This makes these tests sort of dumb, but some is better than none, right?
    [[self.URLProtocolClient expect] URLProtocol:self.URLProtocol didReceiveResponse:[OCMArg any] cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [[self.URLProtocolClient expect] URLProtocol:self.URLProtocol didLoadData:body];
    [[self.URLProtocolClient expect] URLProtocolDidFinishLoading:self.URLProtocol];
    [responder respondToMockRequest:self.mockRequest client:self.URLProtocolClient protocol:self.URLProtocol];
    XCTAssertNoThrow([self.URLProtocolClient verify], @"Mock protocol client did not receive the correct messages");
}


- (void)testMockHTTPResponderWithStatusCodeHeadersBody
{
    NSUInteger statusCode = random() % 500 + 100;
    NSDictionary *headers = UMKRandomDictionaryOfStringsWithElementCount(10);
    NSData *body = [UMKRandomUnicodeStringWithLength(1024) dataUsingEncoding:NSUTF8StringEncoding];

    UMKMockHTTPResponder *responder = [UMKMockHTTPResponder mockHTTPResponderWithStatusCode:statusCode headers:headers body:body];

    XCTAssertTrue([responder conformsToProtocol:@protocol(UMKMockURLResponder)], @"Does not conform to UMKMockURLResponder protocol");
    XCTAssertEqualObjects(responder.body, body, @"Body is not set correctly");
    XCTAssertEqualObjects(headers, responder.headers, @"Headers is not set correctly");

    self.mockRequest.responder = responder;

    // Can't check value of response because NSHTTPURLResponse does not override isEqual:. We have to check this using
    // integration tests. This makes these tests sort of dumb, but some is better than none, right?
    [[self.URLProtocolClient expect] URLProtocol:self.URLProtocol didReceiveResponse:[OCMArg any] cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [[self.URLProtocolClient expect] URLProtocol:self.URLProtocol didLoadData:body];
    [[self.URLProtocolClient expect] URLProtocolDidFinishLoading:self.URLProtocol];
    [responder respondToMockRequest:self.mockRequest client:self.URLProtocolClient protocol:self.URLProtocol];
    XCTAssertNoThrow([self.URLProtocolClient verify], @"Mock protocol client did not receive the correct messages");
}


- (void)testMockHTTPResponderWithStatusCodeHeadersBodyChunkCountHintDelayBetweenChunks
{
    NSUInteger statusCode = random() % 500 + 100;
    NSDictionary *headers = UMKRandomDictionaryOfStringsWithElementCount(10);
    NSData *body = [UMKRandomUnicodeStringWithLength(1024) dataUsingEncoding:NSUTF8StringEncoding];

    UMKMockHTTPResponder *responder = [UMKMockHTTPResponder mockHTTPResponderWithStatusCode:statusCode headers:headers body:body];

    XCTAssertTrue([responder conformsToProtocol:@protocol(UMKMockURLResponder)], @"Does not conform to UMKMockURLResponder protocol");
    XCTAssertEqualObjects(responder.body, body, @"Body is not set correctly");
    XCTAssertEqualObjects(headers, responder.headers, @"Headers is not set correctly");

    self.mockRequest.responder = responder;

    // Can't check value of response because NSHTTPURLResponse does not override isEqual:. We have to check this using
    // integration tests. This makes these tests sort of dumb, but some is better than none, right?
    self.URLProtocolClient = [OCMockObject niceMockForProtocol:@protocol(NSURLProtocolClient)];
    [self.URLProtocolClient setExpectationOrderMatters:YES];

    [[self.URLProtocolClient expect] URLProtocol:self.URLProtocol didReceiveResponse:[OCMArg any] cacheStoragePolicy:NSURLCacheStorageNotAllowed];

    // This may be called multiple times, so we need to protect against that
    [[self.URLProtocolClient expect] URLProtocol:self.URLProtocol didLoadData:body];

    [[self.URLProtocolClient expect] URLProtocolDidFinishLoading:self.URLProtocol];
    [responder respondToMockRequest:self.mockRequest client:self.URLProtocolClient protocol:self.URLProtocol];
    XCTAssertNoThrow([self.URLProtocolClient verify], @"Mock protocol client did not receive the correct messages");
}



@end
