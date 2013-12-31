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
#import <URLMock/UMKErrorUtilities.h>


@interface UMKMockURLProtocolSettings : NSObject

@property (assign, getter = isEnabled) BOOL enabled;
@property (assign, getter = isVerificationEnabled) BOOL verificationEnabled;
@property (assign) BOOL receivedUnexpectedRequest;
@property (nonatomic, strong, readonly) NSMutableArray *expectedMockRequests;
@property (nonatomic, strong, readonly) NSMutableDictionary *servicedRequests;

- (void)reset;

@end


#pragma mark

@implementation UMKMockURLProtocolSettings

- (instancetype)init
{
    self = [super init];
    if (self) {
        _expectedMockRequests = [[NSMutableArray alloc] init];
        _servicedRequests = [[NSMutableDictionary alloc] init];
    }

    return self;
}


- (void)reset
{
    @synchronized (self) {
        self.receivedUnexpectedRequest = NO;
        [self.expectedMockRequests removeAllObjects];
        [self.servicedRequests removeAllObjects];
    }
}

@end


#pragma mark

@interface UMKMockURLProtocol ()

/*! The instance's mock request. */
@property (strong, nonatomic) id <UMKMockURLRequest> mockRequest;

/*! The instance's mock responder. */
@property (strong, nonatomic) id <UMKMockURLResponder> mockResponder;

@end


#pragma mark

@implementation UMKMockURLProtocol

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient>)client
{
    self = [super initWithRequest:request cachedResponse:cachedResponse client:client];
    if (self) {
        _mockRequest = [[self class] expectedMockRequestMatchingURLRequest:request];
        _mockResponder = [_mockRequest responderForURLRequest:request];

        if ([[self class] isVerificationEnabled]) {
            [[self class] removeExpectedMockRequest:_mockRequest];
        }
    }

    return self;
}


+ (UMKMockURLProtocolSettings *)settings
{
    static UMKMockURLProtocolSettings *settings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        settings = [[UMKMockURLProtocolSettings alloc] init];
    });

    return settings;
}


#pragma mark - Enable, Disable, and Reset

+ (void)enable
{
    if (self.settings.isEnabled) return;
    self.settings.enabled = YES;
    [super registerClass:self];
}


+ (void)reset
{
    [self.settings reset];
}


+ (void)disable
{
    if (!self.settings.isEnabled) return;
    self.settings.enabled = NO;
    [super unregisterClass:self];
}


#pragma mark - Accessors

+ (NSArray *)expectedMockRequests
{
    return self.settings.expectedMockRequests;
}


+ (NSDictionary *)servicedRequests
{
    return self.settings.servicedRequests;
}


#pragma mark - Adding and Removing Expectations

/*!
 @abstract Returns the first expected mock request that matches the specified URL request.
 @param request The URL request to find a mock request for. May not be nil.
 @result The first expected mock request that matches the specified URL request.
 */
+ (id <UMKMockURLRequest>)expectedMockRequestMatchingURLRequest:(NSURLRequest *)request
{
    NSParameterAssert(request);

    NSMutableArray *expectedMockRequests = self.settings.expectedMockRequests;
    @synchronized (expectedMockRequests) {
        NSUInteger index = [expectedMockRequests indexOfObjectPassingTest:^BOOL(id <UMKMockURLRequest> mockRequest, NSUInteger idx, BOOL *stop) {
            return [mockRequest matchesURLRequest:request];
        }];

        return (index != NSNotFound) ? expectedMockRequests[index] : nil;
    }
}


+ (void)expectMockRequest:(id <UMKMockURLRequest>)request
{
    NSParameterAssert(request);
    @synchronized (self.settings.expectedMockRequests) {
        [self.settings.expectedMockRequests addObject:request];
    }
}


+ (void)removeExpectedMockRequest:(id <UMKMockURLRequest>)request
{
    @synchronized (self.settings.expectedMockRequests) {
        [self.settings.expectedMockRequests removeObject:request];
    }
}


#pragma mark - Verification

+ (BOOL)isVerificationEnabled
{
    return self.settings.isVerificationEnabled;
}


+ (void)setVerificationEnabled:(BOOL)enabled
{
    if (enabled == self.settings.isVerificationEnabled) return;
    self.settings.verificationEnabled = enabled;
    self.settings.receivedUnexpectedRequest = NO;
}


+ (BOOL)verify
{
    if (![self isVerificationEnabled]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:UMKExceptionString(self, _cmd, @"Verification is not enabled.")
                                     userInfo:nil];
    }
    
    return !self.settings.receivedUnexpectedRequest && self.settings.expectedMockRequests.count == 0;
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
    if (!mockRequest && [self isVerificationEnabled]) {
        self.settings.receivedUnexpectedRequest = YES;
    }

    return mockRequest != nil;
}


+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    NSURL *canonicalURL = [self canonicalURLForURL:request.URL];
    if ([canonicalURL isEqual:request.URL]) {
        return request;
    }

    NSMutableURLRequest *canonicalRequest = [request mutableCopy];
    canonicalRequest.URL = canonicalURL;
    return canonicalRequest;
}


+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return NO;
}


- (void)startLoading
{
    [self.mockResponder respondToMockRequest:self.mockRequest client:self.client protocol:self];

    NSMutableDictionary *servicedMockRequests = [[[self class] settings] servicedRequests];
    @synchronized (servicedMockRequests) {
        servicedMockRequests[self.request] = self.mockRequest;
    }
}


- (void)stopLoading
{
    [self.mockResponder cancelResponse];
}

@end
