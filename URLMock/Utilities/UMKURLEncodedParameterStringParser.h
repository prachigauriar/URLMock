//
//  UMKURLEncodedParameterStringParser.h
//  URLMock
//
//  Created by Prachi Gauriar on 1/5/2014.
//  Copyright (c) 2014 Prachi Gauriar.
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
 UMKURLEncodedParameterStringParser objects parse URL encoded parameter strings.
 
 Below is a brief summary of how strings are parsed. {…} denotes a dictionary, […] denotes an array, and 
 <…> denotes a set.

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
@interface UMKURLEncodedParameterStringParser : NSObject

/*! The string the instance parses. */
@property (nonatomic, strong, readonly) NSString *string;

/*! The encoding that the instance's percent-escape sequences were encoded in. */
@property (nonatomic, assign, readonly) NSStringEncoding encoding;


/*!
 @abstract Initializes a new UMKURLEncodedParameterStringParser instance with the specified string and encoding.
 @param string The URL encoded parameter string to parse.
 @param encoding The encoding that the string used for percent-escape sequences.
 @result A newly initialized UMKURLEncodedParameterStringParser.
 */
- (instancetype)initWithString:(NSString *)string encoding:(NSStringEncoding)encoding;

/*!
 @abstract Parses the receiver's string and returns a dictionary of the resulting object.
 @discussion The resulting dictionary may contain nested strings, arrays, sets, and dictionaries. All dictionary
     keys, array values, and set values are strings. Sets never contain fewer than two items.
 @result The dictionary that results from parsing the receiver's string or nil if a parse error occurred.
 */
- (NSDictionary *)parse;

@end
