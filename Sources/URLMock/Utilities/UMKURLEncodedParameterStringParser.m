//
//  UMKURLEncodedParameterStringParser.m
//  URLMock
//
//  Created by Prachi Gauriar on 1/5/2014.
//  Copyright (c) 2015 Prachi Gauriar.
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

#import "UMKURLEncodedParameterStringParser.h"

#import <URLMock/NSDictionary+UMKURLEncoding.h>
#import <URLMock/UMKErrorUtilities.h>

#import "UMKParameterPair.h"


@implementation UMKURLEncodedParameterStringParser

- (instancetype)initWithString:(NSString *)string
{
    NSParameterAssert(string);

    self = [super init];
    if (self) {
        _string = [string copy];
    }

    return self;
}


- (instancetype)initWithString:(NSString *)string encoding:(NSStringEncoding)encoding
{
    return [self initWithString:string];
}


- (NSStringEncoding)encoding
{
    return NSUTF8StringEncoding;
}


- (NSDictionary<NSString *, id> * _Nullable)parse
{
    NSMutableDictionary<NSString *, id> *dictionary = [[NSMutableDictionary alloc] init];
    for (UMKParameterPair *pair in self.parameterPairs) {
        // If an error occurs while parsing the pair, return nil. Since there are some crazy things that
        // could happen, like taking something that had a string value and indexing into it like an array,
        // catch exceptions too
        @try {
            if (![self addObjectForKey:pair.key value:pair.value toDictionary:dictionary]) {
                return nil;
            }
        } @catch (NSException *exception) {
            return nil;
        }
    }
    
    return dictionary;
}


- (NSArray<UMKParameterPair *> *)parameterPairs
{
    NSArray<NSString *> *keyValueStrings = [self.string componentsSeparatedByString:@"&"];
    NSMutableArray<UMKParameterPair *> *pairs = [[NSMutableArray alloc] initWithCapacity:keyValueStrings.count];
    
    for (NSString *keyValueString in keyValueStrings) {
        NSArray<NSString *> *keyValuePair = [keyValueString componentsSeparatedByString:@"="];
        NSString *key = [keyValuePair[0] stringByRemovingPercentEncoding];
        id value = (keyValuePair.count > 1) ? [keyValuePair[1] stringByRemovingPercentEncoding] : [NSNull null];
        [pairs addObject:[[UMKParameterPair alloc] initWithKey:key value:value]];
    }

    return pairs;
}


- (BOOL)addObjectForKey:(NSString *)key value:(id)value toDictionary:(NSMutableDictionary *)dictionary
{
    if (key.length == 0) {
        return YES;
    }
    
    // Split the key based on the first non-bracket string
    NSString *leftKey = @"";
    NSString *rightKey = @"";
    
    NSTextCheckingResult *leftKeyResult = [[self.class keyRegularExpression] firstMatchInString:key options:0 range:NSMakeRange(0, key.length)];

    if (leftKeyResult.numberOfRanges > 1) {
        leftKey = [key substringWithRange:[leftKeyResult rangeAtIndex:1]];
        
        NSRange patternMatchRange = [leftKeyResult rangeAtIndex:0];
        rightKey = [key substringFromIndex:patternMatchRange.location + patternMatchRange.length];
    }
    
    if (leftKey.length == 0) {
        return YES;
    }

    // Check if the right key contains an array indicator ([]) with additional keys
    NSString *arrayKey = nil;
    if (rightKey.length != 0) {
        NSTextCheckingResult *nestedArrayResult = [[self.class nestedArrayRegularExpression] firstMatchInString:rightKey
                                                                                                        options:0
                                                                                                          range:NSMakeRange(0, rightKey.length)];
        NSTextCheckingResult *arrayResult = [[self.class arrayRegularExpression] firstMatchInString:rightKey
                                                                                            options:0
                                                                                              range:NSMakeRange(0, rightKey.length)];
        
        if (nestedArrayResult.numberOfRanges > 1) {
            arrayKey = [rightKey substringWithRange:[nestedArrayResult rangeAtIndex:1]];
        } else if (arrayResult.numberOfRanges > 1) {
            arrayKey = [rightKey substringWithRange:[arrayResult rangeAtIndex:1]];
        }
    }
    
    if (rightKey.length == 0) {
        // If there is no right key, then just set the value. If we already have a value for the key,
        // make a set of the values
        id currentValue = dictionary[leftKey];
        if (currentValue) {
            if ([currentValue isKindOfClass:[NSSet class]]) {
                NSSet *currentSet = currentValue;
                value = [currentSet setByAddingObject:value];
            } else {
                value = [NSSet setWithObjects:currentValue, value, nil];
            }
        }

        dictionary[leftKey] = value;
    } else if ([rightKey isEqualToString:@"[]"]) {
        // We have an array indicator with no additional keys, if we already have an
        // array for the key append the value, otherwise add a new array containing the value
        id array = dictionary[leftKey];
        if (!array) {
            array = [[NSMutableArray alloc] init];
        }
        
        if (![array isKindOfClass:[NSMutableArray class]]) {
            // If this isn't an array then something went horribly wrong
            return NO;
        }
        
        [array addObject:value];
        dictionary[leftKey] = array;
    } else if (arrayKey) {
        // We have an array indicator with additional keys
        id array = dictionary[leftKey];
        if (!array) {
            array = [[NSMutableArray alloc] init];
        }
        
        if (![array isKindOfClass:[NSMutableArray class]]) {
            // If this isn't an array then we're in trouble
            return NO;
        }
        
        NSMutableDictionary *nestedDictionary;
        if ([[array lastObject] isKindOfClass:[NSMutableDictionary class]] && ![[array lastObject] objectForKey:arrayKey]) {
            // If the array already has a dictionary that doesn't contain the current arrayKey we will continue to use that same dictionary
            nestedDictionary = [array lastObject];
            [self addObjectForKey:arrayKey value:value toDictionary:nestedDictionary];
        } else {
            nestedDictionary = [[NSMutableDictionary alloc] init];
            [self addObjectForKey:arrayKey value:value toDictionary:nestedDictionary];
            [array addObject:nestedDictionary];
        }

        dictionary[leftKey] = array;
    } else {
        // We have a nested key, so recurse on that
        id subDictionary = dictionary[leftKey];
        if (!subDictionary) {
            subDictionary = [[NSMutableDictionary alloc] init];
        }
        
        if (![subDictionary isKindOfClass:[NSMutableDictionary class]]) {
            // If this isn't a dictionary we need to bail out
            return NO;
        }
        
        [self addObjectForKey:rightKey value:value toDictionary:subDictionary];
        dictionary[leftKey] = subDictionary;
    }

    return YES;
}


#pragma mark - Regular Expressions

+ (NSRegularExpression *)keyRegularExpression
{
    static NSRegularExpression *keyRegularExpression;
 
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        
        // Matches the left most key (the first non-bracket substring which could possibly be contained by brackets)
        keyRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"\\A[\\[\\]]*([^\\[\\]]+)\\]*" options:0 error:&error];
        
        if (!keyRegularExpression) {
            NSLog(@"Error creating regular expression: %@", [error description]);
        }
    });
    
    return keyRegularExpression;
}


+ (NSRegularExpression *)nestedArrayRegularExpression
{
    static NSRegularExpression *nestedArrayRegularExpression;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;

        // Matches an array indicator ([]) followed by a nested dictionary indicator ([x])
        nestedArrayRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"^\\[\\]\\[([^\\[\\]]+)\\]$" options:0 error:&error];
        
        if (!nestedArrayRegularExpression) {
            NSLog(@"Error creating regular expression: %@", [error description]);
        }
    });
    
    return nestedArrayRegularExpression;
}


+ (NSRegularExpression *)arrayRegularExpression
{
    static NSRegularExpression *arrayRegularExpression;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;

        // Matches an array indicator ([]) followed by additional keys
        arrayRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"^\\[\\](.+)$" options:0 error:&error];
        
        if (!arrayRegularExpression) {
            NSLog(@"Error creating regular expression: %@", [error description]);
        }
    });
    
    return arrayRegularExpression;
}

@end
