//
//  UMKURLEncodedParameterStringParser.m
//  URLMock
//
//  Created by Prachi Gauriar on 1/5/2014.
//  Copyright (c) 2014 Prachi Gauriar. All rights reserved.
//

#import "UMKURLEncodedParameterStringParser.h"
#import <URLMock/UMKErrorUtilities.h>
#import <URLMock/UMKURLEncoding.h>

@implementation UMKURLEncodedParameterStringParser

- (instancetype)init
{
    return [self initWithString:nil encoding:NSUTF8StringEncoding];
}


- (instancetype)initWithString:(NSString *)string encoding:(NSStringEncoding)encoding
{
    NSParameterAssert(string);
    self = [super init];
    if (self) {
        _string = string;
        _encoding = encoding;
    }
    
    return self;
}


- (NSDictionary *)parse
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    for (UMKParameterPair *pair in self.parameterPairs) {
        // If an error occurs while parsing the pair, return nil. Since there are some crazy things that
        // could happen, like taking something that had a string value and indexing into it like an array,
        // catch exceptions too
        @try {
            if (![self addObjectForParameterPair:pair toDictionary:dictionary]) {
                return nil;
            }
        } @catch (NSException *exception) {
            return nil;
        }
    }
    
    return dictionary;
}


- (NSArray *)parameterPairs
{
    NSArray *keyValueStrings = [self.string componentsSeparatedByString:@"&"];
    NSMutableArray *pairs = [[NSMutableArray alloc] initWithCapacity:keyValueStrings.count];
    
    for (NSString *keyValueString in keyValueStrings) {
        NSArray *keyValuePair = [keyValueString componentsSeparatedByString:@"="];
        id key = [keyValuePair[0] stringByReplacingPercentEscapesUsingEncoding:self.encoding];
        id value = (keyValuePair.count > 1) ? [keyValuePair[1] stringByReplacingPercentEscapesUsingEncoding:self.encoding] : [NSNull null];
        [pairs addObject:[[UMKParameterPair alloc] initWithKey:key value:value]];
    }

    return pairs;
}


- (BOOL)addObjectForParameterPair:(UMKParameterPair *)pair toDictionary:(NSMutableDictionary *)dictionary
{
    NSScanner *keyScanner = [NSScanner scannerWithString:pair.key];
    NSString *key = nil;
    id object = dictionary;

    // Before we get into the loop, read the first key
    if (![keyScanner scanUpToString:@"[" intoString:&key]) {
        return NO;
    }
    
    while (![keyScanner isAtEnd]) {
        // We should already be at the next [, so if either of these scans fail, we have a malformed string
        if ([keyScanner scanUpToString:@"[" intoString:NULL] || ![keyScanner scanString:@"[" intoString:NULL]) {
            return NO;
        }

        NSString *nextKey = nil;
        id nextObject = nil;
        
        // If we scanned something before the next ], our next object will be a dictionary. Otherwise, it will be an array
        Class nextObjectClass = [keyScanner scanUpToString:@"]" intoString:&nextKey] ? [NSMutableDictionary class] : [NSMutableArray class];

        //
        if (key) {
            // Previous object was a dictionary
            if (!(nextObject = [object objectForKey:key])) {
                nextObject = [[nextObjectClass alloc] init];
                [object setObject:nextObject forKey:key];
            }
        } else {
            // Previous object was an array
            if (!(nextObject = [object lastObject])) {
                nextObject = [[nextObjectClass alloc] init];
                [object addObject:nextObject];
            }
        }
        
        // We should have a ], or else this is a malformed key
        if (![keyScanner scanString:@"]" intoString:NULL]) {
            return NO;
        }
        
        key = nextKey;
        object = nextObject;
    }
    
    if (key) {
        // If there's an existing value for this key, we need to put a set in its place
        id value = [object objectForKey:key];
        if (value) {
            // If the value isn't already a set, create a new set with the existing value
            if (![value isKindOfClass:[NSMutableSet class]]) {
                value = [NSMutableSet setWithObject:value];
            }
            
            // Add the new value to the set and set it as key's value
            [value addObject:pair.value];
            [object setObject:value forKey:key];
        } else {
            [object setObject:pair.value forKey:key];
        }
    } else {
        [object addObject:pair.value];
    }
    
    return YES;
}


@end
