//
//  UMOMockHTTPResponse.m
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

#import <URLMock/UMOMockHTTPResponse.h>

@implementation UMOMockHTTPResponse

- (instancetype)init
{
    self = [super init];
    if (self) {
        _headers = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}


+ (instancetype)mockResponseWithError:(NSError *)error
{
    UMOMockHTTPResponse *response = [[self alloc] init];
    response.error = error;
    return response;
}


+ (instancetype)mockResponseWithStatusCode:(NSUInteger)status body:(NSData *)data
{
    return [self mockResponseWithStatusCode:status body:data headers:nil];
}


+ (instancetype)mockResponseWithStatusCode:(NSUInteger)status body:(NSData *)body headers:(NSDictionary *)headers
{
    UMOMockHTTPResponse *response = [[self alloc] init];
    response.statusCode = status;
    response.body = body;
    response.headers = headers;
    return response;
}


@end