//
//  UMKPatternMatchingMockRequest.m
//  URLMock
//
//  Created by Prachi Gauriar on 6/25/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import "UMKPatternMatchingMockRequest.h"

#import <SOCKit/SOCKit.h>

@interface UMKPatternMatchingMockRequest ()

@property (nonatomic, strong, readonly) SOCPattern *pattern;

@end


@implementation UMKPatternMatchingMockRequest

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


- (instancetype)initWithURLPattern:(NSString *)URLPattern responderGenerationBlock:(UMKPatternMatchingResponderGenerationBlock)responderGenerationBlock
{
    NSParameterAssert(URLPattern);
    NSParameterAssert(responderGenerationBlock);

    self = [super init];
    if (self) {
        _URLPattern = [URLPattern copy];
        _pattern = [[SOCPattern alloc] initWithString:_URLPattern];
        _responderGenerationBlock = [responderGenerationBlock copy];
    }

    return self;
}


- (NSString *)canonicalURLStringExcludingQueryForURL:(NSURL *)URL
{
    NSURL *canonicalURL = [UMKMockURLProtocol canonicalURLForURL:URL];
    return [[canonicalURL.absoluteString componentsSeparatedByString:@"?"] firstObject];
}


- (BOOL)matchesURLRequest:(NSURLRequest *)request
{
    NSString *URLString = [self canonicalURLStringExcludingQueryForURL:request.URL];
    return [self.pattern stringMatches:URLString] && (self.requestMatchingBlock ? self.requestMatchingBlock(request) : YES);
}


- (id<UMKMockURLResponder>)responderForURLRequest:(NSURLRequest *)request
{
    NSString *URLString = [self canonicalURLStringExcludingQueryForURL:request.URL];
    return self.responderGenerationBlock(request, [self.pattern parameterDictionaryFromSourceString:URLString]);
}

@end


@implementation UMKPatternMatchingMockHTTPRequest

- (NSString *)HTTPMethod
{
    return _HTTPMethod ? _HTTPMethod : kUMKMockHTTPRequestGetMethod;
}


- (BOOL)matchesURLRequest:(NSURLRequest *)request
{
    return (request.HTTPMethod && [self.HTTPMethod caseInsensitiveCompare:request.HTTPMethod] == NSOrderedSame) && [super matchesURLRequest:request];
}

@end
