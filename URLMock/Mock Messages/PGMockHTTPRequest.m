//
//  PGMockHTTPRequest.m
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

#import "PGMockHTTPRequest.h"
#import "PGURLEncodingUtilities.h"

#pragma mark Constants

NSString *const kPGMockHTTPRequestDeleteMethod = @"DELETE";
NSString *const kPGMockHTTPRequestGetMethod = @"GET";
NSString *const kPGMockHTTPRequestHeadMethod = @"HEAD";
NSString *const kPGMockHTTPRequestPatchMethod = @"PATCH";
NSString *const kPGMockHTTPRequestPostMethod = @"POST";
NSString *const kPGMockHTTPRequestPutMethod = @"PUT";


#pragma mark -

@implementation PGMockHTTPRequest

- (instancetype)initWithHTTPMethod:(NSString *)method URL:(NSURL *)URL
{
    self = [super init];
    if (self) {
        _method = method;
        _URL = URL;
    }
    
    return self;
}


+ (instancetype)mockDeleteRequestWithURLString:(NSString *)string
{
    return [[self alloc] initWithHTTPMethod:kPGMockHTTPRequestDeleteMethod URL:[NSURL URLWithString:string]];
}


+ (instancetype)mockGetRequestWithURLString:(NSString *)string
{
    return [[self alloc] initWithHTTPMethod:kPGMockHTTPRequestGetMethod URL:[NSURL URLWithString:string]];
}


+ (instancetype)mockHeadRequestWithURLString:(NSString *)string
{
    return [[self alloc] initWithHTTPMethod:kPGMockHTTPRequestHeadMethod URL:[NSURL URLWithString:string]];
}


+ (instancetype)mockPatchRequestWithURLString:(NSString *)string
{
    return [[self alloc] initWithHTTPMethod:kPGMockHTTPRequestPatchMethod URL:[NSURL URLWithString:string]];
}


+ (instancetype)mockPostRequestWithURLString:(NSString *)string
{
    return [[self alloc] initWithHTTPMethod:kPGMockHTTPRequestPostMethod URL:[NSURL URLWithString:string]];
}


+ (instancetype)mockPutRequestWithURLString:(NSString *)string
{
    return [[self alloc] initWithHTTPMethod:kPGMockHTTPRequestPutMethod URL:[NSURL URLWithString:string]];
}


- (void)setBodyByURLEncodingParameters:(NSDictionary *)parameters
{
    [self setStringBody:PGURLEncodedStringRepresentation(parameters)];
    if (!_headers[kPGMockHTTPMessageContentTypeHeaderField]) {
        [self setValue:kPGMockHTTPMessageUTF8WWWFormURLEncodedContentTypeHeaderValue forHeaderField:kPGMockHTTPMessageContentTypeHeaderField];
    }
}

@end
