//
//  UMKMockURLProtocol.m
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

#import <URLMock/UMKMockURLProtocol.h>
#import <URLMock/UMKURLEncodingUtilities.h>

@interface UMKMockURLProtocol ()

/*! The instance's mock request. */
@property (strong, nonatomic) id <UMKMockURLRequest> mockRequest;

/*! The instance's mock responder. */
@property (strong, nonatomic) id <UMKMockURLResponder> mockResponder;

/*!
 @abstract Returns the first expected mock request that matches the specified URL request.
 @param request The URL request to find a mock request for. May not be nil.
 @result The first expected mock request that matches the specified URL request.
 */
+ (id <UMKMockURLRequest>)expectedMockRequestMatchingURLRequest:(NSURLRequest *)request;

@end


#pragma mark - Class Variables

/*! Whether the class should intercept all requests to the NSURL system. */
static BOOL _interceptsAllRequests;

/*! Whether instances of the class automatically remove serviced mock requests from the class's set of expected mock requests */
static BOOL _automaticallyRemovesServicedMockRequests;


#pragma mark -

@implementation UMKMockURLProtocol

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient>)client
{
    self = [super initWithRequest:request cachedResponse:cachedResponse client:client];
    if (self) {
        _mockRequest = [[self class] expectedMockRequestMatchingURLRequest:request];
        _mockResponder = [_mockRequest responderForURLRequest:request];

        if ([[self class] automaticallyRemovesServicedMockRequests]) {
            [[[self class] expectedMockRequests] removeObject:_mockRequest];
        }
    }

    return self;
}


#pragma mark - Enable, Disable, and Reset

+ (void)enable
{
    [super registerClass:self];
}


+ (void)reset
{
    [[self expectedMockRequests] removeAllObjects];
    [[self servicedMockRequests] removeAllObjects];
}


+ (void)disable
{
    [super unregisterClass:self];
}


#pragma mark - Accessors

+ (NSArray *)allExpectedMockRequests
{
    return [[self expectedMockRequests] copy];
}


+ (NSMutableArray *)expectedMockRequests
{
    static NSMutableArray *expectedMockRequests = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        expectedMockRequests = [[NSMutableArray alloc] init];
    });
    
    return expectedMockRequests;
}


+ (NSSet *)allServicedMockRequests
{
    return [[self servicedMockRequests] copy];
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


#pragma mark - Adding and Removing Expectations

+ (id <UMKMockURLRequest>)expectedMockRequestMatchingURLRequest:(NSURLRequest *)request
{
    NSParameterAssert(request);
    NSUInteger index = [[self expectedMockRequests] indexOfObjectPassingTest:^BOOL(id <UMKMockURLRequest> mockRequest, NSUInteger idx, BOOL *stop) {
        return [mockRequest matchesURLRequest:request];
    }];

    return (index != NSNotFound) ? [[self expectedMockRequests] objectAtIndex:index] : nil;
}


+ (void)expectMockRequest:(id <UMKMockURLRequest>)request
{
    NSParameterAssert(request);
    [[self expectedMockRequests] addObject:request];
}


+ (BOOL)hasServicedMockRequest:(id <UMKMockURLRequest>)request
{
    return [[self servicedMockRequests] containsObject:request];
}


+ (void)removeExpectedMockRequest:(id <UMKMockURLRequest>)request
{
    [[self expectedMockRequests] removeObject:request];
}


#pragma mark - Canonical URLs

+ (NSURL *)canonicalURLForURL:(NSURL *)URL
{
    NSParameterAssert(URL);

    // Always use the absolute URL
    NSURL *canonicalURL = URL.absoluteURL;
    NSString *query = canonicalURL.query;

    // If there's a query, make sure the order of the parameters is consistent
    if (query) {
        NSString *canonicalQueryString = UMKURLEncodedStringForParameters(UMKDictionaryForURLEncodedParametersString(query));
        NSString *URLString = [canonicalURL absoluteString];
        canonicalURL = [NSURL URLWithString:[URLString stringByReplacingCharactersInRange:[URLString rangeOfString:query]
                                                                               withString:canonicalQueryString]];
    }

    return canonicalURL;
}


#pragma mark - NSURLProtocol subclass methods

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    id <UMKMockURLRequest> mockRequest = [self expectedMockRequestMatchingURLRequest:request];
    if (!mockRequest && [self interceptsAllRequests]) {
        [NSException raise:NSInternalInconsistencyException format:@"Unexpected request received: %@", request];
    }

    return mockRequest != nil;
}


+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    NSMutableURLRequest *canonicalRequest = [request mutableCopy];
    [canonicalRequest setURL:[self canonicalURLForURL:[request URL]]];
    return canonicalRequest;
}


+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return NO;
}


- (void)startLoading
{
    [self.mockResponder respondToMockRequest:self.mockRequest client:self.client protocol:self];
    [[[self class] servicedMockRequests] addObject:self.mockRequest];
}


- (void)stopLoading
{
    [self.mockResponder cancelResponse];
}

@end
