//
//  UMOMockURLProtocol.m
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

#import <URLMock/UMOMockURLProtocol.h>
#import <URLMock/UMOMockHTTPRequest.h>
#import <URLMock/UMOMockHTTPResponse.h>
#import <URLMock/UMOURLEncodingUtilities.h>

#pragma mark Constants

static NSString *const kUMOMockURLProtocolMockRequestKey = @"UMOMockURLProtocolMockRequestKey";


#pragma mark -

@interface UMOMockURLProtocol ()
@property (readwrite, strong, nonatomic) UMOMockHTTPRequest *mockRequest;
@end


#pragma mark -

static BOOL _interceptsAllRequests = NO;
static BOOL _automaticallyRemovesServicedMockRequests = NO;

@implementation UMOMockURLProtocol

+ (void)enable
{
    [super registerClass:self];
}


+ (void)resetAndEnable
{
    [self reset];
    [self enable];
}


+ (void)reset
{
    [[self expectedMockRequests] removeAllObjects];
    [[self servicedMockRequests] removeAllObjects];
}


+ (void)resetAndDisable
{
    [self reset];
    [self disable];
}


+ (void)disable
{
    [super unregisterClass:self];
}


#pragma mark - Accessors

+ (NSMutableDictionary *)expectedMockRequests
{
    static NSMutableDictionary *expectedMockRequests = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        expectedMockRequests = [[NSMutableDictionary alloc] init];
    });
    
    return expectedMockRequests;
}


+ (NSMutableArray *)expectedMockRequestsForCanonicalURL:(NSURL *)canonicalURL
{
    NSMutableArray *mockRequests = [[self expectedMockRequests] objectForKey:canonicalURL];
    if (!mockRequests) {
        mockRequests = [NSMutableArray array];
        [[self expectedMockRequests] setObject:mockRequests forKey:canonicalURL];
    }
    
    return mockRequests;
}


+ (NSMutableSet *)servicedMockRequests
{
    static NSMutableSet *servicedRequests = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        servicedRequests = [[NSMutableSet alloc] init];
    });
    
    return servicedRequests;
}


+ (BOOL)interceptsAllRequests
{
    return _interceptsAllRequests;
}


+ (void)setInterceptsAllRequests:(BOOL)interceptsAllRequests
{
    _interceptsAllRequests = interceptsAllRequests;
}


+ (BOOL)automaticallyRemovesServicedMockRequests
{
    return _automaticallyRemovesServicedMockRequests;
}


+ (void)setAutomaticallyRemovesServicedMockRequests:(BOOL)removesServicedRequests
{
    _automaticallyRemovesServicedMockRequests = removesServicedRequests;
}


+ (NSURL *)canonicalURLForURL:(NSURL *)URL
{
    // Always use the absolute URL
    NSURL *canonicalURL = URL.absoluteURL;
    NSString *query = canonicalURL.query;
    
    // If there's a query, make sure the order of the parameters is consistent
    if (query) {
        NSString *canonicalQueryString = UMOURLEncodedStringForParameters(UMODictionaryForURLEncodedParametersString(query));
        NSString *URLString = [canonicalURL absoluteString];
        canonicalURL = [NSURL URLWithString:[URLString stringByReplacingCharactersInRange:[URLString rangeOfString:query]
                                                                               withString:canonicalQueryString]];
    }
    
    return canonicalURL;
}


+ (UMOMockHTTPRequest *)expectedMockRequestMatchingURLRequest:(NSURLRequest *)request
{
    NSMutableArray *mockRequests = [self expectedMockRequestsForCanonicalURL:[self canonicalURLForURL:request.URL]];
    NSUInteger index = [mockRequests indexOfObjectPassingTest:^BOOL(UMOMockHTTPRequest *mockRequest, NSUInteger idx, BOOL *stop) {
        return [mockRequest matchesURLRequest:request];
    }];

    return (index != NSNotFound) ? mockRequests[index] : nil;
}


+ (void)expectMockRequest:(UMOMockHTTPRequest *)request
{
    NSMutableArray *mockRequestsForCanonicalURL = [self expectedMockRequestsForCanonicalURL:request.canonicalURL];
    [mockRequestsForCanonicalURL addObject:request];
}


+ (BOOL)hasServicedMockRequest:(UMOMockHTTPRequest *)request
{
    return [[self servicedMockRequests] containsObject:request];
}


+ (void)removeExpectedMockRequest:(UMOMockHTTPRequest *)request
{
    NSMutableArray *mockRequestsForCanonicalURL = [self expectedMockRequestsForCanonicalURL:request.canonicalURL];
    [mockRequestsForCanonicalURL removeObject:request];
}


#pragma mark - NSURLProtocol subclass methods

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    return [self interceptsAllRequests] || [self expectedMockRequestMatchingURLRequest:request] != nil;
}


+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    NSMutableURLRequest *canonicalRequest = [request mutableCopy];
    [canonicalRequest setURL:[self canonicalURLForURL:request.URL]];
    return canonicalRequest;
}


+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return NO;
}


- (void)startLoading
{
    self.mockRequest = [[self class] expectedMockRequestMatchingURLRequest:self.request];
    [self.mockRequest.response respondToMockRequest:self.mockRequest client:self.client protocol:self];
    
    if ([[self class] automaticallyRemovesServicedMockRequests]) {
        NSURL *canonicalURL = [[self class] canonicalURLForURL:self.request.URL];
        NSMutableArray *mockRequests = [[self class] expectedMockRequestsForCanonicalURL:canonicalURL];
        [mockRequests removeObject:self.mockRequest];
    }
        
    [[[self class] servicedMockRequests] addObject:self.mockRequest];
}


- (void)stopLoading
{
    [self.mockRequest.response cancelResponse];
}

@end
