//
//  UMOMockHTTPMessage.h
//  URLMock
//
//  Created by Prachi Gauriar on 11/9/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
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

#pragma mark Constants

/*! The HTTP header field for the Accepts header. */
extern NSString *const kUMOMockHTTPMessageAcceptsHeaderField;

/*! The HTTP header field for the Content-Type header. */
extern NSString *const kUMOMockHTTPMessageContentTypeHeaderField;

/*! The HTTP header field for the Cookie header. */
extern NSString *const kUMOMockHTTPMessageCookieHeaderField;

/*! The HTTP header field for the Set-Cookie header. */
extern NSString *const kUMOMockHTTPMessageSetCookieHeaderField;

/*! The HTTP header value for the JSON content type. */
extern NSString *const kUMOMockHTTPMessageJSONContentTypeHeaderValue;

/*! The HTTP header value for the UTF8-encoded JSON content type. */
extern NSString *const kUMOMockHTTPMessageUTF8JSONContentTypeHeaderValue;

/*! The HTTP header value for the WWW Form URL-Encoded content type. */
extern NSString *const kUMOMockHTTPMessageWWWFormURLEncodedContentTypeHeaderValue;

/*! The HTTP header value for the UTF8-encoded WWW Form URL-Encoded content type. */
extern NSString *const kUMOMockHTTPMessageUTF8WWWFormURLEncodedContentTypeHeaderValue;


#pragma mark -

/*!
 UMOMockHTTPMessage is an abstract class that collects common data and behavior for mock HTTP requests and responses.
 Each UMOMockHTTPMessage has a body and headers and methods to access and modify them.
 */
@interface UMOMockHTTPMessage : NSObject {
@protected
    NSMutableDictionary *_headers;
}

/*! The instance's body. */
@property (copy, nonatomic) NSData *body;

/*! The instance's HTTP headers. */
@property (copy, nonatomic) NSDictionary *headers;

/*!
 @abstract Returns whether the specified request's headers are equal to the receiver's.
 @discussion The receiver and the request have equal headers if they have the same number of them, their header fields
     are the same (case-insensitively), and the header values for those fields identical.
 @param request The request whose headers are being compared to the receiver's.
 @result Whether the receiver's and request's headers are equal.
 */
- (BOOL)headersAreEqualToHeadersOfRequest:(NSURLRequest *)request;

/*!
 @abstract Sets the receiver's header value for the specified header field.
 @param value The value to set for the header field. May not be nil.
 @param field The header field for which to set the value. May not be nil.
 */
- (void)setValue:(NSString *)value forHeaderField:(NSString *)field;

/*!
 @abstract Removes the receiver's header value for the specified header field.
 @param field The header field whose value should be removed.
 */
- (void)removeValueForHeaderField:(NSString *)field;


/*!
 @abstract Returns the receiver's body as a JSON object.
 @result The receiver's body as a JSON object, or nil if the receiver's body does not contain valid JSON data.
 */
- (id)JSONObjectFromBody;

/*!
 @abstract Sets the receiver's body to a serialized form of the specified JSON object.
 @discussion If the receiver does not already have a value for the Content-type header field, sets the value of that 
     header to "application/json; charset=utf-8".
 @param JSONObject The JSON object to serialize and set as the receiver's body.
 @throws NSInvalidArgumentException if JSONObject is not a valid JSON object.
 */
- (void)setBodyWithJSONObject:(id)JSONObject;


/*!
 @abstract Returns the receiver's body as a UTF-8-encoded string.
 @result The receiver's body as a UTF-8 encoded string.
 */
- (NSString *)stringFromBody;

/*!
 @abstract Sets the receiver's body as a UTF-8 encoded version of the specified string.
 @param string The string to use for the receiver's body.
 */
- (void)setBodyWithString:(NSString *)string;

/*!
 @abstract Returns the receiver's body as a string in the specified encoding.
 @result The receiver's body as a string in the specified encoding.
 */
- (NSString *)stringFromBodyWithEncoding:(NSStringEncoding)encoding;

/*!
 @abstract Sets the receiver's body to the specified string in the specified encoding.
 @param string The string to use for the receiver's body.
 @param encoding The encoding to use to convert the string to a data object.
 */
- (void)setBodyWithString:(NSString *)string encoding:(NSStringEncoding)encoding;

@end
