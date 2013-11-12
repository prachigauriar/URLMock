//
//  UMOMockHTTPRequest.m
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

#import <URLMock/UMOMockHTTPRequest.h>
#import <URLMock/UMOMockURLProtocol.h>
#import <URLMock/UMOURLEncodingUtilities.h>

#pragma mark Constants

NSString *const kUMOMockHTTPRequestDeleteMethod = @"DELETE";
NSString *const kUMOMockHTTPRequestGetMethod = @"GET";
NSString *const kUMOMockHTTPRequestHeadMethod = @"HEAD";
NSString *const kUMOMockHTTPRequestPatchMethod = @"PATCH";
NSString *const kUMOMockHTTPRequestPostMethod = @"POST";
NSString *const kUMOMockHTTPRequestPutMethod = @"PUT";


#pragma mark -

@implementation UMOMockHTTPRequest

- (instancetype)initWithHTTPMethod:(NSString *)method URL:(NSURL *)URL
{
    self = [super init];
    if (self) {
        _HTTPMethod = method;
        _URL = URL;
        _canonicalURL = [UMOMockURLProtocol canonicalURLForURL:URL];
    }
    
    return self;
}


+ (instancetype)mockDeleteRequestWithURLString:(NSString *)string
{
    return [[self alloc] initWithHTTPMethod:kUMOMockHTTPRequestDeleteMethod URL:[NSURL URLWithString:string]];
}


+ (instancetype)mockGetRequestWithURLString:(NSString *)string
{
    return [[self alloc] initWithHTTPMethod:kUMOMockHTTPRequestGetMethod URL:[NSURL URLWithString:string]];
}


+ (instancetype)mockHeadRequestWithURLString:(NSString *)string
{
    return [[self alloc] initWithHTTPMethod:kUMOMockHTTPRequestHeadMethod URL:[NSURL URLWithString:string]];
}


+ (instancetype)mockPatchRequestWithURLString:(NSString *)string
{
    return [[self alloc] initWithHTTPMethod:kUMOMockHTTPRequestPatchMethod URL:[NSURL URLWithString:string]];
}


+ (instancetype)mockPostRequestWithURLString:(NSString *)string
{
    return [[self alloc] initWithHTTPMethod:kUMOMockHTTPRequestPostMethod URL:[NSURL URLWithString:string]];
}


+ (instancetype)mockPutRequestWithURLString:(NSString *)string
{
    return [[self alloc] initWithHTTPMethod:kUMOMockHTTPRequestPutMethod URL:[NSURL URLWithString:string]];
}


#pragma mark - URL-Encoded Parameters

- (NSDictionary *)parametersFromURLEncodedBody
{
    return UMODictionaryForURLEncodedParametersString([self stringFromBody]);
}


- (void)setBodyByURLEncodingParameters:(NSDictionary *)parameters
{
    [self setBodyWithString:UMOURLEncodedStringForParameters(parameters)];
    if (!_headers[kUMOMockHTTPMessageContentTypeHeaderField]) {
        [self setValue:kUMOMockHTTPMessageUTF8WWWFormURLEncodedContentTypeHeaderValue forHeaderField:kUMOMockHTTPMessageContentTypeHeaderField];
    }
}


#pragma mark - Request Matching

- (BOOL)bodyMatchesBodyOfURLRequest:(NSURLRequest *)request
{
    // If the content type is either JSON or WWW Form URL Encoded, do a content-type-specific equality check.
    // This is because we know JSON and form parameters are equivalent even if their orders are not.
    NSString *contentType = [request valueForHTTPHeaderField:kUMOMockHTTPMessageContentTypeHeaderField];
    if ([contentType rangeOfString:kUMOMockHTTPMessageJSONContentTypeHeaderValue].location != NSNotFound) {
        return [[self JSONObjectFromBody] isEqual:[NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:NULL]];
    } else if ([contentType rangeOfString:kUMOMockHTTPMessageWWWFormURLEncodedContentTypeHeaderValue].location != NSNotFound) {
        NSString *requestBodyString = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
        return [[self parametersFromURLEncodedBody] isEqualToDictionary:UMODictionaryForURLEncodedParametersString(requestBodyString)];;
    }
    
    // Otherwise just compare bytes
    return [self.body isEqualToData:request.HTTPBody];
}


- (BOOL)matchesURLRequest:(NSURLRequest *)request
{
    return [self.canonicalURL isEqual:[UMOMockURLProtocol canonicalURLForURL:request.URL]] && [self.HTTPMethod isEqualToString:request.HTTPMethod] &&
           [self headersAreEqualToHeadersOfRequest:request] && [self bodyMatchesBodyOfURLRequest:request];

}

@end
