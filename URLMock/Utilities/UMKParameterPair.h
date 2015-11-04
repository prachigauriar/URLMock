//
//  UMKParameterPair.h
//  URLMock
//
//  Created by Prachi Gauriar on 1/7/2014.
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
 UMKParameterPair objects store a key-value pair for use with URL encoding/decoding APIs in URLMock.
 @note The basic design and some of the code here is adapted or borrowed from AFNetworking.
 */
@interface UMKParameterPair : NSObject

/*! The instance's key. */
@property (nonatomic, strong) NSString *key;

/*! The instance's value. */
@property (nonatomic, strong) id value;

/*!
 @abstract Returns a newly initialized UMKParameterPair instance with the specfied key and value.
 @param key The key for the new pair object.
 @param value The value for the new pair object.
 @result A newly initialized UMKParameterPair with the specified key and value.
 */
- (instancetype)initWithKey:(NSString *)key value:(id)value;

/*! 
 @abstract Returns a URL encoded string representation of the receiver.
 @discussion Deprecated. Use -URLEncodedStringValue instead.
 @param encoding This parameter is ignored.
 @result A URL encoded string representation of the receiver.
 */
- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)encoding DEPRECATED_ATTRIBUTE;

/*!
 @abstract Returns a URL encoded string representation of the receiver.
 @discussion RFC 3986 lists unreserved characters in section 2.3. All other characters in the key
     and value are percent encoded and the resulting strings are joined with the '=' character.
     One exception is that the characters '[' and ']' are also allowed in the key in order to
     support the encoding of arrays. If value is nil or NSNull the result is just the encoded key.
 @result A URL encoded string representation of the receiver.
 */
- (NSString *)URLEncodedStringValue;

@end
