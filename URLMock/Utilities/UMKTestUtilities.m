//
//  UMKTestUtilities.m
//  URLMock
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

#import <URLMock/UMKTestUtilities.h>
#import <URLMock/NSURL+UMKQueryParameters.h>

#pragma mark Private Type and Function Declarations

/*! 
 @abstract The function pointer type for random object generator functions.
 @param maxNestingDepth The maximum nesting depth for the object, if applicable.
 @param maxElementCountPerCollection The maximum element count per collection in the object, if applicable.
 @result A random object.
 */
typedef id (*UMKRandomObjectGeneratorFunction)(NSUInteger maxNestingDepth, NSUInteger maxElementCountPerCollection);


/*!
 @abstract Returns a random URL encoded parameter object.
 @discussion This object will either be a string, array, set, or dictionary.
 @param maxNestingDepth The maximum nesting depth for the object, if applicable.
 @param maxElementCountPerCollection The maximum element count per collection in the object, if applicable.
 @result A random URL encoded parameter object.
 */
static id UMKRandomURLEncodedParameterObject(NSUInteger maxNestingDepth, NSUInteger maxElementCountPerCollection);

/*!
 @abstract Returns a random URL encoded parameter array.
 @param maxElementCountPerCollection The maximum element count for the array.
 @result A random URL encoded parameter array.
 */
static id UMKRandomURLEncodedParameterArray(NSUInteger maxElementCountPerCollection);

/*!
 @abstract Returns a random URL encoded parameter set.
 @param maxElementCountPerCollection The maximum element count for the set.
 @result A random URL encoded parameter set.
 */
static id UMKRandomURLEncodedParameterSet(NSUInteger maxElementCountPerCollection);

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
 @result A random JSON array.
 */
static id UMKRandomJSONArray(NSUInteger maxNestingDepth, NSUInteger maxElementCountPerCollection);

/*!
 @abstract Returns a random JSON dictionary.
 @param maxNestingDepth The maximum nesting depth for the dictionary.
 @param maxElementCountPerCollection The maximum element count per collection in the dictionary.
 @result A random JSON dictionary.
 */
static id UMKRandomJSONDictionary(NSUInteger maxNestingDepth, NSUInteger maxElementCountPerCollection);

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
    static const NSUInteger kUMKAlphanumericCharacterCount = 62;

    char *randomCString = calloc(length + 1, sizeof(char));
    for (NSUInteger i = 0; i < length; ++i) {
        randomCString[i] = alphanumericCharacters[random() % kUMKAlphanumericCharacterCount];
    }

    NSString *randomString = [NSString stringWithUTF8String:randomCString];
    free(randomCString);
    return randomString;
}


NSString *UMKRandomUnicodeString(void)
{
    return UMKRandomUnicodeStringWithLength(1 + random() % 128);
}


NSString *UMKRandomUnicodeStringWithLength(NSUInteger length)
{
    NSCParameterAssert(length > 0);

    // These arrays give the first and last characters of the following character sets:
    //     Basic Latin: 0x0020-0x007E; Latin-1 Supplement: 0x00A0-0x00FF; Greek and Coptic: 0x0391-0x03A1;
    //     More Greek and Coptic: 0x03A3-0x03FF; Cyrillic: 0x0400-0x046F; Hebrew: 0x05D0-0x05EA;
    //     Arabic: 0x0621-0x063A; Devanagari: 0x0904-0x0939; Hiragana: 0x3041-0x3096; Katakana: 0x30A0-0x30F0
    static const NSUInteger kUMKCharacterSetCount = 10;
    static const unichar characterSetFirst[kUMKCharacterSetCount] = { 0x0020, 0x00A0, 0x0391, 0x03A3, 0x0400, 0x05D0, 0x0621, 0x0904, 0x3041, 0x30A0 };
    static const unichar characterSetLast[kUMKCharacterSetCount] = { 0x007E, 0x00FF, 0x03A1, 0x03FF, 0x046F, 0x05EA, 0x063A, 0x0939, 0x3096, 0x30F0 };
    
    unichar *randomUnicodeString = calloc(length, sizeof(unichar));
    for (NSUInteger i = 0; i < length; ++i) {
        NSUInteger characterSet = random() % kUMKCharacterSetCount;
        randomUnicodeString[i] = characterSetFirst[characterSet] + random() % (characterSetLast[characterSet] - characterSetFirst[characterSet]);
    }

    NSString *randomString = [NSString stringWithCharacters:randomUnicodeString length:length];
    free(randomUnicodeString);
    return randomString;
}


#pragma mark - Booleans and Numbers

BOOL UMKRandomBoolean()
{
    return random() & 01;
}


NSNumber *UMKRandomUnsignedNumber(void)
{
    return @(random());
}


NSNumber *UMKRandomUnsignedNumberInRange(NSRange range)
{
    NSCParameterAssert(range.length > 0);
    return @(range.location + random() % range.length);
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


static id UMKRandomURLEncodedParameterObject(NSUInteger maxNestingDepth, NSUInteger maxElementCountPerCollection)
{
    // Always choose a string if maxNestingDepth is 0
    NSUInteger typeChooser = maxNestingDepth == 0 ? 0 : random() % 3;
    
    switch (typeChooser) {
        case 0:
            return UMKRandomAlphanumericStringWithLength(random() % 10 + 1);
        case 1:
            return UMKRandomURLEncodedParameterArray(maxElementCountPerCollection);
        default:
            return UMKRandomURLEncodedParameterDictionary(maxNestingDepth, maxElementCountPerCollection);
    }
}


static id UMKRandomURLEncodedParameterArray(NSUInteger maxElementCountPerCollection)
{
    NSUInteger elementCount = random() % maxElementCountPerCollection + 1;
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:elementCount];
    
    for (NSUInteger i = 0; i < elementCount; ++i) {
        [array addObject:UMKRandomAlphanumericStringWithLength((random() % 10 + 1))];
    }
    
    return array;
}


static id UMKRandomURLEncodedParameterSet(NSUInteger maxElementCountPerCollection)
{
    // Never allow fewer than two objects in a set
    NSUInteger elementCount = 2 + random() % (maxElementCountPerCollection - 1);
    NSMutableSet *set = [[NSMutableSet alloc] initWithCapacity:elementCount];

    while ([set count] < elementCount) {
        [set addObject:UMKRandomAlphanumericStringWithLength((random() % 10 + 1))];
    }
    
    return set;
}


NSDictionary *UMKRandomURLEncodedParameterDictionary(NSUInteger maxNestingDepth, NSUInteger maxElementCountPerCollection)
{
    NSCParameterAssert(maxNestingDepth > 0);
    NSCParameterAssert(maxElementCountPerCollection > 0);
    
    NSUInteger elementCount = random() % maxElementCountPerCollection + 1;
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:elementCount];
    
    for (NSUInteger i = 0; i < elementCount; ++i) {
        NSString *key = UMKRandomAlphanumericStringWithLength(random() % 10 + 1);
        
        // We can only add a set if max nesting depth is 2 (once for the set, once its elements)
        if (maxElementCountPerCollection > 1 && maxNestingDepth > 2 && UMKRandomBoolean()) {
            dictionary[key] = UMKRandomURLEncodedParameterSet(maxElementCountPerCollection);
        } else {
            dictionary[key] = UMKRandomURLEncodedParameterObject(maxNestingDepth - 1, maxElementCountPerCollection);
        }        
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
            return UMKRandomUnicodeString();
        default:
            return UMKRandomUnsignedNumber();
    }
}


static id UMKRandomJSONArray(NSUInteger maxNestingDepth, NSUInteger maxElementCountPerCollection)
{
    NSUInteger elementCount = random() % maxElementCountPerCollection + 1;
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:elementCount];
    for (NSUInteger i = 0; i < elementCount; ++i) {
        [array addObject:UMKRecursiveRandomJSONObject(maxNestingDepth - 1, maxElementCountPerCollection, UMKRandomBoolean())];
    }
    
    return array;
}


static id UMKRandomJSONDictionary(NSUInteger maxNestingDepth, NSUInteger maxElementCountPerCollection)
{
    NSUInteger elementCount = random() % maxElementCountPerCollection + 1;
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:elementCount];
    for (NSUInteger i = 0; i < elementCount; ++i) {
        dictionary[UMKRandomUnicodeString()] = UMKRecursiveRandomJSONObject(maxNestingDepth - 1, maxElementCountPerCollection, UMKRandomBoolean());
    }
    
    return dictionary;
}


static id UMKRecursiveRandomJSONObject(NSUInteger maxNestingDepth, NSUInteger maxElementCountPerCollection, BOOL complexObject)
{
    if (maxNestingDepth == 0 || !complexObject) return UMKRandomSimpleJSONObject();
    UMKRandomObjectGeneratorFunction generatorFunction = UMKRandomBoolean() ? UMKRandomJSONArray : UMKRandomJSONDictionary;
    return generatorFunction(maxNestingDepth, maxElementCountPerCollection);
}


id UMKRandomJSONObject(NSUInteger maxNestingDepth, NSUInteger maxElementCountPerCollection)
{
    NSCParameterAssert(maxNestingDepth > 0);
    NSCParameterAssert(maxElementCountPerCollection > 0);
    return UMKRecursiveRandomJSONObject(maxNestingDepth, maxElementCountPerCollection, YES);
}


#pragma mark - HTTP Methods

NSString *UMKRandomHTTPMethod(void)
{
    static NSString * const methods[] = { @"DELETE", @"GET", @"HEAD", @"PATCH", @"POST", @"PUT" };
    return methods[random() % 6];
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
    NSDictionary *parameters = UMKRandomBoolean() ? UMKRandomURLEncodedParameterDictionary(random() % 3 + 1, random() % 5 + 1) : nil;
    
    // Fragment
    if (UMKRandomBoolean()) {
        [URLString appendFormat:@"#%@", UMKRandomAlphanumericStringWithLength(random() % 10 + 1)];
    }
    
    return [NSURL umk_URLWithString:URLString parameters:parameters];
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
