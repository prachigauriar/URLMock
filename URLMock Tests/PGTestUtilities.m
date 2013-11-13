//
//  PGTestUtilities.m
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

#import "PGTestUtilities.h"

#pragma mark Functions

NSString *PGRandomAlphanumericString(void)
{
    return PGRandomAlphanumericStringWithLength(1 + random() % 128);
}


NSString *PGRandomAlphanumericStringWithLength(NSUInteger length)
{
    static const char *alphanumericCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    static const NSUInteger alphanumericCharacterCount = 62;

    char *randomCString = calloc(length, sizeof(char) + 1);
    for (NSUInteger i = 0; i < length; ++i) {
        randomCString[i] = alphanumericCharacters[random() % alphanumericCharacterCount];
    }
    
    return [NSString stringWithUTF8String:randomCString];
}


BOOL PGRandomBoolean()
{
    return random() & 01;
}


NSNumber *PGRandomNumber(void)
{
    return [NSNumber numberWithUnsignedInteger:random()];
}


NSNumber *PGRandomNumberInRange(NSRange range)
{
    return [NSNumber numberWithUnsignedInteger:(range.location + random() % range.length)];
}


#pragma mark - Tests

static const NSUInteger PGIterationCount = 512;

@implementation PGTestUtilitiesTest

- (void)setUp
{
    unsigned seed = (unsigned)random();
    NSLog(@"Using seed %du", seed);
    srandom(seed);
}


- (void)testRandomAlphanumericString
{
    NSCharacterSet *alphanumerics = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"];
    NSCharacterSet *nonAlphanumerics = [alphanumerics invertedSet];
    
    for (NSUInteger i = 0; i < PGIterationCount; ++i) {
        NSString *randomString = PGRandomAlphanumericString();
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

    for (NSUInteger i = 0; i < PGIterationCount; ++i) {
        NSUInteger length = random() % 1024;
        
        NSString *randomString = PGRandomAlphanumericStringWithLength(length);
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

    for (NSUInteger i = 0; i < 32; ++i) {
        BOOL boolean = PGRandomBoolean();
        XCTAssertTrue(boolean == YES || boolean == NO, @"Randomly generated boolean is not YES or NO");
        foundYes = foundYes || boolean == YES;
        foundNo = foundNo || boolean == NO;
    }
    
    XCTAssertTrue(foundYes, @"No randomly generated booleans were YES");
    XCTAssertTrue(foundNo, @"No randomly generated booleans were NO");
}


- (void)testRandomNumber
{
    const NSUInteger maxRandomNumber = exp2(31) - 1;
    
    for (NSUInteger i = 0; i < PGIterationCount; ++i) {
        NSNumber *number = PGRandomNumber();
        XCTAssertTrue([number unsignedIntegerValue] <= maxRandomNumber, @"Randomly generated number is beyond 2**31 - 1");
    }
}


- (void)testRandomNumberInRange
{
    for (NSUInteger i = 0; i < PGIterationCount; ++i) {
        NSUInteger location = random();
        NSUInteger length = random();
        
        NSNumber *number = PGRandomNumberInRange(NSMakeRange(location, length));
        XCTAssertTrue([number unsignedIntegerValue] >= location, @"Randomly generated number is less than the range minimum");
        XCTAssertTrue([number unsignedIntegerValue] <= location + length, @"Randomly generated number is greater than the range maximum");
    }
}

@end