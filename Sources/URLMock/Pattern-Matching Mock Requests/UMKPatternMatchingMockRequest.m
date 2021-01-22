//
//  UMKPatternMatchingMockRequest.m
//  URLMock
//
//  Created by Prachi Gauriar on 6/25/2014.
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

#import <URLMock/UMKPatternMatchingMockRequest.h>

#import "SOCKit.h"


@interface UMKPatternMatchingMockRequest ()

/*! The SOCKit pattern associated with the instance’s URL pattern. */
@property (nonatomic, strong, readonly) SOCPattern *pattern;

@end


#pragma mark -

@implementation UMKPatternMatchingMockRequest

- (instancetype)initWithURLPattern:(NSString *)URLPattern
{
    NSParameterAssert(URLPattern);

    self = [super init];
    if (self) {
        _URLPattern = [URLPattern copy];
        _pattern = [[SOCPattern alloc] initWithString:_URLPattern];
    }

    return self;
}


- (void)setHTTPMethods:(NSSet<NSString *> *)HTTPMethods
{
    _HTTPMethods = [HTTPMethods valueForKey:@"uppercaseString"];
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
    if (![self.pattern stringMatches:URLString]) {
        return NO;
    } else if (!self.requestMatchingBlock) {
        return YES;
    }

    NSDictionary<NSString *, NSString *> *parameters = [self.pattern parameterDictionaryFromSourceString:URLString];
    return self.requestMatchingBlock(request, parameters ? parameters : nil);
}


- (id<UMKMockURLResponder>)responderForURLRequest:(NSURLRequest *)request
{
    if (!self.responderGenerationBlock) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"nil responderGenerationBlock" userInfo:nil];
    }

    NSString *URLString = [self canonicalURLStringExcludingQueryForURL:request.URL];
    NSDictionary<NSString *, NSString *> *parameters = [self.pattern parameterDictionaryFromSourceString:URLString];
    return self.responderGenerationBlock(request, parameters ? parameters : nil);
}


- (BOOL)shouldRemoveAfterServicingRequest:(NSURLRequest *)request
{
    return NO;
}

@end
