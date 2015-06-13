//
//  NSURL+UMKQueryParameters.m
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

#import <URLMock/NSURL+UMKQueryParameters.h>

#import <URLMock/NSDictionary+UMKURLEncoding.h>


@implementation NSURL (UMKQueryParameters)

- (instancetype)umk_initWithString:(NSString *)URLString parameters:(NSDictionary *)parameters
{
    return [self umk_initWithString:URLString parameters:parameters relativeToURL:nil];
}


- (instancetype)umk_initWithString:(NSString *)URLString parameters:(NSDictionary *)parameters relativeToURL:(NSURL *)baseURL
{
    if (parameters) {
        NSString *encodedParameters = [parameters umk_URLEncodedParameterString];
        NSRange questionMarkRange = [URLString rangeOfString:@"?" options:NSBackwardsSearch];
        URLString = [URLString stringByAppendingFormat:@"%c%@", questionMarkRange.location == NSNotFound ? '?' : '&', encodedParameters];
    }
    
    return [self initWithString:URLString relativeToURL:baseURL];
}


+ (instancetype)umk_URLWithString:(NSString *)URLString parameters:(NSDictionary *)parameters
{
    return [[self alloc] umk_initWithString:URLString parameters:parameters];
}


+ (instancetype)umk_URLWithString:(NSString *)URLString parameters:(NSDictionary *)parameters relativeToURL:(NSURL *)baseURL
{
    return [[self alloc] umk_initWithString:URLString parameters:parameters relativeToURL:baseURL];
}

@end
