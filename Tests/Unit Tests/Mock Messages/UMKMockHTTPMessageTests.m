//
//  UMKMockHTTPMessageTests.m
//  URLMock
//
//  Created by Prachi Gauriar on 11/15/2013.
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


@interface UMKMockHTTPMessageTests : UMKRandomizedTestCase

@property (nonatomic, strong) UMKMockHTTPMessage *message;

- (void)testInit;

- (void)testHeadersAccessors;
- (void)testHeadersAreEqualToHeadersOfRequest;

- (void)testBodyAccessors;
- (void)testJSONObjectBodyAccessors;
- (void)testParameterBodyAccessors;
- (void)testStringBodyAccessors;

@end


@implementation UMKMockHTTPMessageTests

- (void)setUp
{
    [super setUp];
    self.message = [[UMKMockHTTPMessage alloc] init];
}


- (void)testInit
{
    XCTAssertNotNil(self.message, @"Could not -init message");
    XCTAssertNil(self.message.body, @"Body is not initially nil");
    XCTAssertNotNil(self.message.headers, @"Headers is initially nil");
    XCTAssertEqual(self.message.headers.count, (NSUInteger)0, @"Headers is not initially empty");
}


#pragma mark - Headers

- (void)testHeadersAccessors
{
    // Getting and setting headers as a dictionary
    NSDictionary *headers = UMKRandomDictionaryOfStringsWithElementCount(12);
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

    
    // Setting nil keys or values
    XCTAssertThrowsSpecificNamed([self.message setValue:nil forHeaderField:UMKRandomAlphanumericString()], NSException,
                                 NSInvalidArgumentException, @"Does not throw when given nil value");
    XCTAssertThrowsSpecificNamed([self.message setValue:UMKRandomAlphanumericString() forHeaderField:nil], NSException,
                                 NSInvalidArgumentException, @"Does not throw when given nil field");

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
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    XCTAssertTrue([self.message headersAreEqualToHeadersOfRequest:request], @"Headers are not equal");
    
    NSDictionary *headers = UMKRandomDictionaryOfStringsWithElementCount(12);
    self.message.headers = headers;

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

- (void)testBodyAccessors
{
    NSData *data = [UMKRandomAlphanumericStringWithLength(1024) dataUsingEncoding:NSUTF8StringEncoding];
    self.message.body = data;
    XCTAssertEqualObjects(self.message.body, data, @"Body is not set correctly");

    self.message.body = nil;
    XCTAssertNil(self.message.body, @"Body is not set to nil");
}


- (void)testJSONObjectBodyAccessors
{
    XCTAssertNil([self.message JSONObjectFromBody], @"Does not return nil JSON body when body is nil");
    XCTAssertThrowsSpecificNamed([self.message setBodyWithJSONObject:[NSNull null]], NSException, NSInvalidArgumentException,
                                 @"Set does not throw exception with invalid JSON");
    
    NSString *contentType = UMKRandomAlphanumericStringWithLength(8);
    [self.message setValue:contentType forHeaderField:kUMKMockHTTPMessageContentTypeHeaderField];
    
    id JSONObject = UMKRandomJSONObject(random() % 10 + 1, random() % 10 + 1);
    [self.message setBodyWithJSONObject:JSONObject];

    id manuallyDecodedBody = [NSJSONSerialization JSONObjectWithData:self.message.body options:0 error:NULL];
    XCTAssertEqualObjects([self.message JSONObjectFromBody], JSONObject, @"Did not set JSON body correctly");
    XCTAssertEqualObjects([self.message JSONObjectFromBody], manuallyDecodedBody, @"Did not set JSON body correctly");
    XCTAssertEqualObjects([self.message valueForHeaderField:kUMKMockHTTPMessageContentTypeHeaderField], contentType, @"Content-Type header value was overwritten");
    
    [self.message removeValueForHeaderField:kUMKMockHTTPMessageContentTypeHeaderField];
    [self.message setBodyWithJSONObject:JSONObject];
    XCTAssertEqualObjects([self.message JSONObjectFromBody], JSONObject, @"Did not set JSON body correctly");
    XCTAssertEqualObjects([self.message valueForHeaderField:kUMKMockHTTPMessageContentTypeHeaderField], kUMKMockHTTPMessageUTF8JSONContentTypeHeaderValue,
                          @"Content-Type header value was not set correctly");
    
}


- (void)testParameterBodyAccessors
{
    XCTAssertNil([self.message parametersFromURLEncodedBody], @"Does not return nil parameters when body is nil");

    NSString *contentType = UMKRandomAlphanumericStringWithLength(8);
    [self.message setValue:contentType forHeaderField:kUMKMockHTTPMessageContentTypeHeaderField];

    NSDictionary *parameters = UMKRandomDictionaryOfStringsWithElementCount(10);
    [self.message setBodyByURLEncodingParameters:parameters];

    NSString *bodyString = [[NSString alloc] initWithData:self.message.body encoding:NSUTF8StringEncoding];
    NSDictionary *manuallyDecodedBody = [NSDictionary umk_dictionaryWithURLEncodedParameterString:bodyString];
    XCTAssertEqualObjects([self.message parametersFromURLEncodedBody], parameters, @"Did not set body correctly");
    XCTAssertEqualObjects([self.message parametersFromURLEncodedBody], manuallyDecodedBody, @"Did not set body correctly");
    XCTAssertEqualObjects([self.message valueForHeaderField:kUMKMockHTTPMessageContentTypeHeaderField], contentType, @"Content-Type header value was overwritten");

    [self.message removeValueForHeaderField:kUMKMockHTTPMessageContentTypeHeaderField];
    [self.message setBodyByURLEncodingParameters:parameters];
    XCTAssertEqualObjects([self.message parametersFromURLEncodedBody], parameters, @"Did not set body correctly");
    XCTAssertEqualObjects([self.message valueForHeaderField:kUMKMockHTTPMessageContentTypeHeaderField], kUMKMockHTTPMessageUTF8WWWFormURLEncodedContentTypeHeaderValue,
                          @"Content-Type header value was not set correctly");
}


- (void)testStringBodyAccessors
{
    NSDictionary *beforeHeaders = self.message.headers;
    NSString *bodyString = UMKRandomUnicodeString();
    [self.message setBodyWithString:bodyString];
    XCTAssertEqualObjects(self.message.body, [bodyString dataUsingEncoding:NSUTF8StringEncoding], @"Body string was not set correctly");
    XCTAssertEqualObjects(self.message.headers, beforeHeaders, @"Headers changed after setting body string");

    [self.message setBodyWithString:bodyString encoding:NSUTF16BigEndianStringEncoding];
    XCTAssertEqualObjects(self.message.body, [bodyString dataUsingEncoding:NSUTF16BigEndianStringEncoding], @"Body string was not set correctly");
    XCTAssertEqualObjects(self.message.headers, beforeHeaders, @"Headers changed after setting body string");
}

@end
