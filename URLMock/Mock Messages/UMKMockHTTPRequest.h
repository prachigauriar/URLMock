//
//  UMKMockHTTPRequest.h
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
@property (nonatomic, strong) id<UMKMockURLResponder> responder;

/*! Whether the instance tests header equality when determining if it matches a URL request. This is NO by default. */
@property (nonatomic, assign) BOOL checksHeadersWhenMatching;

/*! 
 @abstract Whether the instance tests body equality when determining if it matches a URL request. This is YES by 
     default.
 */
@property (nonatomic, assign) BOOL checksBodyWhenMatching;

/*!
 @abstract Initializes a newly allocated instance with the specified HTTP method and URL.
 @discussion The returned object does not test header equivalence when matching.
 @param method The HTTP method for the new instance. May not be nil.
 @param URL The URL for the new instance. May not be nil.
 @result An initialized mock request instance.
 */
- (instancetype)initWithHTTPMethod:(NSString *)method URL:(NSURL *)URL;

/*!
 @abstract Initializes a newly allocated instance with the specified HTTP method and URL.
 @param method The HTTP method for the new instance. May not be nil.
 @param URL The URL for the new instance. May not be nil.
 @param checksHeaders Whether the new instance should check header equality when determining if it matches a URL 
     request.
 @result An initialized mock request instance.
 */
- (instancetype)initWithHTTPMethod:(NSString *)method URL:(NSURL *)URL checksHeadersWhenMatching:(BOOL)checksHeaders;


/*!
 @abstract Initializes a newly allocated instance with the specified HTTP method and URL.
 @discussion This is the class's designated initializer.
 @param method The HTTP method for the new instance. May not be nil.
 @param URL The URL for the new instance. May not be nil.
 @param checksHeaders Whether the new instance should check header equality when determining if it matches a URL 
     request.
 @param checksBody Whether the new instance should check body equality when determining if it matches a URL request.
 @result An initialized mock request instance.
 */
- (instancetype)initWithHTTPMethod:(NSString *)method URL:(NSURL *)URL checksHeadersWhenMatching:(BOOL)checksHeaders checksBodyWhenMatching:(BOOL)checksBody;

/*!
 @abstract Creates and returns a new mock HTTP DELETE request to the specified URL.
 @param URL The URL for the new mock request. May not be nil.
 @result A new mock HTTP DELETE request with the specified URL.
 */
+ (instancetype)mockHTTPDeleteRequestWithURL:(NSURL *)URL;

/*!
 @abstract Creates and returns a new mock HTTP DELETE request to the specified URL.
 @param URL The URL for the new mock request. May not be nil.
 @result A new mock HTTP DELETE request with the specified URL.
 */
+ (instancetype)mockHTTPGetRequestWithURL:(NSURL *)URL;

/*!
 @abstract Creates and returns a new mock HTTP HEAD request to the specified URL.
 @param URL The URL for the new mock request. May not be nil.
 @result A new mock HTTP HEAD request with the specified URL.
 */
+ (instancetype)mockHTTPHeadRequestWithURL:(NSURL *)URL;

/*!
 @abstract Creates and returns a new mock HTTP PATCH request to the specified URL.
 @param URL The URL for the new mock request. May not be nil.
 @result A new mock HTTP PATCH request with the specified URL.
 */
+ (instancetype)mockHTTPPatchRequestWithURL:(NSURL *)URL;

/*!
 @abstract Creates and returns a new mock HTTP POST request to the specified URL.
 @param URL The URL for the new mock request. May not be nil.
 @result A new mock HTTP POST request with the specified URL.
 */
+ (instancetype)mockHTTPPostRequestWithURL:(NSURL *)URL;

/*!
 @abstract Creates and returns a new mock HTTP PUT request to the specified URL.
 @param URL The URL for the new mock request. May not be nil.
 @result A new mock HTTP PUT request with the specified URL.
 */
+ (instancetype)mockHTTPPutRequestWithURL:(NSURL *)URL;


/*! @methodgroup Default Headers */

/*! 
 @abstract Returns the default headers for new UMKMockHTTPRequest instances.
 @result The default headers for new UMKMockHTTPRequest instances or nil if no default has been set.
 */
+ (NSDictionary *)defaultHeaders;

/*!
 @abstract Sets the default headers for new UMKMockHTTPRequest instances.
 @discussion This is primarily useful when the URL loading API in use automatically includes a set of headers
     with every request. AFNetworking does this. Using default headers simplifies the mock request creation 
     process.
 @param defaultHeaders The headers that should be the default for all new UMKMockHTTPRequest instances.
 */
+ (void)setDefaultHeaders:(NSDictionary *)defaultHeaders;


/*! @methodgroup URL request matching */

/*!
 @abstract Returns whether the receiver matches the specified URL request.
 @discussion A mock request is said to match a URL request if the have the same canonical URL, the same HTTP method,
     and equivalent headers and bodies. Note that headers are only checked if the instance returns YES for 
     -checksHeadersWhenMatching, and bodies are only checked if the instance returns YES for -checksBodyWhenMatching.
 @param request The URL request.
 @result Whether the receiver matches the specified URL request.
 */
- (BOOL)matchesURLRequest:(NSURLRequest *)request;

@end
