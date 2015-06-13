//
//  UMKMockURLProtocol.m
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

#import <URLMock/UMKMockURLProtocol.h>

#import <URLMock/NSDictionary+UMKURLEncoding.h>
#import <URLMock/UMKErrorUtilities.h>


#pragma mark Constants

NSString *const kUMKErrorDomain = @"UMKErrorDomain";
NSString *const kUMKUnexpectedRequestsKey = @"UMKUnexpectedRequests";
NSString *const kUMKUnservicedMockRequestsKey = @"UMKUnservicedMockRequests";


#pragma mark - UMKMockUnexpectedRequest

/*!
 When verification is enabled, UMKUnexpectedRequestResponders respond to unexpected requests with an error.
 */
@interface UMKUnexpectedRequestResponder : NSObject <UMKMockURLResponder>
@end


#pragma mark -

@implementation UMKUnexpectedRequestResponder

- (void)respondToMockRequest:(id<UMKMockURLRequest>)request client:(id<NSURLProtocolClient>)client protocol:(NSURLProtocol *)protocol
{
    [client URLProtocol:protocol didFailWithError:[NSError errorWithDomain:kUMKErrorDomain code:kUMKUnexpectedRequestErrorCode userInfo:nil]];
}


- (void)cancelResponse
{
}

@end


#pragma mark - UMKMockURLProtocolSettings

/*!
 UMKMockURLProtocolSettings store settings for the UMKMockURLProtocol class.
 */
@interface UMKMockURLProtocolSettings : NSObject

/*! Whether UMKMockURLProtocol is enabled. */
@property (assign, getter = isEnabled) BOOL enabled;

/*! Whether verification is enabled for UMKMockURLProtocol. */
@property (assign, getter = isVerificationEnabled) BOOL verificationEnabled;

/*! The isolation queue for reading/writing expected mock requests. */
@property (nonatomic, copy, readonly) dispatch_queue_t expectedMockRequestsIsolationQueue;

/*! 
 @abstract UMKMockURLProtocol's expected mock requests. 
 @discussion This variable should only be read and written on its isolation queue. Reads should be done using dispatch_sync;
     writes should be done using dispatch_barrier_async. This allows for multiple simultaneous readers, but only one writer,
     and prevents a read from occurring during a write.
 */
@property (nonatomic, strong, readonly) NSMutableArray *expectedMockRequests;

/*! The isolation queue for reading/writing unexpected requests. */
@property (nonatomic, copy, readonly) dispatch_queue_t unexpectedRequestsIsolationQueue;

/*! 
 @abstract UMKMockURLProtocol's unexpected requests.
 @discussion This variable should only be read and written on its isolation queue. Reads should be done using dispatch_sync;
     writes should be done using dispatch_barrier_async. This allows for multiple simultaneous readers, but only one writer,
     and prevents a read from occurring during a write.
*/
@property (nonatomic, strong, readonly) NSMutableArray *unexpectedRequests;

/*! The isolation queue for reading/writing serviced requests. */
@property (nonatomic, copy, readonly) dispatch_queue_t servicedRequestsIsolationQueue;

/*!
 @abstract UMKMockURLProtocol's serviced requests. Keys are NSURLRequests; values are UMKMockURLRequests.
 @discussion This variable should only be read and written on its isolation queue. Reads should be done using dispatch_sync;
     writes should be done using dispatch_barrier_async. This allows for multiple simultaneous readers, but only one writer,
     and prevents a read from occurring during a write.
 */
@property (nonatomic, strong, readonly) NSMutableDictionary *servicedRequests;


/*!
 @abstract Resets the receiver's accounting settings.
 @discussion Accounting settings include the whether the receiver has received any unexpected requests,
     what requests are expected, and what requests have been serviced.
 */
- (void)reset;

@end


#pragma mark -

@implementation UMKMockURLProtocolSettings

- (instancetype)init
{
    self = [super init];
    if (self) {
        _unexpectedRequests = [[NSMutableArray alloc] init];
        NSString *label = [NSString stringWithFormat:@"%@.isolation.unexpectedRequests", [self class]];
        _unexpectedRequestsIsolationQueue = dispatch_queue_create([label UTF8String], 0);
        
        _expectedMockRequests = [[NSMutableArray alloc] init];
        label = [NSString stringWithFormat:@"%@.isolation.expectedMockRequests", [self class]];
        _expectedMockRequestsIsolationQueue = dispatch_queue_create([label UTF8String], 0);
        
        _servicedRequests = [[NSMutableDictionary alloc] init];
        label = [NSString stringWithFormat:@"%@.isolation.servicedRequests", [self class]];
        _servicedRequestsIsolationQueue = dispatch_queue_create([label UTF8String], 0);
    }

    return self;
}


- (void)reset
{
    dispatch_barrier_async(self.expectedMockRequestsIsolationQueue, ^{
        [self.expectedMockRequests removeAllObjects];
    });
    
    dispatch_barrier_async(self.unexpectedRequestsIsolationQueue, ^{
        [self.unexpectedRequests removeAllObjects];
    });
    
    dispatch_barrier_async(self.servicedRequestsIsolationQueue, ^{
        [self.servicedRequests removeAllObjects];
    });
}


- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"<%@: %p> enabled: %@; verificationEnabled: %@, receivedUnexpectedRequest: %@; "
                                      @"expectedMockRequests: %@, servicedRequests: %@", [self class], self,
                                                                                         self.enabled ? @"YES" : @"NO",
                                                                                         self.verificationEnabled ? @"YES" : @"NO",
                                                                                         self.unexpectedRequests.debugDescription,
                                                                                         self.expectedMockRequests.debugDescription,
                                                                                         self.servicedRequests.debugDescription];
}

@end


#pragma mark - UMKMockURLProtocol

@interface UMKMockURLProtocol ()

/*! The instance's mock request. */
@property (strong, nonatomic) id<UMKMockURLRequest> mockRequest;

/*! The instance's mock responder. */
@property (strong, nonatomic) id<UMKMockURLResponder> mockResponder;

@end


#pragma mark -

@implementation UMKMockURLProtocol

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client
{
    self = [super initWithRequest:request cachedResponse:cachedResponse client:client];
    if (self) {
        _mockRequest = [[self class] expectedMockRequestMatchingURLRequest:request];

        // If there was a mock request, mark it as serviced. Otherwise, respond with an unexpected request responder
        if (_mockRequest) {
            _mockResponder = [_mockRequest responderForURLRequest:request];
            NSAssert(_mockResponder, @"No responder for mock request: %@", _mockRequest);
            [[self class] markRequest:request asServicedByMockRequest:_mockRequest];
        } else {
            _mockResponder = [[UMKUnexpectedRequestResponder alloc] init];
            [[self class] addUnexpectedRequest:request];
        }
    }

    return self;
}


#pragma mark - NSURLProtocol subclass methods

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if ([self isVerificationEnabled]) {
        return YES;
    }
    
    return [self expectedMockRequestMatchingURLRequest:request] != nil;
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
    @synchronized (self.settings) {
        if (!self.settings.isEnabled) {
            self.settings.enabled = YES;
            [super registerClass:self];
        }
    }
}


+ (void)reset
{
    [self.settings reset];
}


+ (void)disable
{
    @synchronized (self.settings) {
        if (self.settings.isEnabled) {
            self.settings.enabled = NO;
            [super unregisterClass:self];
        }
    }
}


#pragma mark - Expectations

/*!
 @abstract Returns the first expected mock request that matches the specified URL request.
 @param request The URL request to find a mock request for. May not be nil.
 @result The first expected mock request that matches the specified URL request.
 */
+ (id<UMKMockURLRequest>)expectedMockRequestMatchingURLRequest:(NSURLRequest *)request
{
    NSParameterAssert(request);

    __block NSUInteger index = 0;
    __block id<UMKMockURLRequest> mockRequest = nil;

    dispatch_sync([[[self class] settings] expectedMockRequestsIsolationQueue] , ^{
        index = [self.settings.expectedMockRequests indexOfObjectPassingTest:^BOOL(id<UMKMockURLRequest> mockRequest, NSUInteger idx, BOOL *stop) {
            return [mockRequest matchesURLRequest:request];
        }];
        
        mockRequest = (index != NSNotFound) ? self.settings.expectedMockRequests[index] : nil;
    });
    
    return mockRequest;
}


+ (NSArray *)expectedMockRequests
{
    __block NSArray *expectedMockRequests = nil;
    dispatch_sync(self.settings.expectedMockRequestsIsolationQueue, ^{
        expectedMockRequests = [self.settings.expectedMockRequests copy];
    });
    
    return expectedMockRequests;
}


+ (void)expectMockRequest:(id<UMKMockURLRequest>)request
{
    NSParameterAssert(request);

    dispatch_barrier_async(self.settings.expectedMockRequestsIsolationQueue, ^{
        [self.settings.expectedMockRequests addObject:request];
    });
}


+ (void)removeExpectedMockRequest:(id<UMKMockURLRequest>)request
{
    dispatch_barrier_async(self.settings.expectedMockRequestsIsolationQueue, ^{
        [self.settings.expectedMockRequests removeObject:request];
    });
}


#pragma mark - Unexpected Requests

+ (NSArray *)unexpectedRequests
{
    __block NSArray *unexpectedRequests = nil;
    dispatch_sync(self.settings.unexpectedRequestsIsolationQueue, ^{
        unexpectedRequests = [self.settings.unexpectedRequests copy];
    });
    
    return unexpectedRequests;
}


+ (void)addUnexpectedRequest:(NSURLRequest *)request
{
    dispatch_barrier_async(self.settings.unexpectedRequestsIsolationQueue, ^{
        [self.settings.unexpectedRequests addObject:request];
    });
}


#pragma mark - Servicing Requests

+ (NSDictionary *)servicedRequests
{
    __block NSDictionary *servicedRequests = nil;
    dispatch_sync(self.settings.servicedRequestsIsolationQueue, ^{
        servicedRequests = [self.settings.servicedRequests copy];
    });
    
    return servicedRequests;
}


+ (void)markRequest:(NSURLRequest *)request asServicedByMockRequest:(id<UMKMockURLRequest>)mockRequest
{
    if (![self isVerificationEnabled]) {
        return;
    }

    dispatch_async(self.settings.servicedRequestsIsolationQueue, ^{
        self.settings.servicedRequests[request] = mockRequest;
    });

    // If the mockRequest doesn't respond to shouldRemoveAfterServicingRequest: or it does and it responds YES, remove it
    if (![mockRequest respondsToSelector:@selector(shouldRemoveAfterServicingRequest:)] || [mockRequest shouldRemoveAfterServicingRequest:request]) {
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

    // We want to disallow any writes to either unexpectedRequests or expectedMockRequests until we're done copying both
    __block NSArray *unexpectedRequests = nil;
    __block NSArray *expectedMockRequests = nil;
    dispatch_sync(self.settings.unexpectedRequestsIsolationQueue, ^{
        dispatch_sync(self.settings.expectedMockRequestsIsolationQueue, ^{
            unexpectedRequests = [self.settings.unexpectedRequests copy];
            expectedMockRequests = [self.settings.expectedMockRequests copy];
        });
    });
    
    BOOL receivedUnexpectedRequest = unexpectedRequests.count > 0;

    NSMutableSet *unservicedMockRequests = [NSMutableSet setWithArray:expectedMockRequests];
    [unservicedMockRequests minusSet:[NSSet setWithArray:self.servicedRequests.allValues]];
    BOOL hasUnservicedMockRequests = unservicedMockRequests.count > 0;

    BOOL passed = !(receivedUnexpectedRequest || hasUnservicedMockRequests);
    if (passed || !outError) {
        return passed;
    }
    
    NSUInteger code = 0;
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    // We want to prioritize unexpected requests over unserviced requests.
    // Unserviced requests will be returned whether that's the error code we use or not
    if (receivedUnexpectedRequest) {
        code = kUMKUnexpectedRequestErrorCode;
        userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"Received one or more unexpected requests", @"Unexpected request error description");
        userInfo[kUMKUnexpectedRequestsKey] = unexpectedRequests;
    } else {
        code = kUMKUnservicedMockRequestErrorCode;
        userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"One or more mock requests were not serviced", @"Unserviced mock request error description");
    }
    
    if (hasUnservicedMockRequests) {
        userInfo[kUMKUnservicedMockRequestsKey] = [unservicedMockRequests allObjects];
    }
    
    *outError = [NSError errorWithDomain:kUMKErrorDomain code:code userInfo:userInfo];
    return NO;
}


#pragma mark - Canonical URLs

+ (NSURL *)canonicalURLForURL:(NSURL *)URL
{
    NSParameterAssert(URL);

    // Always use the absolute URL
    NSURL *canonicalURL = URL.absoluteURL;
    NSString *query = canonicalURL.query;

    // If there's a query, make sure the order of the parameters is consistent
    if (query.length > 0) {
        NSString *canonicalQueryString = [[NSDictionary umk_dictionaryWithURLEncodedParameterString:query] umk_URLEncodedParameterString];
        NSString *URLString = [canonicalURL absoluteString];
        canonicalURL = [NSURL URLWithString:[URLString stringByReplacingCharactersInRange:[URLString rangeOfString:query]
                                                                               withString:canonicalQueryString]];
    }

    return canonicalURL;
}

@end
