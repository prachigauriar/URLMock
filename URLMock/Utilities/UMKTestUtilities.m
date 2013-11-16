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
#import <URLMock/UMKURLEncodingUtilities.h>

#pragma mark Private Types and Function Declarations

/*!
 @abstract Returns a random Unicode character.
 @discussion The character may be in the Basic Latin, Latin-1 Supplement, Greek and Coptic, Cyrillic, Hebrew, Arabic, 
     Devanagari, Hiragana, or Katakana character sets.
 @result A random Unicde character.
 */
static unichar UMKRandomUnicodeCharacter(void);

/*! 
 @abstract The function pointer type for complex JSON object generator functions.
 @param maxNestingDepth The maximum nesting depth for the complex JSON object.
 @param maxElementCountPerCollection The maximum element count per collection in the complex JSON object.
 @param elementCount The number of elements in the generated JSON object.
 @result A complex JSON object.
 */
typedef id (*UMKRandomComplexJSONObjectGeneratorFunction)(NSUInteger maxNestingDepth, NSUInteger maxElementCountPerCollection, NSUInteger elementCount);

/*!
 @abstract Returns a random simple JSON object.
 @discussion Simple JSON objects are either NSStrings, NSNumbers, or NSNull.
 @result A simple JSON object.
 */
static id UMKRandomSimpleJSONObject(void);

/*!
 @abstract Returns a random JSON array.
 @param maxNestingDepth The maximum nesting depth for the array.
 @param maxElementCountPerCollection The maximum element count per collection in the array.
 @param elementCount The number of elements to create in the array.
 @result A random JSON array.
 */
static id UMKRandomJSONArray(NSUInteger maxNestingDepth, NSUInteger maxElementCountPerCollection, NSUInteger elementCount);

/*!
 @abstract Returns a random JSON dictionary.
 @param maxNestingDepth The maximum nesting depth for the dictionary.
 @param maxElementCountPerCollection The maximum element count per collection in the dictionary.
 @param elementCount The number of elements to create in the dictionary.
 @result A random JSON dictionary.
 */
static id UMKRandomJSONDictionary(NSUInteger maxNestingDepth, NSUInteger maxElementCountPerCollection, NSUInteger elementCount);

/*!
 @abstract Recursively builds a random JSON object.
 @param maxNestingDepth The maximum nesting depth for the JSON object.
 @param maxElementCountPerCollection The maximum element count per collection in the JSON object.
 @param complexObject Whether the returned object is a complex object, i.e., an array or dictionary.
 @result A random JSON object.
 */
static id UMKRecursiveRandomJSONObject(NSUInteger maxNestingDepth, NSUInteger maxElementCountPerCollection, BOOL complexObject);


#pragma mark - Strings

NSString *UMKRandomAlphanumericString(void)
{
    return UMKRandomAlphanumericStringWithLength(1 + random() % 128);
}


NSString *UMKRandomAlphanumericStringWithLength(NSUInteger length)
{
    NSCParameterAssert(length > 0);

    static const char *alphanumericCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    static const NSUInteger alphanumericCharacterCount = 62;

    char *randomCString = calloc(length + 1, sizeof(char));
    for (NSUInteger i = 0; i < length; ++i) {
        randomCString[i] = alphanumericCharacters[random() % alphanumericCharacterCount];
    }
    
    return [NSString stringWithUTF8String:randomCString];
}


static unichar UMKRandomUnicodeCharacter(void)
{
    // The Unicode ranges here are not meant to be complete. They were just good runs of contiguous code points
    // for the given character sets.
    unichar first, last;
    switch (random() % 10) {
        case 0:
            // Basic Latin: 0x0020-0x007E
            first = 0x0020; last = 0x007E; break;
        case 1:
            // Latin-1 Supplement: 0x00A0-0x00FF
            first = 0x00A0; last = 0x00FF; break;
        case 2:
            // Greek and Coptic: 0x0391-0x03A1
            first = 0x0391; last = 0x03A1; break;
        case 3:
            // More Greek and Coptic: 0x03A3-0x03FF
            first = 0x03A3; last = 0x03FF; break;
        case 4:
            // Cyrillic: 0x0400-0x046F
            first = 0x0400; last = 0x046F; break;
        case 5:
            // Hebrew: 0x05D0-0x05EA
            first = 0x05D0; last = 0x05EA; break;
        case 6:
            // Arabic: 0x0621-0x063A
            first = 0x0621; last = 0x063A; break;
        case 7:
            // Devanagari: 0x0904-0x0939
            first = 0x0904; last = 0x0939; break;
        case 8:
            // Hiragana: 0x3041-0x3096
            first = 0x3041; last = 0x3096; break;
        default:
            // Katakana: 0x30A0-0x30F0
            first = 0x30A0; last = 0x30F0; break;
    }
    
    return first + random() % (last - first);
}


NSString *UMKRandomUnicodeString(void)
{
    return UMKRandomUnicodeStringWithLength(1 + random() % 128);
}


NSString *UMKRandomUnicodeStringWithLength(NSUInteger length)
{
    NSCParameterAssert(length > 0);
    
    unichar *randomUnicodeString = calloc(length, sizeof(unichar));
    for (NSUInteger i = 0; i < length; ++i) {
        randomUnicodeString[i] = UMKRandomUnicodeCharacter();
    }

    return [NSString stringWithCharacters:randomUnicodeString length:length];
}


#pragma mark - Booleans and Numbers

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


#pragma mark - Dictionaries

NSDictionary *UMKRandomDictionaryOfStringsWithElementCount(NSUInteger count)
{
    NSCParameterAssert(count > 0);
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:count];
    for (NSUInteger i = 0; i < count; ++i) {
        dictionary[UMKRandomAlphanumericString()] = UMKRandomAlphanumericString();
    }
    
    return dictionary;
}


#pragma mark - JSON Objects

static id UMKRandomSimpleJSONObject(void)
{
    NSUInteger typeChooser = random() % 3;
    switch (typeChooser) {
        case 0:
            return [NSNull null];
        case 1:
            return UMKRandomAlphanumericString();
        default:
            return UMKRandomUnsignedNumber();
    }
}


static id UMKRandomJSONArray(NSUInteger maxNestingDepth, NSUInteger maxElementCountPerCollection, NSUInteger elementCount)
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:elementCount];
    for (NSUInteger i = 0; i < elementCount; ++i) {
        [array addObject:UMKRecursiveRandomJSONObject(maxNestingDepth - 1, maxElementCountPerCollection, UMKRandomBoolean())];
    }
    
    return array;
}


static id UMKRandomJSONDictionary(NSUInteger maxNestingDepth, NSUInteger maxElementCountPerCollection, NSUInteger elementCount)
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:elementCount];
    for (NSUInteger i = 0; i < elementCount; ++i) {
        dictionary[UMKRandomAlphanumericString()] = UMKRecursiveRandomJSONObject(maxNestingDepth - 1, maxElementCountPerCollection, UMKRandomBoolean());
    }
    
    return dictionary;
}


static id UMKRecursiveRandomJSONObject(NSUInteger maxNestingDepth, NSUInteger maxElementCountPerCollection, BOOL complexObject)
{
    if (maxNestingDepth == 0 || !complexObject) return UMKRandomSimpleJSONObject();
    UMKRandomComplexJSONObjectGeneratorFunction complexObjectFunction = UMKRandomBoolean() ? UMKRandomJSONArray : UMKRandomJSONDictionary;
    return complexObjectFunction(maxNestingDepth, maxElementCountPerCollection, random() % maxElementCountPerCollection + 1);
}


id UMKRandomJSONObject(NSUInteger maxNestingDepth, NSUInteger maxElementCountPerCollection)
{
    NSCParameterAssert(maxNestingDepth > 0);
    NSCParameterAssert(maxElementCountPerCollection > 0);
    return UMKRecursiveRandomJSONObject(maxNestingDepth, maxElementCountPerCollection, YES);
}


#pragma mark - URLs

NSURL *UMKRandomHTTPURL(void)
{
    NSMutableString *URLString = [NSMutableString stringWithFormat:@"%@://subdomain%@.domain%@.com", UMKRandomBoolean() ? @"http" : @"https",
                                                                   UMKRandomUnsignedNumber(), UMKRandomUnsignedNumber()];

    // Path components
    NSUInteger pathComponents = random() % 10 + 1;
    for (NSUInteger i = 0; i < pathComponents; ++i) {
        [URLString appendFormat:@"/%@", UMKRandomAlphanumericStringWithLength((random() % 10 + 1))];
    }
    
    // Parameters
    NSUInteger parameterCount = random() % 5;
    if (parameterCount > 0) {
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:parameterCount];
        for (NSUInteger i = 0; i < parameterCount; ++i) {
            parameters[UMKRandomAlphanumericStringWithLength(random() % 10 + 1)] = UMKRandomAlphanumericStringWithLength(random() % 10 + 1);
        }
        
        [URLString appendFormat:@"?%@", UMKURLEncodedStringForParameters(parameters)];
    }
 
    // Fragment
    if (UMKRandomBoolean()) {
        [URLString appendFormat:@"#%@", UMKRandomAlphanumericStringWithLength(random() % 10 + 1)];
    }
    
    return [NSURL URLWithString:URLString];
}



#pragma mark - Wait for Condition

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
