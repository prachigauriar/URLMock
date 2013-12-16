//
//  UMKMockHTTPResponderTests.m
//  URLMock
//
//  Created by Prachi Gauriar on 12/15/2013.
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
#import <OCMock/OCMock.h>

#import "UMKRandomizedTestCase.h"
#import <URLMock/URLMock.h>
#import <URLMock/URLMockUtilities.h>


@interface UMKMockHTTPResponderTests : UMKRandomizedTestCase

@property (nonatomic, strong) UMKMockHTTPRequest *mockRequest;
@property (nonatomic, strong) id URLProtocolClient;
@property (nonatomic, strong) id URLProtocol;

- (void)testMockHTTPResponderWithError;

@end


@implementation UMKMockHTTPResponderTests

- (void)setUp
{
    [super setUp];
    
    NSURL *URL = UMKRandomHTTPURL();
    
    self.mockRequest = [[UMKMockHTTPRequest alloc] initWithHTTPMethod:UMKRandomAlphanumericString() URL:URL];
    self.URLProtocolClient = [OCMockObject mockForProtocol:@protocol(NSURLProtocolClient)];
    self.URLProtocol = [OCMockObject mockForClass:[NSURLProtocol class]];
    
    [[[self.URLProtocol stub] andReturn:[[NSURLRequest alloc] initWithURL:URL]] request];
    
}


- (void)testMockHTTPResponderWithError
{
    NSError *error = [NSError errorWithDomain:UMKRandomAlphanumericString()
                                         code:random()
                                     userInfo:UMKRandomDictionaryOfStringsWithElementCount(10)];
    
    UMKMockHTTPResponder *responder = [UMKMockHTTPResponder mockHTTPResponderWithError:error];
    XCTAssertTrue([responder conformsToProtocol:@protocol(UMKMockURLResponder)], @"Does not conform to UMKMockURLResponder protocol");
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
    self.mockRequest.responder = responder;
    
    // Can't predict value of response because NSHTTPURLResponse does not override isEqual:. We have to check this using
    // integration tests.
    [[self.URLProtocolClient expect] URLProtocol:self.URLProtocol didReceiveResponse:[OCMArg any] cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [[self.URLProtocolClient expect] URLProtocolDidFinishLoading:self.URLProtocol];
    [responder respondToMockRequest:self.mockRequest client:self.URLProtocolClient protocol:self.URLProtocol];
    XCTAssertNoThrow([self.URLProtocolClient verify], @"Mock protocol client did not receive the correct messages");
}

@end
