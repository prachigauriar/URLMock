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

#import <URLMock/NSDictionary+UMKURLEncoding.h>
#import <URLMock/UMKErrorUtilities.h>


#pragma mark Constants

NSString *const kUMKErrorDomain = @"UMKErrorDomain";
NSString *const kUMKUnservicedMockRequestsKey = @"UMKUnservicedMockRequests";


#pragma mark - UMKMockURLProtocolSettings

/*!
 UMKMockURLProtocolSettings store settings for the UMKMockURLProtocol class.
 */
@interface UMKMockURLProtocolSettings : NSObject

/*! Whether UMKMockURLProtocol is enabled. */
@property (assign, getter = isEnabled) BOOL enabled;

/*! Whether verification is enabled for UMKMockURLProtocol. */
@property (assign, getter = isVerificationEnabled) BOOL verificationEnabled;

/*! Whether UMKMockURLProtocol has received an unexpected request since the last reset. */
@property (assign) BOOL receivedUnexpectedRequest;

/*! UMKMockURLProtocol's expected mock requests. */
@property (nonatomic, strong, readonly) NSMutableArray *expectedMockRequests;

/*! UMKMockURLProtocol's serviced requests. Keys are NSURLRequests; values are UMKMockURLRequests. */
@property (nonatomic, strong, readonly) NSMutableDictionary *servicedRequests;


/*!
 @abstract Resets the receiver's accounting settings.
 @discussion Accounting settings include the whether the receiver has received any unexpected requests,
     what requests are expected, and what requests have been serviced.
 */
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


- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"<%@: %lX; enabled: %@; verificationEnabled: %@, receivedUnexpectedRequest: %@; "
                                      @"expectedMockRequests: %@, servicedRequests: %@>",
            [self class], (unsigned long)self,
            self.enabled ? @"YES" : @"NO",
            self.verificationEnabled ? @"YES" : @"NO",
            self.receivedUnexpectedRequest ? @"YES" : @"NO",
            self.expectedMockRequests.debugDescription,
            self.servicedRequests.debugDescription];
}

@end


#pragma mark - UMKMockURLProtocol

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
        NSAssert(_mockResponder, @"No responder for mock request: %@", _mockRequest);
        
        [[self class] markRequest:request asServicedByMockRequest:_mockRequest];
    }

    return self;
}


#pragma mark - NSURLProtocol subclass methods

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    id <UMKMockURLRequest> mockRequest = [self expectedMockRequestMatchingURLRequest:request];
    if (!mockRequest && [self isVerificationEnabled]) {
        @synchronized (self.settings.servicedRequests) {
            mockRequest = self.settings.servicedRequests[request];
        }
        
        self.settings.receivedUnexpectedRequest = !mockRequest;
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
}


- (void)stopLoading
{
    [self.mockResponder cancelResponse];
}


#pragma mark - Settings

+ (UMKMockURLProtocolSettings *)settings
{
    static UMKMockURLProtocolSettings *settings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        settings = [[UMKMockURLProtocolSettings alloc] init];
    });

    return settings;
}


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


#pragma mark - Expectations

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


+ (NSArray *)expectedMockRequests
{
    return self.settings.expectedMockRequests;
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


#pragma mark - Servicing Requests

+ (NSDictionary *)servicedRequests
{
    return self.settings.servicedRequests;
}


+ (void)markRequest:(NSURLRequest *)request asServicedByMockRequest:(id <UMKMockURLRequest>)mockRequest
{
    if ([self isVerificationEnabled]) {
        @synchronized (self.settings.servicedRequests) {
            self.settings.servicedRequests[request] = mockRequest;
        }
        
        [self removeExpectedMockRequest:mockRequest];
    }
}


#pragma mark - Verification

+ (BOOL)isVerificationEnabled
{
    return self.settings.isVerificationEnabled;
}


+ (void)setVerificationEnabled:(BOOL)enabled
{
    self.settings.verificationEnabled = enabled;
}


+ (BOOL)verifyWithError:(NSError **)outError
{
    if (![self isVerificationEnabled]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:UMKExceptionString(self, _cmd, @"Verification is not enabled.")
                                     userInfo:nil];
    }
    
    // Synchronize here because expectedMockRequests can't change until we make a copy to return
    @synchronized (self.settings.expectedMockRequests) {
        BOOL receivedUnexpectedRequest = self.settings.receivedUnexpectedRequest;
        BOOL hasUnservicedMockRequests = self.settings.expectedMockRequests.count;

        // All code after this if statement is to build the error object, so just return now if we
        // don't need to execute any of that
        BOOL passed = !(receivedUnexpectedRequest || hasUnservicedMockRequests);
        if (passed || !outError) {
            return passed;
        }
        
        NSUInteger code = 0;
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
        
        // Because we don't return which requests were unexpected, we want to prioritize that error over
        // unserviced requests. Unserviced requests will be returned whether that's the error code we use
        // or not
        if (receivedUnexpectedRequest) {
            code = kUMKUnexpectedRequestErrorCode;
            userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"Received an unexpected request",
                                                                    @"Unexpected request error description");
        } else {
            code = kUMKUnservicedMockRequestErrorCode;
            userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"One or more mock requests were not serviced",
                                                                    @"Unserviced mock request error description");
        }
        
        if (hasUnservicedMockRequests) {
            userInfo[kUMKUnservicedMockRequestsKey] = [self.settings.expectedMockRequests copy];
        }
        
        *outError = [NSError errorWithDomain:kUMKErrorDomain code:code userInfo:userInfo];
        return NO;
    }
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
        NSString *canonicalQueryString = [[NSDictionary umk_dictionaryWithURLEncodedParameterString:query] umk_URLEncodedParameterString];
        NSString *URLString = [canonicalURL absoluteString];
        canonicalURL = [NSURL URLWithString:[URLString stringByReplacingCharactersInRange:[URLString rangeOfString:query]
                                                                               withString:canonicalQueryString]];
    }

    return canonicalURL;
}

@end
