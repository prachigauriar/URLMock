//
//  UMKMockHTTPRequest.m
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

#import <URLMock/UMKMockHTTPRequest.h>
#import <URLMock/UMKMockURLProtocol.h>
#import <URLMock/NSDictionary+UMKURLEncoding.h>

#pragma mark Constants

NSString *const kUMKMockHTTPRequestDeleteMethod = @"DELETE";
NSString *const kUMKMockHTTPRequestGetMethod = @"GET";
NSString *const kUMKMockHTTPRequestHeadMethod = @"HEAD";
NSString *const kUMKMockHTTPRequestPatchMethod = @"PATCH";
NSString *const kUMKMockHTTPRequestPostMethod = @"POST";
NSString *const kUMKMockHTTPRequestPutMethod = @"PUT";


#pragma mark -

@interface UMKMockHTTPRequest ()

/*! A canonical version of the instance's URL. */
@property (readonly, strong, nonatomic) NSURL *canonicalURL;

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


#pragma mark -

@implementation UMKMockHTTPRequest

- (instancetype)init
{
    return [self initWithHTTPMethod:nil URL:nil];
}


- (instancetype)initWithHTTPMethod:(NSString *)method URL:(NSURL *)URL
{
    NSParameterAssert(method);
    NSParameterAssert(URL);
    
    self = [super init];
    if (self) {
        _HTTPMethod = method;
        _URL = URL;
        _canonicalURL = [UMKMockURLProtocol canonicalURLForURL:URL];
    }
    
    return self;
}


+ (instancetype)mockHTTPDeleteRequestWithURL:(NSURL *)URL
{
    return [[self alloc] initWithHTTPMethod:kUMKMockHTTPRequestDeleteMethod URL:URL];
}


+ (instancetype)mockHTTPGetRequestWithURL:(NSURL *)URL
{
    return [[self alloc] initWithHTTPMethod:kUMKMockHTTPRequestGetMethod URL:URL];
}


+ (instancetype)mockHTTPHeadRequestWithURL:(NSURL *)URL
{
    return [[self alloc] initWithHTTPMethod:kUMKMockHTTPRequestHeadMethod URL:URL];
}


+ (instancetype)mockHTTPPatchRequestWithURL:(NSURL *)URL
{
    return [[self alloc] initWithHTTPMethod:kUMKMockHTTPRequestPatchMethod URL:URL];
}


+ (instancetype)mockHTTPPostRequestWithURL:(NSURL *)URL
{
    return [[self alloc] initWithHTTPMethod:kUMKMockHTTPRequestPostMethod URL:URL];
}


+ (instancetype)mockHTTPPutRequestWithURL:(NSURL *)URL
{
    return [[self alloc] initWithHTTPMethod:kUMKMockHTTPRequestPutMethod URL:URL];
}


#pragma mark - UMKMockURLRequest Protocol

- (BOOL)matchesURLRequest:(NSURLRequest *)request
{
    return [self.canonicalURL isEqual:[UMKMockURLProtocol canonicalURLForURL:request.URL]] &&
           [self.HTTPMethod caseInsensitiveCompare:request.HTTPMethod] == NSOrderedSame &&
           [self headersAreEqualToHeadersOfRequest:request] &&
           [self bodyMatchesBodyOfURLRequest:request];

}


- (id <UMKMockURLResponder>)responderForURLRequest:(NSURLRequest *)request
{
    return self.responder;
}


#pragma mark - Private Methods

- (BOOL)bodyMatchesBodyOfURLRequest:(NSURLRequest *)request
{
    // If one of these is nil and the other isn't, they don't match. Otherwise, if one is nil,
    // they're both nil, so they do match.
    if ((self.body != nil) != (request.HTTPBody != nil)) {
        return NO;
    } else if (!self.body) {
        return YES;
    }
    
    // If the content type is either JSON or WWW Form URL Encoded, do a content-type-specific equality check.
    // This is because we know JSON and form parameters are equivalent even if their orders are not.
    NSString *contentType = [request valueForHTTPHeaderField:kUMKMockHTTPMessageContentTypeHeaderField];
    if (contentType) {
        if ([contentType rangeOfString:kUMKMockHTTPMessageJSONContentTypeHeaderValue].location != NSNotFound) {
            return [[self JSONObjectFromBody] isEqual:[NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:NULL]];
        } else if ([contentType rangeOfString:kUMKMockHTTPMessageWWWFormURLEncodedContentTypeHeaderValue].location != NSNotFound) {
            NSString *requestBodyString = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
            NSDictionary *bodyParameters = [NSDictionary umk_dictionaryWithURLEncodedParameterString:requestBodyString];
            return [[self parametersFromURLEncodedBody] isEqualToDictionary:bodyParameters];
        }
    }
    
    // Otherwise just compare bytes
    return [self.body isEqualToData:request.HTTPBody];
}

@end
