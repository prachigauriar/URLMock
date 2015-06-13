//
//  NSURLRequest+UMKHTTPConvenienceMethods.h
//  URLMock
//
//  Created by Prachi Gauriar on 6/25/2014.
//  Copyright (c) 2015 Ticketmaster Entertainment, Inc. All rights reserved.
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
 The UMKHTTPConvenienceMethods category on NSURLRequest adds methods to NSURLRequests to make it easier to
 get the request’s HTTP body in numerous forms and compare its HTTP headers to those in a specified dictionary.
 */
@interface NSURLRequest (UMKHTTPConvenienceMethods)

/*!
 @abstract Returns the receiver’s HTTP body as an NSData instance.
 @discussion This method works by first checking if the receiver has an HTTP body stream. If so,
     the stream’s data is collected in an NSData instance and returned. Otherwise, this method
     just returns the same thing as -HTTPBody.
 
     Note that if the receiver has an HTTP body stream, this method may only be invoked once per URL request.
     Subsequent invocations will return nil.
 */
- (NSData *)umk_HTTPBodyData;

/*!
 @abstract Returns the receiver's HTTP body as a JSON object.
 @discussion This method is implemented using -umk_HTTPBodyData. As such, if the receiver has an HTTP body stream, 
     this method may only be invoked once per URL request. Subsequent invocations will return nil.
 @result The receiver's body as a JSON object, or nil if the receiver's body does not contain valid JSON data.
 */
- (id)umk_JSONObjectFromHTTPBody;

/*!
 @abstract Returns a dictionary representation of the receiver's HTTP body intepreted as URL-encoded WWW form parameters.
 @discussion This method is implemented using -umk_HTTPBodyData. As such, if the receiver has an HTTP body stream,
     this method may only be invoked once per URL request. Subsequent invocations will return nil.
 @result A dictionary of the receiver's body as form parameters. Keys are strings. Values are either strings or the
     NSNull instance.
 */
- (NSDictionary *)umk_parametersFromURLEncodedHTTPBody;

/*!
 @abstract Returns the receiver's HTTP body as a UTF-8-encoded string.
 @discussion This method is implemented using -umk_HTTPBodyData. As such, if the receiver has an HTTP body stream,
     this method may only be invoked once per URL request. Subsequent invocations will return nil.
 @result The receiver's HTTP body as a UTF-8 encoded string.
 */
- (NSString *)umk_stringFromHTTPBody;

/*!
 @abstract Returns the receiver's HTTP body as a string in the specified encoding.
 @discussion This method is implemented using -umk_HTTPBodyData. As such, if the receiver has an HTTP body stream,
     this method may only be invoked once per URL request. Subsequent invocations will return nil.
 @param encoding The encoding to use to convert the string to a data object.
 @result The receiver's HTTP body as a string in the specified encoding.
 */
- (NSString *)umk_stringFromHTTPBodyWithEncoding:(NSStringEncoding)encoding;

/*!
 @abstract Returns whether the specified headers are equal to the receiver's HTTP headers.
 @discussion The receiver and the request have equal headers if they have the same number of them, their header fields
     are the same (case-insensitively), and the header values for those fields identical.
 @param headers The HTTP headers being compared to the receiver's.
 @result Whether the receiver's headers are equal to those specified. Returns NO if headers is nil.
 */
- (BOOL)umk_HTTPHeadersAreEqualToHeaders:(NSDictionary *)headers;

@end
