//
//  UMKURLEncodedParameterStringParser.h
//  URLMock
//
//  Created by Prachi Gauriar on 1/5/2014.
//  Copyright (c) 2015 Ticketmaster Entertainment, Inc. All rights reserved. All rights reserved.
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
 
 Below is a brief summary of how strings are parsed. {…} denotes a dictionary and […] denotes an array.

     "A=a" yields { "A" : "a" }
     "A=a&B=b" yields { "A" : "a", "B" : "b" }
     "A[]=a" yields { "A" : [ "a" ] }
     "A[]=a&A[]=b" yields { "A" : [ "a", "b" ] }
     "A[B]=a&A[C]=b" yields { "A" : { "B" : "a", "C" : "b" } }

 Parameter string parsing is based on the Rack parse_nested_query implementation.
 */
@interface UMKURLEncodedParameterStringParser : NSObject

/*! The string the instance parses. */
@property (nonatomic, copy, readonly) NSString *string;

/*!
 Deprecated. UTF-8 is always used during parsing.
 */
@property (nonatomic, assign, readonly) NSStringEncoding encoding DEPRECATED_ATTRIBUTE;


/*!
 @abstract Initializes a new UMKURLEncodedParameterStringParser instance with the specified string.
 @param string The URL encoded parameter string to parse.
 @result A newly initialized UMKURLEncodedParameterStringParser.
 */
- (instancetype)initWithString:(NSString *)string;

/*!
 @abstract Deprecated. Use -initWithString: instead.
 @param string The URL encoded parameter string to parse.
 @param encoding Ignored.
 @result A newly initialized UMKURLEncodedParameterStringParser.
 */
- (instancetype)initWithString:(NSString *)string encoding:(NSStringEncoding)encoding DEPRECATED_ATTRIBUTE;

/*!
 @abstract Parses the receiver's string and returns a dictionary of the resulting object.
 @discussion The resulting dictionary may contain nested strings, arrays, sets, and dictionaries. All dictionary
     keys, array values, and set values are strings. Sets never contain fewer than two items.
 @result The dictionary that results from parsing the receiver's string or nil if a parse error occurred.
 */
- (NSDictionary *)parse;

@end
