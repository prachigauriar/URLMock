//
//  UMKPatternMatchingMockRequest.m
//  URLMock
//
//  Created by Prachi Gauriar on 6/25/2014.
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

#import "UMKPatternMatchingMockRequest.h"

#import <SOCKit/SOCKit.h>


@interface UMKPatternMatchingMockRequest ()

@property (nonatomic, strong, readonly) SOCPattern *pattern;

@end


#pragma mark

@implementation UMKPatternMatchingMockRequest

- (instancetype)init
{
    return [self initWithURLPattern:nil HTTPMethods:nil responderGenerationBlock:nil];
}


- (instancetype)initWithURLPattern:(NSString *)URLPattern responderGenerationBlock:(UMKPatternMatchingResponderGenerationBlock)responderGenerationBlock
{
    return [self initWithURLPattern:URLPattern HTTPMethods:nil responderGenerationBlock:responderGenerationBlock];
}


- (instancetype)initWithURLPattern:(NSString *)URLPattern
                       HTTPMethods:(NSArray *)HTTPMethods
          responderGenerationBlock:(UMKPatternMatchingResponderGenerationBlock)responderGenerationBlock
{
    NSParameterAssert(URLPattern);
    NSParameterAssert(responderGenerationBlock);

    self = [super init];
    if (self) {
        _URLPattern = [URLPattern copy];
        _pattern = [[SOCPattern alloc] initWithString:_URLPattern];
        _responderGenerationBlock = [responderGenerationBlock copy];
        _HTTPMethods = HTTPMethods ? [NSSet setWithArray:[HTTPMethods valueForKey:@"uppercaseString"]] : nil;
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
    if (self.HTTPMethods && ![self.HTTPMethods containsObject:request.HTTPMethod.uppercaseString]) {
        return NO;
    }

    NSString *URLString = [self canonicalURLStringExcludingQueryForURL:request.URL];
    return [self.pattern stringMatches:URLString] && (self.requestMatchingBlock ? self.requestMatchingBlock(request) : YES);
}


- (id<UMKMockURLResponder>)responderForURLRequest:(NSURLRequest *)request
{
    NSString *URLString = [self canonicalURLStringExcludingQueryForURL:request.URL];
    return self.responderGenerationBlock(request, [self.pattern parameterDictionaryFromSourceString:URLString]);
}


- (BOOL)shouldRemoveAfterServicingRequest:(NSURLRequest *)request
{
    return NO;
}

@end
