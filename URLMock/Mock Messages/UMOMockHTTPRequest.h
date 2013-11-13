//
//  UMOMockHTTPRequest.h
//  URLMock
//
//  Created by Prachi Gauriar on 11/8/2013.
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
#import <URLMock/UMOMockHTTPMessage.h>

#pragma mark Constants

/*! The DELETE HTTP method. */
extern NSString *const kUMOMockHTTPRequestDeleteMethod;

/*! The GET HTTP method. */
extern NSString *const kUMOMockHTTPRequestGetMethod;

/*! The HEAD HTTP method. */
extern NSString *const kUMOMockHTTPRequestHeadMethod;

/*! The PATCH HTTP method. */
extern NSString *const kUMOMockHTTPRequestPatchMethod;

/*! The POST HTTP method. */
extern NSString *const kUMOMockHTTPRequestPostMethod;

/*! The PUT HTTP method. */
extern NSString *const kUMOMockHTTPRequestPutMethod;


#pragma mark -

@class UMOMockHTTPResponse;

/*!
 Instances of UMOMockHTTPRequest, or simply mock requests, represent mock HTTP requests. They are used to tell 
 UMOMockURLProtocol which requests to expect and how to respond to them.
 
 Each mock request has an associated HTTP method, URL, and response, plus methods to determine whether the instance
 matches an NSURLRequest.
 */
@interface UMOMockHTTPRequest : UMOMockHTTPMessage

/*! The instance's HTTP method. */
@property (readonly, copy, nonatomic) NSString *HTTPMethod;

/*! The instance's URL. */
@property (readonly, strong, nonatomic) NSURL *URL;

/*! A canonical version of the instance's URL. */
@property (readonly, strong, nonatomic) NSURL *canonicalURL;

/*! The mock response associated with the instance. */
@property (readwrite, strong, nonatomic) UMOMockHTTPResponse *response;

/*!
 @abstract Initializes a newly allocated instance with the specified HTTP method and URL.
 @discussion This is the class's designated initializer.
 @param method The HTTP method for the new instance. May not be nil.
 @param URL The URL for the new instance. May not be nil.
 @result An initialized mock request instance.
 */
- (instancetype)initWithHTTPMethod:(NSString *)method URL:(NSURL *)URL;

/*!
 @abstract Creates and returns a new mock HTTP DELETE request to the specified URL.
 @param string A string representation of the new request's URL. May not be nil.
 @result A new mock DELETE HTTP request with the specified URL.
 */
+ (instancetype)mockDeleteRequestWithURLString:(NSString *)string;

/*!
 @abstract Creates and returns a new mock HTTP DELETE request to the specified URL.
 @param string A string representation of the new request's URL. May not be nil.
 @result A new mock DELETE HTTP request with the specified URL.
 */
+ (instancetype)mockGetRequestWithURLString:(NSString *)string;

/*!
 @abstract Creates and returns a new mock HTTP HEAD request to the specified URL.
 @param string A string representation of the new request's URL. May not be nil.
 @result A new mock HEAD HTTP request with the specified URL.
 */
+ (instancetype)mockHeadRequestWithURLString:(NSString *)string;

/*!
 @abstract Creates and returns a new mock HTTP PATCH request to the specified URL.
 @param string A string representation of the new request's URL. May not be nil.
 @result A new mock PATCH HTTP request with the specified URL.
 */
+ (instancetype)mockPatchRequestWithURLString:(NSString *)string;

/*!
 @abstract Creates and returns a new mock HTTP POST request to the specified URL.
 @param string A string representation of the new request's URL. May not be nil.
 @result A new mock POST HTTP request with the specified URL.
 */
+ (instancetype)mockPostRequestWithURLString:(NSString *)string;

/*!
 @abstract Creates and returns a new mock HTTP PUT request to the specified URL.
 @param string A string representation of the new request's URL. May not be nil.
 @result A new mock PUT HTTP request with the specified URL.
 */
+ (instancetype)mockPutRequestWithURLString:(NSString *)string;


/*!
 @abstract Returns a dictionary representation of the receiver's body intepreted as URL-encoded WWW form parameters.
 @result A dictionary of the receiver's body as form parameters. Keys are strings. Values are either strings or the
     NSNull instance.
 */
- (NSDictionary *)parametersFromURLEncodedBody;

/*!
 @abstract Sets the receiver's body as a WWW Form URL-encoded representation of the specified dictionary.
 @discussion If the receiver does not already have a value for the Content-type header field, sets the value of that
     header to "application/x-www-form-urlencoded; charset=utf-8".
 @param parameters The dictionary of parameters to set as the receiver's body. May not be nil. Keys must be strings.
     Values may be any object type; the value used in the receiver's body will be the result of invoking -description 
     on the value.
 */
- (void)setBodyByURLEncodingParameters:(NSDictionary *)parameters;


/*!
 @abstract Returns whether the receiver matches the specified URL request.
 @discussion A mock request is said to match a URL request if the have the same canonical URL, the same HTTP method,
     and equivalent headers and bodies.
 @param request The URL request.
 @result Whether the receiver matches the specified URL request.
 */
- (BOOL)matchesURLRequest:(NSURLRequest *)request;

/*!
 @abstract Returns whether the receiver's body matches that of the specified URL request.
 @discussion If the URL request's content-type contains "application/json" or "application/x-www-form-urlencoded", 
     this method will interpret the bodies of both the receiver and the URL request as JSON or URL-encoded parameters
     and compare them that way. Otherwise, the bodies' bytes are compared.
 @param request The URL request.
 @result Whether the receiver's body matches that of the specified URL request.
 */
- (BOOL)bodyMatchesBodyOfURLRequest:(NSURLRequest *)request;

@end
