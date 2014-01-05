//
//  UMKURLEncodedParameterPair.m
//  URLMock
//
//  Created by Prachi Gauriar on 1/5/2014.
//  Copyright (c) 2014 Prachi Gauriar, (c) 2013 AFNetworking (http://afnetworking.com/)
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

#import <URLMock/UMKParameterPair.h>

static const NSString *const kUMKParameterPairEscapedCharacters = @":/?&=;+!@#$()',*";

@implementation UMKParameterPair

- (instancetype)initWithKey:(id)key value:(id)value
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
	return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (__bridge CFStringRef)[self.key description],
                                                                                 (__bridge CFStringRef)kUMKUnescapedCharacters,
                                                                                 (__bridge CFStringRef)kUMKParameterPairEscapedCharacters,
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding));
}


- (NSString *)URLEncodedValueStringWithEncoding:(NSStringEncoding)encoding
{
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (__bridge CFStringRef)[self.value description],
                                                                                 NULL,
                                                                                 (__bridge CFStringRef)kUMKParameterPairEscapedCharacters,
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding));
}

@end


@implementation NSObject (UMKURLEncodedParameterPairs)

- (NSArray *)umk_parameterPairsWithKey:(NSString *)key
{
    return @[ [[UMKParameterPair alloc] initWithKey:key value:self] ];
}

@end


@implementation NSArray (UMKURLEncodedParameterPairs)

- (NSArray *)umk_parameterPairsWithKey:(NSString *)key
{
    NSMutableArray *pairs = [[NSMutableArray alloc] initWithCapacity:self.count];
    NSString *nestedKey = [NSString stringWithFormat:@"%@[]", key];
    for (id element in self) {
        [pairs addObjectsFromArray:[element umk_parameterPairsWithKey:nestedKey]];
    }
    
    return pairs;
}

@end


@implementation NSDictionary (UMKURLEncodedParameterPairs)

- (NSArray *)umk_parameterPairsWithKey:(NSString *)key
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortedNestedKeys = [[self allKeys] sortedArrayUsingDescriptors:@[ sortDescriptor ]];
    
    NSMutableArray *pairs = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (id nestedKey in sortedNestedKeys) {
        NSString *parameterPairKey = key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey;
        [pairs addObjectsFromArray:[[self objectForKey:nestedKey] umk_parameterPairsWithKey:parameterPairKey]];
    }

    return pairs;
}

@end


@implementation NSSet (UMKURLEncodedParameterPairs)

- (NSArray *)umk_parameterPairsWithKey:(NSString *)key
{
    NSMutableArray *pairs = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (id element in self) {
        [pairs addObjectsFromArray:[element umk_parameterPairsWithKey:key]];
    }
    
    return pairs;
}

@end
