//
//  UMKMockHTTPRequestTests.m
//  URLMock
//
//  Created by Prachi Gauriar on 11/16/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <URLMock/URLMock.h>
#import <URLMock/URLMockUtilities.h>

@interface UMKMockHTTPRequestTests : XCTestCase

- (void)testInit;
- (void)testConvenienceFactoryMethods;

@end


@implementation UMKMockHTTPRequestTests

+ (void)setUp
{
    srandomdev();
}


- (void)setUp
{
    unsigned seed = (unsigned)random();
    NSLog(@"Using seed %d", seed);
    srandom(seed);
}


- (void)testInit
{
    NSString *HTTPMethod = UMKRandomAlphanumericStringWithLength(10);
    NSURL *URL = UMKRandomHTTPURL();
    
    XCTAssertThrows([[UMKMockHTTPRequest alloc] init], @"Does not raise an exception");
    XCTAssertThrows([[UMKMockHTTPRequest alloc] initWithHTTPMethod:nil URL:URL], @"Does not raise an exception when HTTP method is nil");
    XCTAssertThrows([[UMKMockHTTPRequest alloc] initWithHTTPMethod:HTTPMethod URL:nil], @"Does not raise an exception when HTTP method is nil");

    UMKMockHTTPRequest *request = [[UMKMockHTTPRequest alloc] initWithHTTPMethod:HTTPMethod URL:URL];
    XCTAssertNotNil(request, "Returns nil");
    XCTAssertEqualObjects(request.HTTPMethod, HTTPMethod, @"HTTP Method not set correctly");
    XCTAssertEqualObjects(request.URL, URL, @"URL not set correctly");
}


- (void)testConvenienceFactoryMethods
{
    NSURL *URL = UMKRandomHTTPURL();
    NSString *URLString = [URL description];

    for (NSString *method in @[ @"DELETE", @"GET", @"HEAD", @"PATCH", @"POST", @"PUT" ]) {
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"mockHTTP%@RequestWithURLString:", method.capitalizedString]);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        XCTAssertThrows([[UMKMockHTTPRequest class] performSelector:selector withObject:nil], @"Does not raise exception when URL string is nil");
        UMKMockHTTPRequest *request = [[UMKMockHTTPRequest class] performSelector:selector withObject:URLString];
#pragma clang diagnostic pop
        
        XCTAssertNotNil(request, @"Returns nil");
        XCTAssertEqual([request.HTTPMethod caseInsensitiveCompare:method], NSOrderedSame, @"HTTP method is not %@", method);
        XCTAssertEqualObjects(request.URL, URL, @"URL not set correctly");
    }
}

@end
