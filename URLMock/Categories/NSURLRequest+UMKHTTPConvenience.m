//
//  NSURLRequest+UMKHTTPConvenience.m
//  URLMock
//
//  Created by Prachi Gauriar on 6/25/2014.
//  Copyright (c) 2014 Two Toasters, LLC.
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

#import "NSURLRequest+UMKHTTPConvenience.h"

@implementation NSURLRequest (UMKHTTPConvenience)

- (NSData *)umk_HTTPBodyData
{
    if (!self.HTTPBodyStream) {
        return self.HTTPBody;
    }

    const NSUInteger kBufferSize = 4096;
    uint8_t buffer[kBufferSize];

    NSMutableData *data = [[NSMutableData alloc] init];
    NSInputStream *bodyStream = [[self mutableCopy] HTTPBodyStream];

    [bodyStream open];

    while (bodyStream.hasBytesAvailable) {
        NSInteger bytesRead = [bodyStream read:buffer maxLength:kBufferSize];
        if (bytesRead > 0) {
            NSData *readData = [NSData dataWithBytes:buffer length:bytesRead];
            [data appendData:readData];
        } else if (bytesRead < 0) {
            return nil;
        } else {
            break;
        }
    }

    [bodyStream close];
    return [data copy];
}


- (BOOL)umk_HTTPHeadersAreEqualToHeaders:(NSDictionary *)headers
{
    if (!headers || headers.count != self.allHTTPHeaderFields.count) {
        return NO;
    }

    for (NSString *key in headers) {
        if (![[self valueForHTTPHeaderField:key] isEqualToString:headers[key]]) {
            return NO;
        }
    }

    return YES;
}

@end
