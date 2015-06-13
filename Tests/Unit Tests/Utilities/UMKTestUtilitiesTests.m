//
//  UMKTestUtilitiesTests.m
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


@interface UMKTestUtilitiesTest : UMKRandomizedTestCase

- (void)testRandomAlphanumericString;
- (void)testRandomAlphanumericStringWithLength;
- (void)testRandomUnicodeString;
- (void)testRandomUnicodeStringWithLength;
- (void)testRandomIdentifierString;
- (void)testRandomIdentifierStringWithLength;
- (void)testRandomBoolean;
- (void)testRandomUnsignedNumber;
- (void)testRandomUnsignedNumberInRange;
- (void)testRandomDictionaryOfStringsWithElementCount;
- (void)testRandomURLEncodedParametersDictionary;
- (void)testRandomJSONObject;
- (void)testRandomHTTPURL;
- (void)testRandomHTTPMethod;
- (void)testRandomError;
- (void)testWaitForCondition;

@end


@implementation UMKTestUtilitiesTest

+ (NSCharacterSet *)invertedAlphanumericCharacterSet
{
    static NSCharacterSet *invertedAlphanumericCharacterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSCharacterSet *alphanumerics = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"];
        invertedAlphanumericCharacterSet = [alphanumerics invertedSet];
    });
    
    return invertedAlphanumericCharacterSet;
}


+ (NSCharacterSet *)invertedRandomUnicodeCharacterSet
{
    static NSCharacterSet *invertedRandomUnicodeCharacterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableCharacterSet *randomUnicodeCharacters = [[NSMutableCharacterSet alloc] init];
        
        [randomUnicodeCharacters addCharactersInRange:NSMakeRange(0x0020, 0x007F - 0x0020)];  // Basic Latin
        [randomUnicodeCharacters addCharactersInRange:NSMakeRange(0x00A0, 0x00FF - 0x00A0)];  // Latin-1 Supplement
        [randomUnicodeCharacters addCharactersInRange:NSMakeRange(0x0370, 0x04FF - 0x0370)];  // Greek, Coptic, and Cyrillic
        [randomUnicodeCharacters addCharactersInRange:NSMakeRange(0x0590, 0x05FF - 0x0590)];  // Hebrew
        [randomUnicodeCharacters addCharactersInRange:NSMakeRange(0x0600, 0x06FF - 0x0600)];  // Arabic
        [randomUnicodeCharacters addCharactersInRange:NSMakeRange(0x0900, 0x097F - 0x0900)];  // Devanagari
        [randomUnicodeCharacters addCharactersInRange:NSMakeRange(0x3040, 0x30FF - 0x3040)];  // Hiragana and Katakana
        
        invertedRandomUnicodeCharacterSet = [randomUnicodeCharacters invertedSet];
    });
    
    return invertedRandomUnicodeCharacterSet;
}


+ (NSRegularExpression *)identifierRegularExpression
{
    static NSRegularExpression *identifierRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        identifierRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[A-Za-z_][A-Za-z0-9_]*$" options:0 error:NULL];
    });

    return identifierRegularExpression;
}


- (void)testRandomAlphanumericString
{
    NSCharacterSet *invertedAlphanumerics = [[self class] invertedAlphanumericCharacterSet];
    
    for (NSUInteger i = 0; i < UMKIterationCount; ++i) {
        NSString *randomString = UMKRandomAlphanumericString();
        XCTAssertNotNil(randomString, @"Randomly generated string is nil");
        XCTAssertTrue([randomString length] >= 1, @"Randomly generated string did not contain at least one character");
        XCTAssertTrue([randomString length] <= 128, @"Randomly generated string contains more than 128 characters");

        NSRange foundRange = [randomString rangeOfCharacterFromSet:invertedAlphanumerics];
        XCTAssertEqual(foundRange.location, (NSUInteger)NSNotFound, @"Randomly generated string contains non-alphanumeric characters");
    }
}


- (void)testRandomAlphanumericStringWithLength
{
    NSCharacterSet *invertedAlphanumerics = [[self class] invertedAlphanumericCharacterSet];

    for (NSUInteger i = 0; i < UMKIterationCount; ++i) {
        NSUInteger length = random() % 1024 + 1;

        NSString *randomString = UMKRandomAlphanumericStringWithLength(length);
        XCTAssertNotNil(randomString, @"Randomly generated string is nil");
        XCTAssertEqual([randomString length], length, @"Randomly generated string has incorrect length");

        NSRange foundRange = [randomString rangeOfCharacterFromSet:invertedAlphanumerics];
        XCTAssertEqual(foundRange.location, (NSUInteger)NSNotFound, @"Randomly generated string contains non-alphanumeric characters");
    }
}


- (void)testRandomUnicodeString
{
    NSCharacterSet *invertedRandomUnicodeCharacters = [[self class] invertedRandomUnicodeCharacterSet];
    
    for (NSUInteger i = 0; i < UMKIterationCount; ++i) {
        NSString *randomString = UMKRandomUnicodeString();
        XCTAssertNotNil(randomString, @"Randomly generated string is nil");
        XCTAssertTrue([randomString length] >= 1, @"Randomly generated string did not contain at least one character");
        XCTAssertTrue([randomString length] <= 128, @"Randomly generated string contains more than 128 characters");
        
        NSRange foundRange = [randomString rangeOfCharacterFromSet:invertedRandomUnicodeCharacters];
        XCTAssertEqual(foundRange.location, (NSUInteger)NSNotFound, @"Randomly generated string contains Unicode characters outside the specified range");
    }
}


- (void)testRandomUnicodeStringWithLength
{
    NSCharacterSet *invertedRandomUnicodeCharacters = [[self class] invertedRandomUnicodeCharacterSet];
    
    for (NSUInteger i = 0; i < UMKIterationCount; ++i) {
        NSUInteger length = random() % 1024 + 1;
        
        NSString *randomString = UMKRandomUnicodeStringWithLength(length);
        XCTAssertNotNil(randomString, @"Randomly generated string is nil");
        XCTAssertEqual([randomString length], length, @"Randomly generated string has incorrect length");
        
        NSRange foundRange = [randomString rangeOfCharacterFromSet:invertedRandomUnicodeCharacters];
        XCTAssertEqual(foundRange.location, (NSUInteger)NSNotFound, @"Randomly generated string contains Unicode characters outside the specified range");
    }
}


- (void)testRandomIdentifierString
{
    NSRegularExpression *identifierRegularExpression = [[self class] identifierRegularExpression];

    for (NSUInteger i = 0; i < UMKIterationCount; ++i) {
        NSString *randomString = UMKRandomIdentifierString();
        XCTAssertNotNil(randomString, @"Randomly generated string is nil");
        XCTAssertTrue([randomString length] >= 1, @"Randomly generated string did not contain at least one character");
        XCTAssertTrue([randomString length] <= 128, @"Randomly generated string contains more than 128 characters");

        NSUInteger matchCount = [identifierRegularExpression numberOfMatchesInString:randomString
                                                                             options:NSMatchingAnchored
                                                                               range:NSMakeRange(0, randomString.length)];
        XCTAssertEqual(matchCount, (NSUInteger)1, @"Randomly generated string does not match identifier regular expresion");
    }
}


- (void)testRandomIdentifierStringWithLength
{
    NSRegularExpression *identifierRegularExpression = [[self class] identifierRegularExpression];

    for (NSUInteger i = 0; i < UMKIterationCount; ++i) {
        NSUInteger length = random() % 1024 + 1;
 
        NSString *randomString = UMKRandomIdentifierStringWithLength(length);
        XCTAssertNotNil(randomString, @"Randomly generated string is nil");
        XCTAssertEqual([randomString length], length, @"Randomly generated string has incorrect length");

        NSUInteger matchCount = [identifierRegularExpression numberOfMatchesInString:randomString
                                                                             options:NSMatchingAnchored
                                                                               range:NSMakeRange(0, randomString.length)];
        XCTAssertEqual(matchCount, (NSUInteger)1, @"Randomly generated string does not match identifier regular expresion");
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


- (void)testRandomDictionaryOfStringsWithElementCount
{
    NSUInteger elementCount = random() % 100 + 1;
    NSDictionary *dictionary = UMKRandomDictionaryOfStringsWithElementCount(elementCount);
    
    XCTAssertEqual(dictionary.count, elementCount, @"Returned dictionary's element count is incorrect");
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        XCTAssertTrue([key isKindOfClass:[NSString class]], @"Key is not a string");
        XCTAssertTrue([value isKindOfClass:[NSString class]], @"Value is not a string");
    }];
}


- (void)assertObject:(id)object hasCorrectMaxNestingDepth:(NSUInteger)maxNestingDepth andMaxElementCountPerCollection:(NSUInteger)maxElementCountPerCollection
{
    // maxNestingDepth and maxElementCountPerCollection are respected
    NSUInteger depthCount = 0;
    
    // We use these as a way to do a breadth-first search without recursion. We don't move on to the objects in
    // nextDepthObjects until after currentDepthObjects is empty.
    NSMutableArray *currentDepthObjects = [NSMutableArray arrayWithObject:object];
    NSMutableArray *nextDepthObjects = [NSMutableArray array];
    
    id complexObject = nil;
    while ((complexObject = [currentDepthObjects lastObject])) {
        XCTAssertTrue([complexObject count] <= maxElementCountPerCollection, @"Collection has more elements than maxElementCountPerCollection");
        
        id element = nil;
        NSEnumerator *objectEnumerator = [complexObject objectEnumerator];
        while ((element = [objectEnumerator nextObject])) {
            if ([element isKindOfClass:[NSDictionary class]] || [element isKindOfClass:[NSArray class]] || [element isKindOfClass:[NSSet class]]) {
                [nextDepthObjects addObject:element];
            }
        }
        
        // If this was the last object in currentDepthObjects, move on to the objects in the next depth.
        // Also increment our depth count, which is the whole point of this.
        [currentDepthObjects removeLastObject];
        if ([currentDepthObjects count] == 0) {
            ++depthCount;
            currentDepthObjects = nextDepthObjects;
            nextDepthObjects = [NSMutableArray array];
        }
    }
    
    XCTAssertTrue(depthCount <= maxNestingDepth, @"Depth (%lu) exceeds max nesting depth (%lu)", (unsigned long)depthCount, (unsigned long)maxNestingDepth);

}


- (void)testRandomJSONObject
{
    for (NSUInteger i = 0; i < UMKIterationCount; ++i) {
        NSUInteger maxNestingDepth = random() % 10 + 1;
        NSUInteger maxElementCountPerCollection = random() % 10 + 1;

        // Valid JSON Object
        id JSONObject = UMKRandomJSONObject(maxNestingDepth, maxElementCountPerCollection);
        XCTAssertTrue([NSJSONSerialization isValidJSONObject:JSONObject], @"Returned object is not a valid JSON object");
        [self assertObject:JSONObject hasCorrectMaxNestingDepth:maxNestingDepth andMaxElementCountPerCollection:maxElementCountPerCollection];
    }
}


- (void)testRandomURLEncodedParametersDictionary
{
    for (NSUInteger i = 0; i < UMKIterationCount; ++i) {
        NSUInteger maxNestingDepth = random() % 10 + 1;
        NSUInteger maxElementCountPerCollection = random() % 10 + 1;
        
        // Valid URL encoded dictionary
        NSDictionary *dictionary = UMKRandomURLEncodedParameterDictionary(maxNestingDepth, maxElementCountPerCollection);
        XCTAssertTrue([dictionary umk_isValidURLEncodedParameterDictionary], @"Returned object is not a valid URL encoded parameter dictionary");
        [self assertObject:dictionary hasCorrectMaxNestingDepth:maxNestingDepth andMaxElementCountPerCollection:maxElementCountPerCollection];
    }
}


- (void)testRandomHTTPURL
{
    NSMutableSet *URLs = [[NSMutableSet alloc] initWithCapacity:UMKIterationCount];
    NSMutableSet *hosts = [[NSMutableSet alloc] initWithCapacity:UMKIterationCount];
    
    NSUInteger fragmentCount = 0;
    for (NSUInteger i = 0; i < UMKIterationCount; ++i) {
        NSURL *URL = UMKRandomHTTPURL();
        XCTAssertNotNil(URL, @"URL is nil");
        
        XCTAssertTrue([URL.scheme isEqualToString:@"http"] || [URL.scheme isEqualToString:@"https"], @"Non-HTTP scheme");

        // Test for 2 and 11 because / is always a component
        XCTAssertTrue(URL.pathComponents.count >= 2 && URL.pathComponents.count <= 11, @"Incorrect number of path components");

        if (URL.query.length > 0) {
            NSDictionary *parameters = [NSDictionary umk_dictionaryWithURLEncodedParameterString:URL.query];
            XCTAssertNotNil(parameters, @"parameters from query is nil");
            XCTAssertTrue([parameters umk_isValidURLEncodedParameterDictionary], @"parameters is not a valid URL encoded parameter dictionary");
            
            [self assertObject:parameters hasCorrectMaxNestingDepth:3 andMaxElementCountPerCollection:5];
        }
        
        if (URL.fragment.length > 0) {
            ++fragmentCount;
        }
        
        if (URL) {
            [URLs addObject:URL];
            [hosts addObject:URL.host];
        }
    }
    
    XCTAssertEqual(URLs.count, UMKIterationCount, @"Duplicate URL occurred within the iteration count.");
    XCTAssertEqual(hosts.count, UMKIterationCount, @"Duplicate hosts occurred within the iteration count.");
    XCTAssertNotEqual(fragmentCount, 0, @"No fragments within the iteration count");
    XCTAssertNotEqual(fragmentCount, UMKIterationCount, @"No non-fragments within the iteration count");
}


- (void)testRandomHTTPMethod
{
    NSSet *methods = [NSSet setWithObjects:@"DELETE", @"GET", @"HEAD", @"PATCH", @"POST", @"PUT", nil];
    NSMutableSet *returnedValues = [NSMutableSet setWithCapacity:methods.count];
    for (NSUInteger i = 0; i < UMKIterationCount; ++i) {
        [returnedValues addObject:UMKRandomHTTPMethod()];
    }
    
    XCTAssertEqualObjects(returnedValues, methods, @"Returned values don't match HTTP methods");
}


- (void)testRandomError
{
    NSMutableSet *domains = [[NSMutableSet alloc] initWithCapacity:UMKIterationCount];
    NSMutableSet *codes = [[NSMutableSet alloc] initWithCapacity:UMKIterationCount];

    for (NSUInteger i = 0; i < UMKIterationCount; ++i) {
        NSError *error = UMKRandomError();
        XCTAssertNotNil(error, @"error is nil");

        XCTAssertNotNil(error.domain, @"domain is nil");
        XCTAssertEqual(error.domain.length, (NSUInteger)10, @"domain length is incorrect");
        [domains addObject:error.domain];

        [codes addObject:@(error.code)];

        XCTAssertEqual(error.userInfo.count, (NSUInteger)5, @"Returned userInfo element count is incorrect");
        [error.userInfo enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
            XCTAssertTrue([key isKindOfClass:[NSString class]], @"Key is not a string");
            XCTAssertTrue([value isKindOfClass:[NSString class]], @"Value is not a string");
        }];
    }

    XCTAssertTrue(domains.count >= UMKIterationCount / 2, @"Not enough unique domains generated");
    XCTAssertTrue(codes.count >= UMKIterationCount / 2, @"Not enough unique codes generated");
}


- (void)testWaitForCondition
{
    // Note: this probably needs to be better tested
    NSTimeInterval timeout = 0.5;

    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    XCTAssertFalse(UMKWaitForCondition(timeout, ^BOOL{ return NO; }));
    NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
    XCTAssertTrue(end - start >= timeout, @"Elapsed time (%f) is less than timeout (%f)", end - start, timeout);

    start = [NSDate timeIntervalSinceReferenceDate];
    XCTAssertTrue(UMKWaitForCondition(timeout, ^BOOL{ return YES; }));
    end = [NSDate timeIntervalSinceReferenceDate];
    XCTAssertTrue(end - start < timeout, @"Elapsed time (%f) is greater than timeout (%f)", end - start, timeout);
}

@end
