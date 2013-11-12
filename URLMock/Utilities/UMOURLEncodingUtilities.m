//
//  UMOURLEncodingUtilities.m
//  URLMock
//
//  Created by Prachi Gauriar on 11/9/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
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

#import <URLMock/UMOURLEncodingUtilities.h>

// Note: Most of this code was shamelessly taken from AFNetworking.


#pragma mark Constants

static NSString *const kUMOEscapedCharacters = @":/?&=;+!@#$()',*";


#pragma mark - Private Functions

/*!
 @abstract Returns a percent-escaped representation of the string in the specified encoding.
 @discussion This function should be used for percent-escaping keys in URL-encoded parameter lists.
     As such, the following characters are left unescaped: '.', '[', ']'.
 @param key The key string to be encoded.
 @param NSStringEncoding The encoding to use when escaping the string.
 @result A percent-escaped representation of key.
 */
static NSString *UMOPercentEscapedKeyStringWithEncoding(NSString *key, NSStringEncoding encoding)
{
    static NSString *const kUMOUnescapedCharacters = @".[]";
	return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (__bridge CFStringRef)key,
                                                                                 (__bridge CFStringRef)kUMOUnescapedCharacters,
                                                                                 (__bridge CFStringRef)kUMOEscapedCharacters,
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding));
}


/*!
 @abstract Returns a percent-escaped representation of the string in the specified encoding.
 @discussion This function should be used for percent-escaping values in URL-encoded parameter lists. 
     No characters are left unescaped.
 @param value The value string to be encoded.
 @param NSStringEncoding The encoding to use when escaping the string.
 @result A percent-escaped representation of value.
 */
static NSString *UMOPercentEscapedValueStringWithEncoding(NSString *value, NSStringEncoding encoding)
{
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (__bridge CFStringRef)value,
                                                                                 NULL,
                                                                                 (__bridge CFStringRef)kUMOEscapedCharacters,
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding));
}


#pragma mark - Public Functions

NSString *UMOURLEncodedStringForParameters(NSDictionary *parameters)
{
    return UMOURLEncodedStringForParametersUsingEncoding(parameters, NSUTF8StringEncoding);
}


NSString *UMOURLEncodedStringForParametersUsingEncoding(NSDictionary *parameters, NSStringEncoding encoding)
{
    NSMutableArray *encodedPairs = [[NSMutableArray alloc] initWithCapacity:parameters.count];

    NSArray *sortedKeys = [[parameters allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *key in sortedKeys) {
        id value = parameters[key];
        if (value == [NSNull null]) {
            [encodedPairs addObject:UMOPercentEscapedKeyStringWithEncoding(key, encoding)];
        } else {
            NSString *encodedKey = UMOPercentEscapedKeyStringWithEncoding(key, encoding);
            NSString *encodedValue = UMOPercentEscapedValueStringWithEncoding([value description], encoding);
            [encodedPairs addObject:[NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue]];
        }
    }
    
    return [encodedPairs componentsJoinedByString:@"&"];
}


NSDictionary *UMODictionaryForURLEncodedParametersString(NSString *string)
{
    return UMODictionaryForURLEncodedParametersStringUsingEncoding(string, NSUTF8StringEncoding);
}


NSDictionary *UMODictionaryForURLEncodedParametersStringUsingEncoding(NSString *string, NSStringEncoding encoding)
{
    NSArray *keyValueStrings = [string componentsSeparatedByString:@"&"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:keyValueStrings.count];
    
    for (NSString *keyValueString in keyValueStrings) {
        NSArray *keyValuePair = [keyValueString componentsSeparatedByString:@"="];
        NSString *key = [keyValuePair[0] stringByReplacingPercentEscapesUsingEncoding:encoding];
        NSString *value = [keyValuePair[1] stringByReplacingPercentEscapesUsingEncoding:encoding];
        dictionary[key] = value;
    }
    
    return dictionary;
}