//
//  NSURLRequestUMKHTTPConvenienceTests.m
//  URLMock
//
//  Created by Prachi Gauriar on 6/29/2014.
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


@interface NSURLRequestUMKHTTPConvenienceTests : UMKRandomizedTestCase

- (void)testHTTPBodyData;
- (void)testJSONObjectFromHTTPBody;
- (void)testParametersFromURLEncodedHTTPBody;
- (void)testStringFromHTTPBodyMethods;
- (void)testHTTPHeadersAreEqualToHeaders;

@end


@implementation NSURLRequestUMKHTTPConvenienceTests

- (void)testHTTPBodyData
{
    NSData *bodyData = [UMKRandomAlphanumericString() dataUsingEncoding:NSUTF8StringEncoding];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:UMKRandomHTTPURL()];
    request.HTTPBody = bodyData;
    XCTAssertEqualObjects(request.umk_HTTPBodyData, bodyData, @"body data does not return HTTPBody when HTTPBodyStream is nil");

    bodyData = [UMKRandomAlphanumericString() dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBodyStream = [NSInputStream inputStreamWithData:bodyData];
    XCTAssertEqualObjects(request.umk_HTTPBodyData, bodyData, @"body data does not return HTTPBodyStream as data");
}


- (void)testJSONObjectFromHTTPBody
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:UMKRandomHTTPURL()];
    XCTAssertNil([request umk_JSONObjectFromHTTPBody], @"Does not return nil when body is nil");

    id JSONObject = UMKRandomJSONObject(random() % 10 + 1, random() % 10 + 1);
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:JSONObject options:0 error:NULL];
    XCTAssertEqualObjects([request umk_JSONObjectFromHTTPBody], JSONObject, @"Returns incorrect JSON body");

    JSONObject = UMKRandomJSONObject(random() % 10 + 1, random() % 10 + 1);
    request.HTTPBodyStream = [NSInputStream inputStreamWithData:[NSJSONSerialization dataWithJSONObject:JSONObject options:0 error:NULL]];
    XCTAssertEqualObjects([request umk_JSONObjectFromHTTPBody], JSONObject, @"Returns incorrect JSON body");
}


- (void)testParametersFromURLEncodedHTTPBody
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:UMKRandomHTTPURL()];
    XCTAssertNil([request umk_parametersFromURLEncodedHTTPBody], @"Does not return nil when body is nil");

    NSDictionary *parameters = UMKRandomDictionaryOfStringsWithElementCount(10);
    request.HTTPBody = [[parameters umk_URLEncodedParameterString] dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects([request umk_parametersFromURLEncodedHTTPBody], parameters, @"Returns incorrect parameters");

    parameters = UMKRandomDictionaryOfStringsWithElementCount(10);
    request.HTTPBodyStream = [NSInputStream inputStreamWithData:[[parameters umk_URLEncodedParameterString] dataUsingEncoding:NSUTF8StringEncoding]];
    XCTAssertEqualObjects([request umk_parametersFromURLEncodedHTTPBody], parameters, @"Returns incorrect parameters");
}


- (void)testStringFromHTTPBodyMethods
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:UMKRandomHTTPURL()];
    XCTAssertNil([request umk_stringFromHTTPBody], @"Does not return nil when body is nil");
    XCTAssertNil([request umk_stringFromHTTPBodyWithEncoding:NSUTF16BigEndianStringEncoding], @"Does not return nil when body is nil");

    NSString *bodyString = UMKRandomUnicodeString();
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects([request umk_stringFromHTTPBody], bodyString, @"Returns incorrect string");

    bodyString = UMKRandomUnicodeString();
    request.HTTPBodyStream = [NSInputStream inputStreamWithData:[bodyString dataUsingEncoding:NSUTF16BigEndianStringEncoding]];
    XCTAssertEqualObjects([request umk_stringFromHTTPBodyWithEncoding:NSUTF16BigEndianStringEncoding], bodyString, @"Returns incorrect string");
}


- (void)testHTTPHeadersAreEqualToHeaders
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    XCTAssertTrue([request umk_HTTPHeadersAreEqualToHeaders:nil], @"Headers are not equal");

    NSDictionary *headers = UMKRandomDictionaryOfStringsWithElementCount(12);
    [request setAllHTTPHeaderFields:headers];

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

    XCTAssertTrue([request umk_HTTPHeadersAreEqualToHeaders:headers], @"Headers are not equal");

    [request setValue:nil forHTTPHeaderField:[request.allHTTPHeaderFields.keyEnumerator nextObject]];
    XCTAssertFalse([request umk_HTTPHeadersAreEqualToHeaders:headers], @"Headers are equal when they shouldn't be");
    XCTAssertFalse([request umk_HTTPHeadersAreEqualToHeaders:nil], @"Headers are equal when they shouldn't be");
}

@end
