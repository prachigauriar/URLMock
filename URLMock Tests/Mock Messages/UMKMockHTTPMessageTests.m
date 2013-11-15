//
//  UMKMockHTTPMessageTests.m
//  URLMock
//
//  Created by Prachi Gauriar on 11/15/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <URLMock/URLMock.h>
#import <URLMock/URLMockUtilities.h>

@interface UMKMockHTTPMessageTests : XCTestCase

@property (strong, nonatomic) UMKMockHTTPMessage *message;

- (void)testInit;

- (void)testHeadersAccessors;
- (void)testHeadersAreEqualToHeadersOfRequest;

- (void)testBodyAccessors;
- (void)testJSONObjectBodyAccessors;
- (void)testStringBodyAccessors;

@end


@implementation UMKMockHTTPMessageTests

- (void)setUp
{
    self.message = [[UMKMockHTTPMessage alloc] init];
}


- (NSDictionary *)randomDictionaryOfStringsWithMinimumCount:(NSUInteger)minimumCount
{
    const NSUInteger MAX_KEY_COUNT = 32;

    NSUInteger keyValueCount = random() % (MAX_KEY_COUNT - minimumCount) + minimumCount;
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:keyValueCount];

    for (NSUInteger i = 0; i < keyValueCount; ++i) {
        dictionary[UMKRandomAlphanumericString()] = UMKRandomAlphanumericString();
    }

    return dictionary;
}


- (void)testInit
{
    XCTAssertNotNil(self.message, @"Could not -init message");
    XCTAssertNil(self.message.body, @"Body is not initially nil");
    XCTAssertNotNil(self.message.headers, @"Headers is not initially nil");
}


#pragma mark - Headers

- (void)testHeadersAccessors
{
    // Getting and setting headers as a dictionary
    NSDictionary *headers = [self randomDictionaryOfStringsWithMinimumCount:12];
    self.message.headers = headers;
    XCTAssertEqualObjects(self.message.headers, headers, @"Headers not set correctly");

    // Getting nil and unset headers
    XCTAssertNil([self.message valueForHeaderField:nil], @"Non-nil header value for nil field");
    XCTAssertNil([self.message valueForHeaderField:UMKRandomAlphanumericString()], @"Non-nil header value for unset field");

    // Case-insensitivity for getting header values
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *field, NSString *value, BOOL *stop) {
        XCTAssertEqualObjects([self.message valueForHeaderField:field], value, @"Incorrect header value for exact field");
        XCTAssertEqualObjects([self.message valueForHeaderField:field.lowercaseString], value, @"Incorrect header value for lowercase field");
        XCTAssertEqualObjects([self.message valueForHeaderField:field.uppercaseString], value, @"Incorrect header value for uppercase field");
        XCTAssertEqualObjects([self.message valueForHeaderField:field.capitalizedString], value, @"Incorrect header value for capitalized field");
    }];


    XCTAssertThrows([self.message setValue:nil forHeaderField:UMKRandomAlphanumericString()], @"Does not throw when given nil value");
    XCTAssertThrows([self.message setValue:UMKRandomAlphanumericString() forHeaderField:nil], @"Does not throw when given nil field");

    // Case-insensitivity for setting field values
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *field, NSString *value, BOOL *stop) {
        NSString *randomValue = UMKRandomAlphanumericString();
        [self.message setValue:randomValue forHeaderField:field];
        XCTAssertEqualObjects([self.message valueForHeaderField:field], randomValue, @"Incorrect header value set for exact field");

        randomValue = UMKRandomAlphanumericString();
        [self.message setValue:randomValue forHeaderField:field.lowercaseString];
        XCTAssertEqualObjects([self.message valueForHeaderField:field], randomValue, @"Incorrect header value set for lowercase field");

        randomValue = UMKRandomAlphanumericString();
        [self.message setValue:randomValue forHeaderField:field.uppercaseString];
        XCTAssertEqualObjects([self.message valueForHeaderField:field], randomValue, @"Incorrect header value set for uppercase field");

        randomValue = UMKRandomAlphanumericString();
        [self.message setValue:randomValue forHeaderField:field.capitalizedString];
        XCTAssertEqualObjects([self.message valueForHeaderField:field], randomValue, @"Incorrect header value set for capitalized field");
    }];

    NSDictionary *before = self.message.headers;
    [self.message removeValueForHeaderField:UMKRandomAlphanumericString()];
    XCTAssertEqualObjects(self.message.headers, before, @"Removal of unset key changed headers");

    // Case-insensitivity for removing field values
    NSUInteger i = 0;
    for (NSString *field in self.message.headers) {
        switch (i++ % 4) {
            case 0:
                [self.message removeValueForHeaderField:field];
                break;
            case 1:
                [self.message removeValueForHeaderField:field.lowercaseString];
                break;
            case 2:
                [self.message removeValueForHeaderField:field.uppercaseString];
                break;
            case 3:
                [self.message removeValueForHeaderField:field.capitalizedString];
                break;
        }

        XCTAssertNil([self.message valueForHeaderField:field], @"Field value was not removed");
    }
}


- (void)testHeadersAreEqualToHeadersOfRequest
{
    NSDictionary *headers = [self randomDictionaryOfStringsWithMinimumCount:12];
    self.message.headers = headers;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

    NSUInteger i = 0;
    for (NSString *field in headers) {
        switch (i++ % 4) {
            case 0:
                [request setValue:headers[field] forHTTPHeaderField:field];
                break;
            case 1:
                [request setValue:headers[field] forHTTPHeaderField:field.lowercaseString];
                break;
            case 2:
                [request setValue:headers[field] forHTTPHeaderField:field.uppercaseString];
                break;
            case 3:
                [request setValue:headers[field] forHTTPHeaderField:field.capitalizedString];
                break;
        }
    }

    XCTAssertTrue([self.message headersAreEqualToHeadersOfRequest:request], @"Headers are not equal");
    XCTAssertFalse([self.message headersAreEqualToHeadersOfRequest:[[NSURLRequest alloc] init]], @"Headers are equal when they should not be.");
    XCTAssertFalse([self.message headersAreEqualToHeadersOfRequest:nil], @"Headers are equal to those of a nil request.");

    [self.message removeValueForHeaderField:[self.message.headers.keyEnumerator nextObject]];
    XCTAssertFalse([self.message headersAreEqualToHeadersOfRequest:request], @"Headers are equal when they shouldn't be");

    self.message.headers = nil;
    XCTAssertFalse([self.message headersAreEqualToHeadersOfRequest:nil], @"Headers are equal to those of a nil request");
}


#pragma mark - Body


@end
