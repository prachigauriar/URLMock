//
//  UMKMockHTTPMessage.m
//  URLMock
//
//  Created by Prachi Gauriar on 11/9/2013.
//  Copyright (c) 2015 Ticketmaster Entertainment, Inc. All rights reserved.
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

#import <URLMock/UMKMockHTTPMessage.h>

#import <URLMock/NSDictionary+UMKURLEncoding.h>
#import <URLMock/NSURLRequest+UMKHTTPConvenienceMethods.h>
#import <URLMock/UMKErrorUtilities.h>


#pragma mark Constants

NSString *const kUMKMockHTTPMessageAcceptsHeaderField = @"Accepts";
NSString *const kUMKMockHTTPMessageContentTypeHeaderField = @"Content-Type";
NSString *const kUMKMockHTTPMessageCookieHeaderField = @"Cookie";
NSString *const kUMKMockHTTPMessageSetCookieHeaderField = @"Set-Cookie";

NSString *const kUMKMockHTTPMessageJSONContentTypeHeaderValue = @"application/json";
NSString *const kUMKMockHTTPMessageUTF8JSONContentTypeHeaderValue = @"application/json; charset=utf-8";
NSString *const kUMKMockHTTPMessageWWWFormURLEncodedContentTypeHeaderValue = @"application/x-www-form-urlencoded";
NSString *const kUMKMockHTTPMessageUTF8WWWFormURLEncodedContentTypeHeaderValue = @"application/x-www-form-urlencoded; charset=utf-8";


#pragma mark - Custom NSPointerFunctions

static NSUInteger UMKCaseInsensitiveStringHashFunction(const void *item, NSUInteger (*size)(const void *item))
{
    return [[(__bridge NSString *)item lowercaseString] hash];
}


static BOOL UMKCaseInsensitiveStringIsEqualFunction(const void *item1, const void *item2, NSUInteger (*size)(const void *item))
{
    return [(__bridge NSString *)item1 caseInsensitiveCompare:(__bridge NSString *)item2] == NSOrderedSame;
}


#pragma mark -

@implementation UMKMockHTTPMessage

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSPointerFunctionsOptions keyOptions = NSPointerFunctionsCopyIn | NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality;
        NSPointerFunctions *keyFunctions = [NSPointerFunctions pointerFunctionsWithOptions:keyOptions];
        keyFunctions.hashFunction = UMKCaseInsensitiveStringHashFunction;
        keyFunctions.isEqualFunction = UMKCaseInsensitiveStringIsEqualFunction;

        NSPointerFunctionsOptions valueOptions = NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPersonality;
        NSPointerFunctions *valueFunctions = [NSPointerFunctions pointerFunctionsWithOptions:valueOptions];
        _headers = [[NSMapTable alloc] initWithKeyPointerFunctions:keyFunctions valuePointerFunctions:valueFunctions capacity:16];
    }
    
    return self;
}


#pragma mark - Headers

- (NSDictionary *)headers
{
    return [_headers dictionaryRepresentation];
}


- (void)setHeaders:(NSDictionary *)headers
{
    [_headers removeAllObjects];
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *field, NSString *value, BOOL *stop) {
        [self setValue:value forHeaderField:field];
    }];
}


- (NSString *)valueForHeaderField:(NSString *)field
{
    return [_headers objectForKey:field];
}


- (void)setValue:(NSString *)value forHeaderField:(NSString *)field
{
    if (!value) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"nil value" userInfo:nil];
    } else if (!field) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"nil field" userInfo:nil];
    }

    if ([_headers objectForKey:field]) {
        [_headers removeObjectForKey:field];
    }
    
    [_headers setObject:value forKey:field];
}


- (void)removeValueForHeaderField:(NSString *)field
{
    [_headers removeObjectForKey:field];
}


- (BOOL)headersAreEqualToHeadersOfRequest:(NSURLRequest *)request
{
    return [request umk_HTTPHeadersAreEqualToHeaders:self.headers];
}


#pragma mark - Body

- (id)JSONObjectFromBody
{
    return self.body ? [NSJSONSerialization JSONObjectWithData:self.body options:0 error:NULL] : nil;
}


- (void)setBodyWithJSONObject:(id)JSONObject
{
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:JSONObject options:0 error:NULL];
    if (!JSONData) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:UMKExceptionString(self, _cmd, @"Invalid JSON object")
                                     userInfo:nil];
    }
    
    self.body = JSONData;
    if (![self valueForHeaderField:kUMKMockHTTPMessageContentTypeHeaderField]) {
        [self setValue:kUMKMockHTTPMessageUTF8JSONContentTypeHeaderValue forHeaderField:kUMKMockHTTPMessageContentTypeHeaderField];
    }
}


- (NSDictionary *)parametersFromURLEncodedBody
{
    return self.body ? [NSDictionary umk_dictionaryWithURLEncodedParameterString:[self stringFromBody]] : nil;
}


- (void)setBodyByURLEncodingParameters:(NSDictionary *)parameters
{
    NSParameterAssert(parameters);
    
    [self setBodyWithString:[parameters umk_URLEncodedParameterString]];
    if (![self valueForHeaderField:kUMKMockHTTPMessageContentTypeHeaderField]) {
        [self setValue:kUMKMockHTTPMessageUTF8WWWFormURLEncodedContentTypeHeaderValue forHeaderField:kUMKMockHTTPMessageContentTypeHeaderField];
    }
}


- (NSString *)stringFromBody
{
    return [self stringFromBodyWithEncoding:NSUTF8StringEncoding];
}


- (void)setBodyWithString:(NSString *)string
{
    [self setBodyWithString:string encoding:NSUTF8StringEncoding];
}


- (NSString *)stringFromBodyWithEncoding:(NSStringEncoding)encoding
{
    return [[NSString alloc] initWithData:self.body encoding:encoding];
}


- (void)setBodyWithString:(NSString *)string encoding:(NSStringEncoding)encoding
{
    self.body = [string dataUsingEncoding:encoding];
}

@end
