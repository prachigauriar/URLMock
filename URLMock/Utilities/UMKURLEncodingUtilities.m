//
//  UMKURLEncodingUtilities.m
//  URLMock
//
//  Created by Prachi Gauriar on 11/9/2013.
//  Copyright (c) 2013 Prachi Gauriar.
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

#import <URLMock/UMKURLEncodingUtilities.h>
#import <URLMock/NSObject+UMKURLEncodedParameterPairs.h>

#pragma mark Constants

static NSString *const kUMKEscapedCharacters = @":/?&=;+!@#$()',*";


#pragma mark - Public Functions

NSString *UMKURLEncodedStringForParameters(NSDictionary *parameters)
{
    return UMKURLEncodedStringForParametersUsingEncoding(parameters, NSUTF8StringEncoding);
}


NSString *UMKURLEncodedStringForParametersUsingEncoding(NSDictionary *parameters, NSStringEncoding encoding)
{
    NSCParameterAssert(parameters);

    NSMutableArray *encodedPairs = [[NSMutableArray alloc] initWithCapacity:parameters.count];

    NSArray *sortedKeys = [[parameters allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *key in sortedKeys) {
        id value = parameters[key];
        if (value == [NSNull null]) {
            [encodedPairs addObject:UMKPercentEscapedKeyStringWithEncoding(key, encoding)];
        } else {
            NSString *encodedKey = UMKPercentEscapedKeyStringWithEncoding(key, encoding);
            NSString *encodedValue = UMKPercentEscapedValueStringWithEncoding([value description], encoding);
            [encodedPairs addObject:[NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue]];
        }
    }
    
    return [encodedPairs componentsJoinedByString:@"&"];
}


NSDictionary *UMKDictionaryForURLEncodedParametersString(NSString *string)
{
    return UMKDictionaryForURLEncodedParametersStringUsingEncoding(string, NSUTF8StringEncoding);
}


NSDictionary *UMKDictionaryForURLEncodedParametersStringUsingEncoding(NSString *string, NSStringEncoding encoding)
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


#pragma mark -

@interface AFQueryStringPair : NSObject

@property (nonatomic, strong) id field;
@property (nonatomic, strong) id value;

- (instancetype)initWithField:(id)field value:(id)value;
- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding;

@end


@implementation AFQueryStringPair

- (instancetype)initWithField:(id)field value:(id)value
{
    self = [super init];
    if (self) {
        self.field = field;
        self.value = value;
    }
    
    return self;
}


- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding
{
    if (!self.value || self.value == [NSNull null]) {
        return UMKPercentEscapedKeyStringWithEncoding([self.field description], stringEncoding);
    }
    
    return [NSString stringWithFormat:@"%@=%@", UMKPercentEscapedKeyStringWithEncoding([self.field description], stringEncoding), UMKPercentEscapedValueStringWithEncoding([self.value description], stringEncoding)];
}

@end


#pragma mark -

NSArray *AFQueryStringPairsFromKeyAndValue(NSString *key, id value)
{
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        // Sort dictionary keys to ensure consistent ordering in query string, which is important when deserializing potentially ambiguous sequences, such as an array of dictionaries
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            id nestedValue = [dictionary objectForKey:nestedKey];
            if (nestedValue) {
                [mutableQueryStringComponents addObjectsFromArray:AFQueryStringPairsFromKeyAndValue((key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey), nestedValue)];
            }
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        for (id nestedValue in array) {
            [mutableQueryStringComponents addObjectsFromArray:AFQueryStringPairsFromKeyAndValue([NSString stringWithFormat:@"%@[]", key], nestedValue)];
        }
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = value;
        for (id obj in set) {
            [mutableQueryStringComponents addObjectsFromArray:AFQueryStringPairsFromKeyAndValue(key, obj)];
        }
    } else {
        [mutableQueryStringComponents addObject:[[AFQueryStringPair alloc] initWithField:key value:value]];
    }
    
    return mutableQueryStringComponents;
}


NSArray *AFQueryStringPairsFromDictionary(NSDictionary *dictionary)
{
    return AFQueryStringPairsFromKeyAndValue(nil, dictionary);
}


static NSString *AFQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding)
{
    NSMutableArray *pairs = [NSMutableArray array];
    for (AFQueryStringPair *pair in AFQueryStringPairsFromDictionary(parameters)) {
        [pairs addObject:[pair URLEncodedStringValueWithEncoding:stringEncoding]];
    }
    
    return [pairs componentsJoinedByString:@"&"];
}



