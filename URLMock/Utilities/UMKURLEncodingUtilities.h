//
//  UMKURLEncodingUtilities.h
//  URLMock
//
//  Created by Prachi Gauriar on 11/9/2013.
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

#import <Foundation/Foundation.h>

/*!
 @header UMKURLEncodingUtilities
 @abstract Defines utility functions for converting dictionaries into URL-encoding strings and vice versa.
 @note Most of this code was adapted or borrowed from AFNetworking.
 */


/*! @functiongroup Encoding parameters */

/*!
 @abstract Returns a URL-encoded string representation of the given parameters.
 @discussion The contents of the dictionary are intepreted as WWW form parameters. The parameter
     values in the resulting string are obtained by sending -description to each dictionary value
     and then percent-escaping the keys using UTF-8 as the string encoding. If a dictionary key has
     a value of NSNull, its value is omitted from the string.
 @param parameters The dictionary of parameters. Keys must be strings. May not be nil.
 @result A URL-encoded string representation of the parameters.
 */
extern NSString *UMKURLEncodedStringForParameters(NSDictionary *parameters);

/*!
 @abstract Returns a URL-encoded string representation of the given parameters.
 @discussion The contents of the dictionary are intepreted as WWW form parameters. The parameter
     values in the resulting string are obtained by sending -description to each dictionary value
     and then percent-escaping the keys using the specified string encoding. If a dictionary key has
     a value of NSNull, its value is omitted from the string.
 @param parameters The dictionary of parameters. Keys must be strings. May not be nil.
 @param encoding The string encoding to use when percent-escaping the string.
 @result A URL-encoded string representation of the parameters in the specified encoding.
 */
extern NSString *UMKURLEncodedStringForParametersUsingEncoding(NSDictionary *parameters, NSStringEncoding encoding);


/*! @functiongroup Decoding parameters */

/*!
 @abstract Returns a dictionary representation of the URL-encoded parameters string.
 @discussion Keys and values in the resulting dictionary are NSStrings unless a parameter does not 
     have a value. In this case, its value in the dictionary will be NSNull. For purposes of percent-
     unescaping, the string is interpreted in UTF-8.
 @param string The URL-encoded parameters string. May not be nil.
 @result A dictionary representation of the URL-encoded parameters string.
 */
extern NSDictionary *UMKDictionaryForURLEncodedParametersString(NSString *string);

/*!
 @abstract Returns a dictionary representation of the URL-encoded parameters string.
 @discussion Keys and values in the resulting dictionary are NSStrings unless a parameter does not
     have a value. In this case, its value in the dictionary will be NSNull. For purposes of percent-
     unescaping, the string is interpreted in the specified string encoding.
 @param string The URL-encoded parameters string. May not be nil.
 @param encoding The string encoding to use when percent-unescaping the string.
 @result A dictionary representation of the URL-encoded parameters string.
 */
extern NSDictionary *UMKDictionaryForURLEncodedParametersStringUsingEncoding(NSString *string, NSStringEncoding encoding);
