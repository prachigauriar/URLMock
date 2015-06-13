//
//  NSURL+UMKQueryParameters.h
//  URLMock
//
//  Created by Prachi Gauriar on 1/4/2014.
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
 The UMKQueryParameters category of NSURL adds methods to create and initialize NSURLs with 
 URL-encoded query parameters.
 */
@interface NSURL (UMKQueryParameters)

/*!
 @abstract Returns a newly initialized NSURL object with the specified URL string and query parameters.
 @discussion This method expects URLString to contain only characters that are allowed in a properly
     formed URL. All other characters must be properly percent escaped. Any percent-escaped characters
     are interpreted using UTF-8 encoding. May not be nil.
 @param URLString The URL string with which to initialize the NSURL object. May not be nil. Must conform
     to RFC 2396.
 @param parameters The parameters object to use to build the NSURL object's query string.
 @result A newly initialized NSURL object
 */
- (instancetype)umk_initWithString:(NSString *)URLString parameters:(NSDictionary *)parameters;

/*!
 @abstract Returns a newly initialized NSURL object with the specified base URL, relative
     string, and query parameters.
 @discussion This method expects URLString to contain only characters that are allowed in a properly
     formed URL. All other characters must be properly percent escaped. Any percent-escaped characters
     are interpreted using UTF-8 encoding. May not be nil.
 @param URLString The URL string with which to initialize the NSURL object. May not be nil. Must conform
     to RFC 2396.
 @param parameters The parameters object to use to build the NSURL object's query string.
 @param baseURL The base URL for the NSURL object.
 @result A newly initialized NSURL object
 */
- (instancetype)umk_initWithString:(NSString *)URLString parameters:(NSDictionary *)parameters relativeToURL:(NSURL *)baseURL;

/*!
 @abstract Creates and returns an NSURL object initialized with the specified URL string and query parameters.
 @discussion This method expects URLString to contain only characters that are allowed in a properly
     formed URL. All other characters must be properly percent escaped. Any percent-escaped characters
     are interpreted using UTF-8 encoding. May not be nil.
 @param URLString The URL string with which to initialize the NSURL object. May not be nil. Must conform
     to RFC 2396.
 @param parameters The parameters object to use to build the NSURL object's query string.
 @result An NSURL object
 */
+ (instancetype)umk_URLWithString:(NSString *)URLString parameters:(NSDictionary *)parameters;

/*!
 @abstract Creates and returns an NSURL object initialized with the specified base URL, relative
     string, and query parameters.
 @discussion This method expects URLString to contain only characters that are allowed in a properly 
     formed URL. All other characters must be properly percent escaped. Any percent-escaped characters 
     are interpreted using UTF-8 encoding. May not be nil.
 @param URLString The URL string with which to initialize the NSURL object. May not be nil. Must conform
     to RFC 2396. URLString is interpreted relative to baseURL.
 @param parameters The parameters object to use to build the NSURL object's query string.
 @param baseURL The base URL for the NSURL object.
 @result An NSURL object
 */
+ (instancetype)umk_URLWithString:(NSString *)URLString parameters:(NSDictionary *)parameters relativeToURL:(NSURL *)baseURL;

@end
