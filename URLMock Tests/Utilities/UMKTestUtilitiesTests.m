//
//  UMKTestUtilitiesTests.m
//  URLMock
//
//  Created by Prachi Gauriar on 11/15/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <URLMock/UMKTestUtilities.h>

static const NSUInteger UMKIterationCount = 512;


@interface UMKTestUtilitiesTest : XCTestCase

- (void)testRandomAlphanumericString;
- (void)testRandomAlphanumericStringWithLength;
- (void)testRandomBoolean;
- (void)testRandomUnsignedNumber;
- (void)testRandomUnsignedNumberInRange;
- (void)testWaitForCondition;

@end


@implementation UMKTestUtilitiesTest

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


- (void)testRandomAlphanumericString
{
    NSCharacterSet *alphanumerics = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"];
    NSCharacterSet *nonAlphanumerics = [alphanumerics invertedSet];

    for (NSUInteger i = 0; i < UMKIterationCount; ++i) {
        NSString *randomString = UMKRandomAlphanumericString();
        XCTAssertNotNil(randomString, @"Randomly generated string was nil");
        XCTAssertTrue([randomString length] >= 1, @"Randomly generated string did not contain at least one character");
        XCTAssertTrue([randomString length] <= 128, @"Randomly generated string contained more than 128 characters");

        NSRange foundRange = [randomString rangeOfCharacterFromSet:nonAlphanumerics];
        XCTAssertEqual(foundRange.location, NSNotFound, @"Randomly generated string contained non-alphanumeric characters");
    }
}


- (void)testRandomAlphanumericStringWithLength
{
    NSCharacterSet *alphanumerics = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"];
    NSCharacterSet *nonAlphanumerics = [alphanumerics invertedSet];

    for (NSUInteger i = 0; i < UMKIterationCount; ++i) {
        NSUInteger length = random() % 1024 + 1;

        NSString *randomString = UMKRandomAlphanumericStringWithLength(length);
        XCTAssertNotNil(randomString, @"Randomly generated string was nil");
        XCTAssertTrue([randomString length] == length, @"Randomly generated string had incorrect length");

        NSRange foundRange = [randomString rangeOfCharacterFromSet:nonAlphanumerics];
        XCTAssertEqual(foundRange.location, NSNotFound, @"Randomly generated string contained non-alphanumeric characters");
    }
}


- (void)testRandomBoolean
{
    BOOL foundYes = NO;
    BOOL foundNo = NO;

    for (NSUInteger i = 0; i < UMKIterationCount; ++i) {
        BOOL boolean = UMKRandomBoolean();
        XCTAssertTrue(boolean == YES || boolean == NO, @"Randomly generated boolean is not YES or NO");
        foundYes = foundYes || boolean == YES;
        foundNo = foundNo || boolean == NO;
    }

    XCTAssertTrue(foundYes, @"No randomly generated booleans were YES");
    XCTAssertTrue(foundNo, @"No randomly generated booleans were NO");
}


- (void)testRandomUnsignedNumber
{
    const NSUInteger RANDOM_MAX = exp2(31) - 1;

    for (NSUInteger i = 0; i < UMKIterationCount; ++i) {
        NSNumber *number = UMKRandomUnsignedNumber();
        XCTAssertTrue([number unsignedIntegerValue] <= RANDOM_MAX, @"Randomly generated number is beyond 2**31 - 1");
    }
}


- (void)testRandomUnsignedNumberInRange
{
    const NSUInteger RANDOM_MAX = exp2(31) - 1;

    for (NSUInteger i = 0; i < UMKIterationCount; ++i) {
        NSUInteger location = random() % (RANDOM_MAX / 2);
        NSUInteger length = random() % (RANDOM_MAX / 2) + 1;

        NSNumber *number = UMKRandomUnsignedNumberInRange(NSMakeRange(location, length));
        XCTAssertTrue([number unsignedIntegerValue] >= location, @"Randomly generated number is less than the range minimum");
        XCTAssertTrue([number unsignedIntegerValue] <= location + length, @"Randomly generated number is greater than the range maximum");
    }
}


- (void)testWaitForCondition
{
    // Note: this probably needs to be better tested
    NSTimeInterval timeout = 0.5;

    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    XCTAssertFalse(UMKWaitForCondition(timeout, ^BOOL{ return NO; }));
    NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
    XCTAssertTrue(end - start >= timeout, @"Elapsed time (%f) was less than timeout (%f)", end - start, timeout);

    start = [NSDate timeIntervalSinceReferenceDate];
    XCTAssertTrue(UMKWaitForCondition(timeout, ^BOOL{ return YES; }));
    end = [NSDate timeIntervalSinceReferenceDate];
    XCTAssertTrue(end - start < timeout, @"Elapsed time (%f) was greater than timeout (%f)", end - start, timeout);
}



@end