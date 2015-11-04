//
//  NSDictionary+UMKURLEncoding.h
//  URLMock
//
//  Created by Prachi Gauriar on 1/5/2014.
//  Copyright (c) 2015 Ticketmaster Entertainment, Inc., (c) 2013 AFNetworking
//      (http://afnetworking.com/). All rights reserved.
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

#import <Foundation/Foundation.h>


/*!
 The UMKURLEncoding category of NSDictionary provides a methods for easily URL encoding and decoding dictionary
 objects.

 Below is a brief summary of how URL encoded parameter strings are parsed. {…} denotes a dictionary, […] denotes 
 an array, and <…> denotes a set.
 
     "A=a" yields { "A" : "a" }
     "A=a&B=b" yields { "A" : "a", "B" : "b" }
     "A=a&A=b" yields { "A" : < "a", "b"> }
     "A[]=a" yields { "A" : [ "a" ] }
     "A[]=a&A[]=b" yields { "A" : [ "a", "b" ] }
     "A[B]=a&A[C]=b" yields { "A" : { "B" : "a", "C" : "b" } }
     "A[B]=a&A[B]=b" yields { "A" : { "B" : < "a", "b" > } }
 
 Strings can only result in dictionaries that contain nested strings, arrays, sets, and dictionaries.
 All dictionary keys, array values, and set values are strings. Sets never contain fewer than two items.
 */
@interface NSDictionary (UMKURLEncoding)

/*!
 @abstract Returns a new dictionary by parsing the specified URL encoded parameter string.
 @discussion UTF-8 encoding is used to unescape the parameter string's percent sequences.
 @param string The URL encoded parameter string to parse.
 @result A new dictionary containing the objects specified in the URL encoded parameter string.
 */
+ (instancetype)umk_dictionaryWithURLEncodedParameterString:(NSString *)string;

/*!
 @abstract Deprecated. Use +umk_dictionaryWithURLEncodedParameterString instead.
 @param string The URL encoded parameter string to parse.
 @param encoding Ignored.
 @result A new dictionary containing the objects specified in the URL encoded parameter string.
 */
+ (instancetype)umk_dictionaryWithURLEncodedParameterString:(NSString *)string encoding:(NSStringEncoding)encoding DEPRECATED_ATTRIBUTE;

/*!
 @abstract Returns whether the receiver is a valid URL encoded parameter dictionary.
 @discussion A dictionary is considered valid if it meets the following criteria: all its keys are strings; each of its
     values is either a string, a set that contains only strings and has more than one element, an array that contains 
     only strings and has at least one element, or a valid URL encoded parameter dictionary.
 @result Whether the receiver is a valid URL encoded parameter dictionary.
 */
- (BOOL)umk_isValidURLEncodedParameterDictionary;

/*!
 @abstract Returns a URL encoded parameter string representation of the receiver.
 @result A URL encoded parameter string representation of the receiver.
 */
- (NSString *)umk_URLEncodedParameterString;

/*!
 @abstract Returns a URL encoded parameter string representation of the receiver.
 @discussion Deprecated. Use -umk_URLEncodedParameterString instead.
 @param encoding This parameter is ignored.
 @result A URL encoded parameter string representation of the receiver.
 */
- (NSString *)umk_URLEncodedParameterStringWithEncoding:(NSStringEncoding)encoding DEPRECATED_ATTRIBUTE;

@end
