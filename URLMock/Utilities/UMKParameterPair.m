//
//  UMKParameterPair.m
//  URLMock
//
//  Created by Prachi Gauriar on 1/7/2014.
//  Copyright (c) 2015 Ticketmaster Entertainment, Inc., (c) 2013 AFNetworking
//      (http://afnetworking.com/). All rights reserved.
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
    return [self URLEncodedStringValue];
}


- (NSString *)URLEncodedStringValue
{
    static NSString *const kUMKKeyAllowedCharacters = @"[]ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~";
    static NSString *const kUMKValueAllowedCharacters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~";

    NSString *stringValue = [self URLEncodedString:self.key allowedCharacters:kUMKKeyAllowedCharacters];
    if (self.value && self.value != [NSNull null]) {
        stringValue = [stringValue stringByAppendingFormat:@"=%@", [self URLEncodedString:[self.value description] allowedCharacters:kUMKValueAllowedCharacters]];
    }
    
    return stringValue;
}


- (NSString *)URLEncodedString:(NSString *)string allowedCharacters:(NSString *)allowedCharacters
{
    NSCharacterSet *allowedCharacterSet = [NSCharacterSet characterSetWithCharactersInString:allowedCharacters];
    return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
}

@end
