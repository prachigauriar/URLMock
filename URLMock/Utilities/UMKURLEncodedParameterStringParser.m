//
//  UMKURLEncodedParameterStringParser.m
//  URLMock
//
//  Created by Prachi Gauriar on 1/5/2014.
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

#import <URLMock/UMKURLEncodedParameterStringParser.h>

#import <URLMock/NSDictionary+UMKURLEncoding.h>
#import <URLMock/UMKErrorUtilities.h>
#import <URLMock/UMKParameterPair.h>

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
        _string = [string copy];
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
    if (pair.key.length == 0) {
        return YES;
    }

    id collection = dictionary;
    NSString *key = nil;

    // Before we get into the loop, read the first key
    NSScanner *keyScanner = [NSScanner scannerWithString:pair.key];
    
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

        // If there's an existing object, set nextObject to that. Otherwise, create a new object for it and add it to the
        // previous object
        if (key) {
            // Previous object was a dictionary
            if (!(nextObject = [collection objectForKey:key])) {
                nextObject = [[nextObjectClass alloc] init];
                [collection setObject:nextObject forKey:key];
            }
        } else {
            // Previous object was an array
            if (!(nextObject = [collection lastObject])) {
                nextObject = [[nextObjectClass alloc] init];
                [collection addObject:nextObject];
            }
        }
        
        // We should have a ], or else this is a malformed key
        if (![keyScanner scanString:@"]" intoString:NULL]) {
            return NO;
        }
        
        key = nextKey;
        collection = nextObject;
    }
    
    if (key) {
        // If the collection isn't a dictionary, return NO
        if (![collection isKindOfClass:[NSMutableDictionary class]]) {
            return NO;
        }

        // If there's an existing value for this key, we need to add the value to a set
        id value = [collection objectForKey:key];
        if (value) {
            // If the value is a set, add the object. If the value is a string, create a new set.
            // Otherwise, something has gone wrong, so return NO.
            if ([value isKindOfClass:[NSMutableSet class]]) {
                if ([value containsObject:pair.value]) {
                    return NO;
                }
                
                [value addObject:pair.value];
            } else if ([value isKindOfClass:[NSString class]]) {
                value = [NSMutableSet setWithObjects:value, pair.value, nil];
                [collection setObject:value forKey:key];
            } else {
                return NO;
            }
        } else {
            [collection setObject:pair.value forKey:key];
        }
    } else {
        if (![collection isKindOfClass:[NSMutableArray class]]) {
            return NO;
        }
        
        [collection addObject:pair.value];
    }
    
    return YES;
}

@end
