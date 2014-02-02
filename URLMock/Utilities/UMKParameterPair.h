//
//  UMKParameterPair.h
//  URLMock
//
//  Created by Prachi Gauriar on 1/7/2014.
//  Copyright (c) 2014 Prachi Gauriar, (c) 2013 AFNetworking (http://afnetworking.com/)
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
@property (nonatomic, strong) id key;

/*! The instance's value. */
@property (nonatomic, strong) id value;

/*!
 @abstract Returns a newly initialized UMKParameterPair instance with the specfied key and value.
 @param key The key for the new pair object.
 @param value The value for the new pair object.
 @result A newly initialized UMKParameterPair with the specified key and value.
 */
- (instancetype)initWithKey:(id)key value:(id)value;

/*! 
 @abstract Returns a URL encoded string representation of the receiver.
 @discussion Characters that can't be represented in a URL are percent-escaped the specified encoding.
 @param encoding The encoding to use when percent-escaping the receiver key and value.
 @result A URL encoded string representation of the receiver.
 */
- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)encoding;

@end
