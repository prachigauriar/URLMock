//
//  NSURLRequest+UMKHTTPConvenience.h
//  URLMock
//
//  Created by Prachi Gauriar on 6/25/2014.
//  Copyright (c) 2014 Two Toasters, LLC.
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
 The UMKHTTPConvenience category on NSURLRequest adds methods to NSURLRequests to make it easier 
 to get the request’s HTTP body as an NSData instance and compare its HTTP headers to those in a
 specified dictionary.
 */
@interface NSURLRequest (UMKHTTPConvenience)

/*!
 @abstract Returns the receiver’s HTTP body as an NSData instance.
 @discussion This method works by first checking if the receiver has an HTTP body stream. If so,
     the stream’s data is collected in an NSData instance and returned. Otherwise, this method
     just returns the same thing as -HTTPBody.
 */
- (NSData *)umk_HTTPBodyData;

/*!
 @abstract Returns whether the specified headers are equal to the receiver's HTTP headers.
 @discussion The receiver and the request have equal headers if they have the same number of them, their header fields
     are the same (case-insensitively), and the header values for those fields identical.
 @param headers The HTTP headers being compared to the receiver's.
 @result Whether the receiver's headers are equal to those specified. Returns NO if headers is nil.
 */
- (BOOL)umk_HTTPHeadersAreEqualToHeaders:(NSDictionary *)headers;

@end
