//
//  UMOMockURLProtocol.m
//  URLMock
//
//  Created by Prachi Gauriar on 11/9/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import <URLMock/UMOMockURLProtocol.h>
#import <URLMock/UMOMockHTTPRequest.h>
#import <URLMock/UMOMockHTTPResponse.h>
#import <URLMock/UMOURLEncodingUtilities.h>


#pragma mark -

static BOOL _interceptsAllRequests = NO;

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
    [[self fulfilledMockRequests] removeAllObjects];
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


+ (NSMutableSet *)fulfilledMockRequests
{
    static NSMutableSet *fulfilledRequests = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fulfilledRequests = [[NSMutableSet alloc] init];
    });
    
    return fulfilledRequests;
}


+ (BOOL)interceptsAllRequests
{
    return _interceptsAllRequests;
}


+ (void)setInterceptsAllRequests:(BOOL)interceptsAllRequests
{
    _interceptsAllRequests = interceptsAllRequests;
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
    // Because we're storing requests in arrays, our worst-case lokup time is going to be O(n),
    // where n is the number of mock requests for the given canonical URL. Worse still, for
    // each mock request, we're going to incur this overhead twice: once in +canInitWithRequest:
    // and then again in -startLoading. We can avoid the overhead of the second call by saving
    // the last result. This is only really useful in the pathological case where we have lots
    // of mock requests for the exact same URL, but if we ever add requests that match based
    // on a pattern, this could pay off then too, especially since checking whether it matches
    // would be more expensive.
    static UMOMockHTTPRequest *lastFoundMockRequest = nil;
    if ([lastFoundMockRequest matchesURLRequest:request]) {
        return lastFoundMockRequest;
    }
    
    // If we can find a mock request for this URL that matches the URL request, update lastFoundMockRequest
    NSMutableArray *mockRequests = [self expectedMockRequestsForCanonicalURL:[self canonicalURLForURL:request.URL]];
    NSUInteger index = [mockRequests indexOfObjectPassingTest:^BOOL(UMOMockHTTPRequest *mockRequest, NSUInteger idx, BOOL *stop) {
        return [mockRequest matchesURLRequest:request];
    }];
    
    lastFoundMockRequest = (index != NSNotFound) ? mockRequests[index] : nil;
    return lastFoundMockRequest;
}


+ (void)expectMockRequest:(UMOMockHTTPRequest *)request
{
    NSMutableArray *mockRequestsForCanonicalURL = [self expectedMockRequestsForCanonicalURL:request.canonicalURL];
    [mockRequestsForCanonicalURL addObject:request];
}


+ (BOOL)hasRespondedToMockRequest:(UMOMockHTTPRequest *)request
{
    return [[self fulfilledMockRequests] containsObject:request];
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
    UMOMockHTTPRequest *mockRequest = [[self class] expectedMockRequestMatchingURLRequest:self.request];
    [mockRequest.response respondToMockRequest:mockRequest client:self.client protocol:self];
    
    NSURL *canonicalURL = [[self class] canonicalURLForURL:self.request.URL];
    NSMutableArray *mockRequests = [[self class] expectedMockRequestsForCanonicalURL:canonicalURL];
    [mockRequests removeObject:mockRequest];
    
    [[[self class] fulfilledMockRequests] addObject:mockRequest];
}


- (void)stopLoading
{
    // TODO: Figure out what to do here
}

@end
