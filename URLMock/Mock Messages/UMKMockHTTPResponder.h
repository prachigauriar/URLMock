//
//  UMKMockHTTPResponder.h
//  URLMock
//
//  Created by Prachi Gauriar on 11/8/2013.
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

#import <URLMock/UMKMockHTTPMessage.h>
#import <URLMock/UMKMockURLProtocol.h>


/*!
 UMKMockHTTPResponder objects respond to mock HTTP URL requests. Instances can be created to respond with
 an NSError, an HTTP response, or even an HTTP response with its body broken into multiple chunks that are
 delivered over time.
 
 To simplify its interface, UMKMockHTTPResponder is implemented as a class cluster. Subclasses effectively 
 have to reimplement everything from scratch, and the only important common interface is already defined in
 UMKMockURLResponder. As such, there is little reason to ever subclass this class.
 */
@interface UMKMockHTTPResponder : UMKMockHTTPMessage <UMKMockURLResponder>

/*! @methodgroup Error Responders */

/*!
 @abstract Returns a new UMKMockHTTPResponder instance that responds by sending the specified error.
 @discussion The specified error is the one that is _sent_ to the NSURL system in response to a mock
     URL request; however, the NSURL system may modify it by adding fields to the error's userInfo or
     even changing the error's code. As such, expectations about the actual error that will be received
     should be limited. At best, individual fields in the error should be examined to ensure they match
     expectations.
 @param error The error to respond with. May not be nil.
 @result A new UMKMockHTTPResponder instance initialized with the specified error.
 */
+ (instancetype)mockHTTPResponderWithError:(NSError *)error;


/*! @methodgroup Data Responders */

/*!
 @abstract Returns a new UMKMockHTTPResponder instance that responds by sending an HTTP response with the
     specified HTTP status code.
 @discussion The HTTP headers and body that the responder responds with can be further modified using the
     standard methods from UMKMockHTTPMessage.
 @param statusCode The HTTP status code to respond with.
 @result A new UMKMockHTTPResponder instance initialized with the specified status code.
 */
+ (instancetype)mockHTTPResponderWithStatusCode:(NSInteger)statusCode;

/*!
 @abstract Returns a new UMKMockHTTPResponder instance that responds by sending an HTTP response with the
     specified HTTP status code and headers.
 @discussion The HTTP headers and body that the responder responds with can be further modified using the
     standard methods from UMKMockHTTPMessage.
 @param statusCode The HTTP status code to respond with.
 @param headers The HTTP headers to respond with.
 @result A newly initialized UMKMockHTTPResponseResponder with the specified status code and headers.
 */
+ (instancetype)mockHTTPResponderWithStatusCode:(NSInteger)statusCode headers:(NSDictionary *)headers;

/*!
 @abstract Returns a new UMKMockHTTPResponder instance that responds by sending an HTTP response with the
     specified HTTP status code and body.
 @discussion The HTTP headers and body that the responder responds with can be further modified using the
     standard methods from UMKMockHTTPMessage.
 @param statusCode The HTTP status code to respond with.
 @param body The HTTP body to respond with.
 @result A newly initialized UMKMockHTTPResponseResponder with the specified status code and body.
 */
+ (instancetype)mockHTTPResponderWithStatusCode:(NSInteger)statusCode body:(NSData *)body;

/*!
 @abstract Returns a new UMKMockHTTPResponder instance that responds by sending an HTTP response with the
     specified HTTP status code, headers, and body.
 @discussion The HTTP headers and body that the responder responds with can be further modified using the
     standard methods from UMKMockHTTPMessage.
 @param statusCode The HTTP status code to respond with.
 @param headers The HTTP headers to respond with.
 @param body The HTTP body to respond with.
 @result A newly initialized UMKMockHTTPResponseResponder with the specified status code, headers, and body.
 */
+ (instancetype)mockHTTPResponderWithStatusCode:(NSInteger)statusCode headers:(NSDictionary *)headers body:(NSData *)body;

/*!
 @abstract Returns a new UMKMockHTTPResponder instance with the specified status code, headers, body, chunk
     count hint, and delay between chunks.
 @param statusCode The HTTP status code to respond with.
 @param headers The HTTP headers to respond with.
 @param body The HTTP body to respond with.
 @param hint A hint as to how many chunks the HTTP body should be broken into when responding. The
     actual number of chunks depends on the size of the body and the whims of the NSURL system. May not be 0.
 @param delay The amount of time the responder should wait between sending chunks of data. This
     is only used if chunks is more than 1. Must be non-negative.
 @result A newly initialized UMKMockHTTPResponder with the specified parameters.
 */
+ (instancetype)mockHTTPResponderWithStatusCode:(NSInteger)statusCode headers:(NSDictionary *)headers body:(NSData *)body
                                 chunkCountHint:(NSUInteger)hint delayBetweenChunks:(NSTimeInterval)delay;

@end
