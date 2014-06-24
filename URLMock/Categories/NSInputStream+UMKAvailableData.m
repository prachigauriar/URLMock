//
//  NSInputStream+UMKAvailableData.m
//  URLMock
//
//  Created by Prachi Gauriar on 6/23/2014.
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

#import "NSInputStream+UMKAvailableData.h"

@implementation NSInputStream (UMKAvailableData)

- (NSData *)umk_availableData
{
    const NSUInteger kBufferSize = 4096;
    uint8_t buffer[kBufferSize];

    NSMutableData *data = [[NSMutableData alloc] init];
    [self open];

    while (self.hasBytesAvailable) {
        NSInteger bytesRead = [self read:buffer maxLength:kBufferSize];
        if (bytesRead > 0) {
            NSData *readData = [NSData dataWithBytes:buffer length:bytesRead];
            [data appendData:readData];
        } else if (bytesRead < 0) {
            return nil;
        } else {
            break;
        }
    }

    [self close];
    return [data copy];
}

@end
