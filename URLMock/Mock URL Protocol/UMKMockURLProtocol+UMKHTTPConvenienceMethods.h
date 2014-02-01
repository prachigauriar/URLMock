//
//  UMKMockURLProtocol+UMKHTTPConvenienceMethods.h
//  URLMock
//
//  Created by Prachi Gauriar on 2/1/2014.
//  Copyright (c) 2014 Prachi Gauriar.
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

// JSON request bodies with error responses
+ (UMKMockHTTPRequest *)expectMockHTTPRequestWithMethod:(NSString *)method URL:(NSURL *)URL requestJSON:(id)requestJSON responseError:(NSError *)error;
+ (UMKMockHTTPRequest *)expectMockHTTPGetRequestWithURL:(NSURL *)URL responseError:(NSError *)error;
+ (UMKMockHTTPRequest *)expectMockHTTPPatchRequestWithURL:(NSURL *)URL requestJSON:(id)requestJSON responseError:(NSError *)error;
+ (UMKMockHTTPRequest *)expectMockHTTPPostRequestWithURL:(NSURL *)URL requestJSON:(id)requestJSON responseError:(NSError *)error;
+ (UMKMockHTTPRequest *)expectMockHTTPPutRequestWithURL:(NSURL *)URL requestJSON:(id)requestJSON responseError:(NSError *)error;

// JSON request bodies with JSON responses
+ (UMKMockHTTPRequest *)expectMockHTTPRequestWithMethod:(NSString *)method URL:(NSURL *)URL requestJSON:(id)requestJSON
                                     responseStatusCode:(NSUInteger)statusCode responseJSON:(id)responseJSON;
+ (UMKMockHTTPRequest *)expectMockHTTPGetRequestWithURL:(NSURL *)URL responseStatusCode:(NSUInteger)statusCode responseJSON:(id)responseJSON;
+ (UMKMockHTTPRequest *)expectMockHTTPPatchRequestWithURL:(NSURL *)URL requestJSON:(id)requestJSON
                                       responseStatusCode:(NSUInteger)statusCode responseJSON:(id)responseJSON;
+ (UMKMockHTTPRequest *)expectMockHTTPPostRequestWithURL:(NSURL *)URL requestJSONBody:(id)requestJSON
                                      responseStatusCode:(NSUInteger)statusCode responseJSON:(id)responseJSON;
+ (UMKMockHTTPRequest *)expectMockHTTPPutRequestWithURL:(NSURL *)URL requestJSON:(id)requestJSON
                                     responseStatusCode:(NSUInteger)statusCode responseJSON:(id)responseJSON;

@end
