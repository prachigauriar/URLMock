//
//  UMKMockURLProtocol+UMKHTTPConvenienceMethods.h
//  URLMock
//
//  Created by Prachi Gauriar on 2/1/2014.
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

#import <URLMock/UMKMockURLProtocol.h>


@class UMKMockHTTPRequest;

@interface UMKMockURLProtocol (UMKHTTPConvenienceMethods)

/*! @methodgroup Mock Requests with JSON Bodies with Error Responders */

/*!
 @abstract Creates and expects a new mock HTTP request that responds with an error.
 @discussion There is no need to add the returned mock request to the list of expected mock requests, as
     this method adds it automatically.
 @param method The HTTP method for the mock HTTP request. May not be nil.
 @param URL The URL for the mock HTTP request. May not be nil.
 @param requestJSON A JSON object to use as the mock HTTP request body.
 @param error The error that the mock responder responds with. May not be nil.
 @result The newly created mock HTTP request. Its responder is set to the new mock error responder.
 */
+ (UMKMockHTTPRequest *)expectMockHTTPRequestWithMethod:(NSString *)method URL:(NSURL *)URL
                                            requestJSON:(id)requestJSON responseError:(NSError *)error;

/*!
 @abstract Creates and expects a new mock HTTP GET request that responds with an error.
 @discussion There is no need to add the returned mock request to the list of expected mock requests, as
     this method adds it automatically.
 @param URL The URL for the mock GET request. May not be nil.
 @param error The error that the mock responder responds with. May not be nil.
 @result The newly created mock HTTP GET request. Its responder is set to the new mock error responder.
 */
+ (UMKMockHTTPRequest *)expectMockHTTPGetRequestWithURL:(NSURL *)URL responseError:(NSError *)error;

/*!
 @abstract Creates and expects a new mock HTTP PATCH request that responds with an error.
 @discussion There is no need to add the returned mock request to the list of expected mock requests, as
     this method adds it automatically.
 @param URL The URL for the mock PATCH request. May not be nil.
 @param requestJSON A JSON object to use as the mock HTTP PATCH request body.
 @param error The error that the mock responder responds with. May not be nil.
 @result The newly created mock HTTP PATCH request. Its responder is set to the new mock error responder.
 */
+ (UMKMockHTTPRequest *)expectMockHTTPPatchRequestWithURL:(NSURL *)URL requestJSON:(id)requestJSON responseError:(NSError *)error;

/*!
 @abstract Creates and expects a new mock HTTP POST request that responds with an error.
 @discussion There is no need to add the returned mock request to the list of expected mock requests, as
     this method adds it automatically.
 @param URL The URL for the mock POST request. May not be nil.
 @param requestJSON A JSON object to use as the mock HTTP POST request body.
 @param error The error that the mock responder responds with. May not be nil.
 @result The newly created mock HTTP POST request. Its responder is set to the new mock error responder.
 */
+ (UMKMockHTTPRequest *)expectMockHTTPPostRequestWithURL:(NSURL *)URL requestJSON:(id)requestJSON responseError:(NSError *)error;

/*!
 @abstract Creates and expects a new mock HTTP PUT request that responds with an error.
 @discussion There is no need to add the returned mock request to the list of expected mock requests, as
     this method adds it automatically.
 @param URL The URL for the mock PUT request. May not be nil.
 @param requestJSON A JSON object to use as the mock HTTP PUT request body.
 @param error The error that the mock responder responds with. May not be nil.
 @result The newly created mock HTTP PUT request. Its responder is set to the new mock error responder.
 */
+ (UMKMockHTTPRequest *)expectMockHTTPPutRequestWithURL:(NSURL *)URL requestJSON:(id)requestJSON responseError:(NSError *)error;


/*! @methodgroup Mock Requests and Responders with JSON Bodies */

/*!
 @abstract Creates and expects a new mock HTTP request that responds with a JSON object.
 @discussion There is no need to add the returned mock request to the list of expected mock requests, as
     this method adds it automatically.
 @param method The HTTP method for the mock HTTP request. May not be nil.
 @param URL The URL for the mock HTTP request. May not be nil.
 @param requestJSON A JSON object to use as the mock HTTP request body.
 @param statusCode The status code for the HTTP response.
 @param responseJSON A JSON object to use as the mock HTTP response body.
 @result The newly created mock HTTP request. Its responder is set to the new mock JSON body responder.
 */
+ (UMKMockHTTPRequest *)expectMockHTTPRequestWithMethod:(NSString *)method URL:(NSURL *)URL requestJSON:(id)requestJSON
                                     responseStatusCode:(NSInteger)statusCode responseJSON:(id)responseJSON;

/*!
 @abstract Creates and expects a new mock HTTP GET request that responds with a JSON object.
 @discussion There is no need to add the returned mock request to the list of expected mock requests, as
     this method adds it automatically.
 @param URL The URL for the mock GET request. May not be nil.
 @param statusCode The status code for the HTTP response.
 @param responseJSON A JSON object to use as the mock HTTP response body.
 @result The newly created mock HTTP GET request. Its responder is set to the new mock JSON body responder.
 */
+ (UMKMockHTTPRequest *)expectMockHTTPGetRequestWithURL:(NSURL *)URL responseStatusCode:(NSInteger)statusCode responseJSON:(id)responseJSON;

/*!
 @abstract Creates and expects a new mock HTTP PATCH request that responds with a JSON object.
 @discussion There is no need to add the returned mock request to the list of expected mock requests, as
     this method adds it automatically.
 @param URL The URL for the mock PATCH request. May not be nil.
 @param requestJSON A JSON object to use as the mock HTTP PATCH request body.
 @param statusCode The status code for the HTTP response.
 @param responseJSON A JSON object to use as the mock HTTP response body.
 @result The newly created mock HTTP PATCH request. Its responder is set to the new mock JSON body responder.
 */
+ (UMKMockHTTPRequest *)expectMockHTTPPatchRequestWithURL:(NSURL *)URL requestJSON:(id)requestJSON
                                       responseStatusCode:(NSInteger)statusCode responseJSON:(id)responseJSON;

/*!
 @abstract Creates and expects a new mock HTTP POST request that responds with a JSON object.
 @discussion There is no need to add the returned mock request to the list of expected mock requests, as
     this method adds it automatically.
 @param URL The URL for the mock POST request. May not be nil.
 @param requestJSON A JSON object to use as the mock HTTP POST request body.
 @param statusCode The status code for the HTTP response.
 @param responseJSON A JSON object to use as the mock HTTP response body.
 @result The newly created mock HTTP POST request. Its responder is set to the new mock JSON body responder.
 */
+ (UMKMockHTTPRequest *)expectMockHTTPPostRequestWithURL:(NSURL *)URL requestJSON:(id)requestJSON
                                      responseStatusCode:(NSInteger)statusCode responseJSON:(id)responseJSON;

/*!
 @abstract Creates and expects a new mock HTTP PUT request that responds with a JSON object.
 @discussion There is no need to add the returned mock request to the list of expected mock requests, as
     this method adds it automatically.
 @param URL The URL for the mock PUT request. May not be nil.
 @param requestJSON A JSON object to use as the mock HTTP PUT request body.
 @param statusCode The status code for the HTTP response.
 @param responseJSON A JSON object to use as the mock HTTP response body.
 @result The newly created mock HTTP PUT request. Its responder is set to the new mock JSON body responder.
 */
+ (UMKMockHTTPRequest *)expectMockHTTPPutRequestWithURL:(NSURL *)URL requestJSON:(id)requestJSON
                                     responseStatusCode:(NSInteger)statusCode responseJSON:(id)responseJSON;

@end
