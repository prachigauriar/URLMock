//
//  UMKTestUtilities.h
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

/*!
 @header UMKTestUtilities
 @abstract Defines utility classes, functions, and macros for use when creating unit tests.
 @discussion Most of the functionality is related to randomizing tests by creating random objects.
 */

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

/*!
 UMKRandomizedTestCases simply override +setUp to call srandomdev() and -setUp to generate and log a
 random seed value before calling srandom(). Subclasses that override +setUp or -setUp should invoke
 the superclass implementation.
 */
@interface UMKRandomizedTestCase : XCTestCase
@end


/*! @functiongroup Random strings */

/*!
 @abstract Returns a random string of alphanumeric characters.
 @discussion The length of the string is (randomly) between 1 and 128.
 @result A random string of alphanumeric characters.
 */
extern NSString *UMKRandomAlphanumericString(void);

/*!
 @abstract Returns a random string of alphanumeric characters of the specified length.
 @param length The length of the random string. Must be non-zero.
 @result A random string of alphanumeric characters of the specified length.
 */
extern NSString *UMKRandomAlphanumericStringWithLength(NSUInteger length);

/*!
 @abstract Returns a random string of Unicode characters.
 @discussion The length of the returned string is (randomly) between 1 and 128. It may contain characters
     from the Basic Latin, Latin-1 Supplement, Greek and Coptic, Cyrillic, Hebrew, Arabic, Devanagari,
     Hiragana, and Katakana character sets.
 @result A random string of Unicode characters.
 */
extern NSString *UMKRandomUnicodeString(void);

/*!
 @abstract Returns a random string of Unicode characters of the specified length.
 @discussion The returned string may contain characters from the Basic Latin, Latin-1 Supplement, Greek and
     Coptic, Cyrillic, Hebrew, Arabic, Devanagari, Hiragana, and Katakana character sets.
 @param length The length of the random string. Must be non-zero.
 @result A random string of Unicode characters of the specified length.
 */
extern NSString *UMKRandomUnicodeStringWithLength(NSUInteger length);


/*! @functiongroup Random booleans and numbers */

/*!
 @abstract Returns a random boolean value.
 @result A random boolean.
 */
extern BOOL UMKRandomBoolean(void);

/*!
 @abstract Returns a new NSNumber instance with a random unsigned integer value.
 @result A new NSNumber instance with a random unsigned integer value.
 */
extern NSNumber *UMKRandomUnsignedNumber(void);

/*!
 @abstract Returns a new NSNumber instance with a random unsigned integer value in the given range.
 @param range The range within which the random number should fall. The range length must be positive.
 @result A new NSNumber instance with a random unsigned integer value.
 */
extern NSNumber *UMKRandomUnsignedNumberInRange(NSRange range);


/*! @functiongroup Random dictionaries */

/*!
 @abstract Returns a new NSDictionary instance with the specified number of random string key-value pairs.
 @param count The number of entries in the newly created dictionary. Must be positive.
 @result A dictionary of random string key-value pairs.
 */
extern NSDictionary *UMKRandomDictionaryOfStringsWithElementCount(NSUInteger count);

/*!
 @abstract Returns a new random dictionary that can be safely converted to and from a URL encoded parameter string.
 @discussion Nested objects may be strings, arrays, sets, or dictionaries. All dictionary keys are strings. All
     sets have at least two elements. All arrays and sets contain only strings.
 @param maxNestingDepth The maximum nesting depth in the returned object. For example, a maximum nesting depth of 2
     means that it would be impossible to return a number in an array in a dictionary. Must be positive.
 @param maxElementCountPerCollection The maximum number of elements allowed in a given collection in the returned
     object. Must be positive.
 @result A new random dictionary that can be safely converted to and from a URL encoded parameter string.
 */
extern NSDictionary *UMKRandomURLEncodedParameterDictionary(NSUInteger maxNestingDepth, NSUInteger maxElementCountPerCollection);


/*! @functiongroup Random JSON objects */

/*!
 @abstract Returns a new random JSON object.
 @discussion The type of the object is randomly chosen. 
 @param maxNestingDepth The maximum nesting depth in the returned object. For example, a maximum nesting depth of 2
     means that it would be impossible to return a number in an array in a dictionary. Must be positive.
 @param maxElementCountPerCollection The maximum number of elements allowed in a given collection in the returned 
     object. Must be positive.
 @result A new random JSON object.
 */
extern id UMKRandomJSONObject(NSUInteger maxNestingDepth, NSUInteger maxElementCountPerCollection);


/*! @functiongroup Random HTTP methods and URLs */

/*!
 @abstract Randomly returns one of @"DELETE", @"GET", @"HEAD", @"PATCH", @"POST", and @"PUT".
 @result A random HTTP method.
 */
extern NSString *UMKRandomHTTPMethod(void);

/*!
 @abstract Returns a new random HTTP URL.
 @discussion The returned URL will either use the HTTP or HTTPS scheme, have between 1 and 10 path components (excluding
     '/'), and potentially a fragment. If the URL has a query string, it will be generated by converting the result of
     UMKRandomURLEncodedParameterDictionary with a maxNestingDepth between 1–3, and a maxElementCountPerCollection between
     1–5.
 @result A new random HTTP URL.
 */
extern NSURL *UMKRandomHTTPURL(void);


/*! @functiongroup Waiting for conditions */

/*!
 @abstract Waits no longer than the specified timeout interval for the given condition block to evaluate to YES.
 @discussion This method primarily exists as a helper for testing asynchronous operations. In this case, the condition
     block should return YES when the operation has completed.
 @param timeoutInterval The time interval to wait for the condition block to return true. May not be negative.
 @param condition A block that returns true when a given condition has been fulfilled.
 @result YES if the condition block returned YES before the timeout; NO otherwise.
 */
extern BOOL UMKWaitForCondition(NSTimeInterval timeoutInterval, BOOL (^condition)(void));

/*!
 @abstract XCTAsserts that the given expression evaluates to YES before the given timeout interval elapses.
 @param timeoutInterval An NSTimeInterval containing the amount of time to wait for the expression to evaluate to YES.
 @param expression The boolean expression to evaluate.
 @param format An NSString object that contains a printf-style string containing an error message describing the failure 
     condition and placeholders for the arguments.
 @param ... The arguments displayed in the format string.
 */
#define UMKAssertTrueBeforeTimeout(timeoutInterval, expression, format...) \
    XCTAssertTrue(UMKWaitForCondition((timeoutInterval), ^BOOL{ return (expression); }), ## format)
