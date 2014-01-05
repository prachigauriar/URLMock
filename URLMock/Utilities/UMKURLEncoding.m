//
//  UMKURLEncoding.m
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

@implementation NSDictionary (UMKURLEncoding)

+ (instancetype)umk_dictionaryWithURLEncodedParameterString:(NSString *)string
{
    return [self umk_dictionaryWithURLEncodedParameterString:string encoding:NSUTF8StringEncoding];
}


+ (instancetype)umk_dictionaryWithURLEncodedParameterString:(NSString *)string encoding:(NSStringEncoding)encoding
{
    NSCParameterAssert(string);
    
    NSArray *keyValueStrings = [string componentsSeparatedByString:@"&"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:keyValueStrings.count];
    
    for (NSString *keyValueString in keyValueStrings) {
        NSArray *keyValuePair = [keyValueString componentsSeparatedByString:@"="];
        NSString *key = [keyValuePair[0] stringByReplacingPercentEscapesUsingEncoding:encoding];
        dictionary[key] = (keyValuePair.count > 1) ? [keyValuePair[1] stringByReplacingPercentEscapesUsingEncoding:encoding] : [NSNull null];
    }
    
    return dictionary;
}


- (NSString *)umk_URLEncodedParameterString
{
    return [self umk_URLEncodedParameterStringUsingEncoding:NSUTF8StringEncoding];
}


- (NSString *)umk_URLEncodedParameterStringUsingEncoding:(NSStringEncoding)encoding
{
    NSArray *pairs = [self umk_parameterPairsWithKey:nil];
    NSMutableArray *pairStrings = [[NSMutableArray alloc] initWithCapacity:pairs.count];
    
    for (UMKParameterPair *pair in pairs) {
        [pairStrings addObject:[pair URLEncodedStringValueWithEncoding:encoding]];
    }
    
    return [pairStrings componentsJoinedByString:@"&"];
}

@end


#pragma mark - UMKParameterPair

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


#pragma mark - UMKParameterPairs categories

@implementation NSObject (UMKParameterPairs)

- (NSArray *)umk_parameterPairsWithKey:(NSString *)key
{
    return @[ [[UMKParameterPair alloc] initWithKey:key value:self] ];
}

@end


@implementation NSArray (UMKParameterPairs)

- (NSArray *)umk_parameterPairsWithKey:(NSString *)key
{
    NSMutableArray *pairs = [[NSMutableArray alloc] initWithCapacity:self.count];
    NSString *nestedKey = [NSString stringWithFormat:@"%@[]", key];
    for (id value in self) {
        [pairs addObjectsFromArray:[value umk_parameterPairsWithKey:nestedKey]];
    }
    
    return pairs;
}

@end


@implementation NSDictionary (UMKParameterPairs)

- (NSArray *)umk_parameterPairsWithKey:(NSString *)key
{
    NSArray *sortedNestedKeys = [[self allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 description] caseInsensitiveCompare:[obj2 description]];
    }];
        
    NSMutableArray *pairs = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (id nestedKey in sortedNestedKeys) {
        NSString *parameterPairKey = key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey;
        id value = self[nestedKey];
        [pairs addObjectsFromArray:[value umk_parameterPairsWithKey:parameterPairKey]];
    }

    return pairs;
}

@end


@implementation NSSet (UMKParameterPairs)

- (NSArray *)umk_parameterPairsWithKey:(NSString *)key
{
    NSMutableArray *pairs = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (id element in self) {
        [pairs addObjectsFromArray:[element umk_parameterPairsWithKey:key]];
    }
    
    return pairs;
}

@end
