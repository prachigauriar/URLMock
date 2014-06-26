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
    return [self initWithURLPattern:nil responderGenerationBlock:nil];
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


#pragma mark -

@interface UMKPatternMatchingMockHTTPRequest ()

@property (nonatomic, copy) NSSet *lowercaseHTTPMethods;

@end


@implementation UMKPatternMatchingMockHTTPRequest

- (BOOL)matchesURLRequest:(NSURLRequest *)request
{
    if (self.lowercaseHTTPMethods && ![self.lowercaseHTTPMethods containsObject:request.HTTPMethod.lowercaseString]) {
        return NO;
    }

    return [super matchesURLRequest:request];
}


- (void)setHTTPMethods:(NSSet *)HTTPMethods
{
    _HTTPMethods = [HTTPMethods copy];
    self.lowercaseHTTPMethods = [HTTPMethods valueForKey:@"lowercaseString"];
}

@end
