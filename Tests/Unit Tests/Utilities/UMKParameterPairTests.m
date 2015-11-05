//
//  UMKParameterPairTests.m
//  URLMock
//
//  Created by Andrew Hershberger on 11/2/15.
//  Copyright © 2015 Ticketmaster Entertainment, Inc. All rights reserved.
//

#import "UMKRandomizedTestCase.h"
#import <URLMock/UMKParameterPair.h>


@interface UMKParameterPairTests : UMKRandomizedTestCase
@end


@implementation UMKParameterPairTests

- (void)testInit
{
    NSString *key = UMKRandomUnicodeString();
    NSString *value = UMKRandomUnicodeString();

    UMKParameterPair *pair = [[UMKParameterPair alloc] initWithKey:key value:value];

    XCTAssertNotNil(pair, @"Returns nil");
    XCTAssertEqualObjects(pair.key, key, @"Key is not set correctly");
    XCTAssertEqualObjects(pair.value, value, @"Value is not set correctly");
}

- (void)testURLEncodedStringValueWithEncoding
{
    NSString *allowedValueCharacters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~";
    NSString *allowedKeyCharacters = [allowedValueCharacters stringByAppendingString:@"[]"];

    NSString *key = allowedKeyCharacters;
    id value = allowedValueCharacters;
    UMKParameterPair *pair = [[UMKParameterPair alloc] initWithKey:key value:value];
    NSString *expectedResult = [NSString stringWithFormat:@"%@=%@", key, value];
    XCTAssertEqualObjects([pair URLEncodedStringValue], expectedResult, @"Encoded string value is incorrect");

    key = allowedValueCharacters;
    value = nil;
    pair = [[UMKParameterPair alloc] initWithKey:key value:value];
    expectedResult = key;
    XCTAssertEqualObjects([pair URLEncodedStringValue], expectedResult, @"Encoded string value is incorrect");
    
    key = allowedValueCharacters;
    value = [NSNull null];
    pair = [[UMKParameterPair alloc] initWithKey:key value:value];
    expectedResult = key;
    XCTAssertEqualObjects([pair URLEncodedStringValue], expectedResult, @"Encoded string value is incorrect");

    key = UMKRandomUnicodeString();
    value = UMKRandomUnicodeString();
    pair = [[UMKParameterPair alloc] initWithKey:key value:value];
    NSCharacterSet *allowedKeyCharacterSet = [NSCharacterSet characterSetWithCharactersInString:allowedKeyCharacters];
    NSCharacterSet *allowedValueCharacterSet = [NSCharacterSet characterSetWithCharactersInString:allowedValueCharacters];
    expectedResult = [NSString stringWithFormat:@"%@=%@", [key stringByAddingPercentEncodingWithAllowedCharacters:allowedKeyCharacterSet], [value stringByAddingPercentEncodingWithAllowedCharacters:allowedValueCharacterSet]];

    XCTAssertEqualObjects([pair URLEncodedStringValue], expectedResult, @"Encoded string value is incorrect");

    key = allowedValueCharacters;
    value = nil;
}

- (void)testURLEncodingNonStringValues
{
    NSString *key = UMKRandomUnicodeString();
    id value = @1;

    UMKParameterPair *pair = [[UMKParameterPair alloc] initWithKey:key value:value];

    XCTAssertNoThrow([pair URLEncodedStringValue], @"-URLEncodedStringValue should not throw");
}

@end
