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

#pragma mark Private Types and Function Declarations

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


#pragma mark - Alphanumeric Strings

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
