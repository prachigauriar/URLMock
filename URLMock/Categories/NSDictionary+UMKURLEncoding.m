//
//  NSDictionary+UMKURLEncoding.m
//  URLMock
//
//  Created by Prachi Gauriar on 1/5/2014.
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

#import <URLMock/NSDictionary+UMKURLEncoding.h>

#import <URLMock/UMKParameterPair.h>
#import <URLMock/UMKURLEncodedParameterStringParser.h>


#pragma mark UMKURLEncoding Informal Protocol

@interface NSObject (UMKURLEncoding)

/*!
 @abstract Returns an array of parameter pairs whose keys are the one specified and whose
     values represent the values in the receiver.
 @result An array of parameter pairs.
 */
- (NSArray *)umk_parameterPairsWithKey:(NSString *)key;

/*!
 @abstract Returns whether the object is a valid URL encoded parameter object.
 @discussion This is used to verify if a dictionary is a valid parameter object. The following objects are
     valid: strings, arrays containing only strings and having at least one element, sets containing only
     strings and having at least two elements, and dictionaries whose keys are strings and whose values are
     valid URL encoded objects (including other dictionaries).
 @result Whether the object is a valid URL encoded parameter object.
 */
- (BOOL)umk_isValidURLEncodedParameterObject;

@end


#pragma mark -

@implementation NSObject (UMKURLEncoding)

- (NSArray *)umk_parameterPairsWithKey:(NSString *)key
{
    return @[ [[UMKParameterPair alloc] initWithKey:key value:self] ];
}


- (BOOL)umk_isValidURLEncodedParameterObject
{
    return NO;
}

@end


#pragma mark -

@implementation NSArray (UMKURLEncoding)

- (NSArray *)umk_parameterPairsWithKey:(NSString *)key
{
    NSMutableArray *pairs = [[NSMutableArray alloc] initWithCapacity:self.count];
    NSString *nestedKey = [NSString stringWithFormat:@"%@[]", key];
    for (id value in self) {
        [pairs addObjectsFromArray:[value umk_parameterPairsWithKey:nestedKey]];
    }
    
    return pairs;
}

- (BOOL)umk_isValidURLEncodedParameterObject
{
    if ([self count] == 0) {
        return NO;
    }
    
    for (id element in self) {
        if (![element isKindOfClass:[NSString class]]) {
            return NO;
        }
    }
    
    return YES;
}

@end


#pragma mark -

@implementation NSDictionary (UMKURLEncoding)


+ (instancetype)umk_dictionaryWithURLEncodedParameterString:(NSString *)string
{
    NSParameterAssert(string);
    UMKURLEncodedParameterStringParser *parser = [[UMKURLEncodedParameterStringParser alloc] initWithString:string];
    return [parser parse];
}


+ (instancetype)umk_dictionaryWithURLEncodedParameterString:(NSString *)string encoding:(NSStringEncoding)encoding
{
    return [self umk_dictionaryWithURLEncodedParameterString:string];
}


- (BOOL)umk_isValidURLEncodedParameterObject
{
    for (id key in self) {
        id value = [self objectForKey:key];
        if (![key isKindOfClass:[NSString class]] || ![value umk_isValidURLEncodedParameterObject]) {
            return NO;
        }
    }
    
    return YES;
}


- (BOOL)umk_isValidURLEncodedParameterDictionary
{
    return [self umk_isValidURLEncodedParameterObject];
}


- (NSString *)umk_URLEncodedParameterString
{
    NSArray *pairs = [self umk_parameterPairsWithKey:nil];
    NSMutableArray *pairStrings = [[NSMutableArray alloc] initWithCapacity:pairs.count];

    for (UMKParameterPair *pair in pairs) {
        [pairStrings addObject:[pair URLEncodedStringValue]];
    }

    return [pairStrings componentsJoinedByString:@"&"];
}


- (NSString *)umk_URLEncodedParameterStringWithEncoding:(NSStringEncoding)encoding
{
    return [self umk_URLEncodedParameterString];
}


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


#pragma mark -

@implementation NSSet (UMKURLEncoding)

- (NSArray *)umk_parameterPairsWithKey:(NSString *)key
{
    NSMutableArray *pairs = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (id element in self) {
        [pairs addObjectsFromArray:[element umk_parameterPairsWithKey:key]];
    }
    
    return pairs;
}


- (BOOL)umk_isValidURLEncodedParameterObject
{
    if ([self count] < 2) {
        return NO;
    }
    
    for (id element in self) {
        if (![element isKindOfClass:[NSString class]]) {
            return NO;
        }
    }

    return YES;
}

@end


#pragma mark -

@implementation NSString (UMKURLEncoding)

- (BOOL)umk_isValidURLEncodedParameterObject
{
    return YES;
}

@end
