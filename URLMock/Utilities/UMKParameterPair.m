//
//  UMKParameterPair.m
//  URLMock
//
//  Created by Prachi Gauriar on 1/7/2014.
//  Copyright (c) 2014 Two Toasters, LLC, (c) 2013 AFNetworking (http://afnetworking.com/)
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

#import <URLMock/UMKParameterPair.h>


#pragma mark Constants

static const NSString *const kUMKParameterPairEscapedCharacters = @":/?&=;+!@#$()',*";


#pragma mark -

@implementation UMKParameterPair

- (instancetype)initWithKey:(NSString *)key value:(id)value
{
    self = [super init];
    if (self) {
        _key = key;
        _value = value;
    }
    
    return self;
}


- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)encoding
{
    NSString *stringValue = [self URLEncodedKeyStringWithEncoding:encoding];
    if (self.value && self.value != [NSNull null]) {
        stringValue = [stringValue stringByAppendingFormat:@"=%@", [self URLEncodedValueStringWithEncoding:encoding]];
    }
    
    return stringValue;
}


- (NSString *)URLEncodedKeyStringWithEncoding:(NSStringEncoding)encoding
{
    static NSString *const kUMKUnescapedCharacters = @".[]";
	return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                     (__bridge CFStringRef)self.key,
                                                                     (__bridge CFStringRef)kUMKUnescapedCharacters,
                                                                     (__bridge CFStringRef)kUMKParameterPairEscapedCharacters,
                                                                     CFStringConvertNSStringEncodingToEncoding(encoding)));
}


- (NSString *)URLEncodedValueStringWithEncoding:(NSStringEncoding)encoding
{
    return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                     (__bridge CFStringRef)[self.value description],
                                                                     NULL,
                                                                     (__bridge CFStringRef)kUMKParameterPairEscapedCharacters,
                                                                     CFStringConvertNSStringEncodingToEncoding(encoding)));
}

@end
