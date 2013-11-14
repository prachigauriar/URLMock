//
//  UMKTestUtilities.m
//
//  Created by Prachi Gauriar on 5/29/2013.
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

#import "UMKTestUtilities.h"

#pragma mark Functions

NSString *UMKRandomAlphanumericString(void)
{
    return UMKRandomAlphanumericStringWithLength(1 + random() % 128);
}


NSString *UMKRandomAlphanumericStringWithLength(NSUInteger length)
{
    NSCParameterAssert(length > 0);

    static const char *alphanumericCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    static const NSUInteger alphanumericCharacterCount = 62;

    char *randomCString = calloc(length, sizeof(char) + 1);
    for (NSUInteger i = 0; i < length; ++i) {
        randomCString[i] = alphanumericCharacters[random() % alphanumericCharacterCount];
    }
    
    return [NSString stringWithUTF8String:randomCString];
}


BOOL UMKRandomBoolean()
{
    return random() & 01;
}


NSNumber *UMKRandomUnsignedNumber(void)
{
    return [NSNumber numberWithUnsignedInteger:random()];
}


NSNumber *UMKRandomUnsignedNumberInRange(NSRange range)
{
    NSCParameterAssert(range.length > 0);
    return [NSNumber numberWithUnsignedInteger:(range.location + random() % range.length)];
}


BOOL UMKWaitForCondition(NSTimeInterval timeoutInterval, BOOL (^condition)(void))
{
    NSCParameterAssert(timeoutInterval >= 0.0);
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];

    BOOL conditionResult = NO;
    while(!(conditionResult = condition()) && [NSDate timeIntervalSinceReferenceDate] - start <= timeoutInterval) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
    }

    return conditionResult;
}


#pragma mark - Tests

@interface UMKTestUtilitiesTest : XCTestCase

- (void)testRandomAlphanumericString;
- (void)testRandomAlphanumericStringWithLength;
- (void)testRandomBoolean;
- (void)testRandomUnsignedNumber;
- (void)testRandomUnsignedNumberInRange;
- (void)testWaitForCondition;

@end


static const NSUInteger UMKIterationCount = 512;

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