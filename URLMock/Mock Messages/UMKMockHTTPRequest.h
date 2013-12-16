//
//  UMKMockHTTPRequest.h
//  URLMock
//
//  Created by Prachi Gauriar on 11/8/2013.
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
#import <URLMock/UMKMockHTTPMessage.h>
#import <URLMock/UMKMockURLProtocol.h>

#pragma mark Constants

/*! The DELETE HTTP method. */
extern NSString *const kUMKMockHTTPRequestDeleteMethod;

/*! The GET HTTP method. */
extern NSString *const kUMKMockHTTPRequestGetMethod;

/*! The HEAD HTTP method. */
extern NSString *const kUMKMockHTTPRequestHeadMethod;

/*! The PATCH HTTP method. */
extern NSString *const kUMKMockHTTPRequestPatchMethod;

/*! The POST HTTP method. */
extern NSString *const kUMKMockHTTPRequestPostMethod;

/*! The PUT HTTP method. */
extern NSString *const kUMKMockHTTPRequestPutMethod;


#pragma mark -

/*!
 Instances of UMKMockHTTPRequest, or simply mock requests, represent mock HTTP requests. They are used to tell 
 UMKMockURLProtocol which requests to expect and how to respond to them.
 
 Each mock request has an associated HTTP method, URL, and responder, plus methods to determine whether the instance
 matches an NSURLRequest.
 */
@interface UMKMockHTTPRequest : UMKMockHTTPMessage <UMKMockURLRequest>

/*! The instance's HTTP method. */
@property (nonatomic, copy, readonly) NSString *HTTPMethod;

/*! The instance's URL. */
@property (nonatomic, strong, readonly) NSURL *URL;

/*! The mock responder associated with the instance. This is the object returned by -responderForURLRequest:. */
@property (nonatomic, strong) id <UMKMockURLResponder> responder;

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
 @result A new mock HTTP DELETE request with the specified URL.
 */
+ (instancetype)mockHTTPDeleteRequestWithURLString:(NSString *)string;

/*!
 @abstract Creates and returns a new mock HTTP DELETE request to the specified URL.
 @param string A string representation of the new request's URL. May not be nil.
 @result A new mock HTTP DELETE request with the specified URL.
 */
+ (instancetype)mockHTTPGetRequestWithURLString:(NSString *)string;

/*!
 @abstract Creates and returns a new mock HTTP HEAD request to the specified URL.
 @param string A string representation of the new request's URL. May not be nil.
 @result A new mock HTTP HEAD request with the specified URL.
 */
+ (instancetype)mockHTTPHeadRequestWithURLString:(NSString *)string;

/*!
 @abstract Creates and returns a new mock HTTP PATCH request to the specified URL.
 @param string A string representation of the new request's URL. May not be nil.
 @result A new mock HTTP PATCH request with the specified URL.
 */
+ (instancetype)mockHTTPPatchRequestWithURLString:(NSString *)string;

/*!
 @abstract Creates and returns a new mock HTTP POST request to the specified URL.
 @param string A string representation of the new request's URL. May not be nil.
 @result A new mock HTTP POST request with the specified URL.
 */
+ (instancetype)mockHTTPPostRequestWithURLString:(NSString *)string;

/*!
 @abstract Creates and returns a new mock HTTP PUT request to the specified URL.
 @param string A string representation of the new request's URL. May not be nil.
 @result A new mock HTTP PUT request with the specified URL.
 */
+ (instancetype)mockHTTPPutRequestWithURLString:(NSString *)string;

/*!
 @abstract Returns whether the receiver matches the specified URL request.
 @discussion A mock request is said to match a URL request if the have the same canonical URL, the same HTTP method,
     and equivalent headers and bodies.
 @param request The URL request.
 @result Whether the receiver matches the specified URL request.
 */
- (BOOL)matchesURLRequest:(NSURLRequest *)request;

@end
