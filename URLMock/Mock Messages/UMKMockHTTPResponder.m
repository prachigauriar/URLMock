//
//  UMKMockHTTPResponder.m
//  URLMock
//
//  Created by Prachi Gauriar on 11/8/2013.
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

#import <URLMock/UMKMockHTTPResponder.h>

#import <URLMock/NSException+UMKSubclassResponsibility.h>


#pragma mark Constants

/*! The minimum body length for chunking. The NSURL system seems to coalesce payloads smaller than 2048 bytes. */
static const NSUInteger kUMKMinimumBodyLengthToChunk = 2048;

/*! The minimum delay between chunks. The NSURL system seems to coalesce data that is received within 0.0001 seconds of the previous chunk. */
static const NSTimeInterval kUMKMinimumDelayBetweenChunks = 0.0001;

/*! The HTTP 1.1 version string. */
static NSString *const kUMKHTTP11VersionString = @"HTTP/1.1";


#pragma mark -

@interface UMKMockHTTPResponder ()

/*! Whether the responder is currently responding to a request. */
@property (nonatomic, getter = isResponding) BOOL responding;

@end


#pragma mark - Private Subclass Interfaces

/*!
 Instances of UMKMockHTTPErrorResponder respond to mock HTTP URL requests with errors.
 */
@interface UMKMockHTTPErrorResponder : UMKMockHTTPResponder

/*! The error that the instance responds with. */
@property (readonly, strong, nonatomic) NSError *error;

/*!
 @abstract Initializes a newly-created UMKMockHTTPErrorResponder instance with the specified error.
 @discussion This is the error that is sent to the NSURL system in response to a mock URL request. The NSURL system may modify it by adding 
     fields to the error's userInfo or even changing the error's code. As such, expectations about the actual error that will be received 
     should be limited. Equality checks should not be used; at best, individual fields in the error should be examined.
 @param error The error to respond with. May not be nil.
 @result A newly initialized UMKMockHTTPErrorResponder with the specified error.
 */
- (instancetype)initWithError:(NSError *)error;

@end


/*!
 UMKMockHTTPResponseResponder instances respond to mock HTTP requests with an HTTP response.
 */
@interface UMKMockHTTPResponseResponder : UMKMockHTTPResponder

/*! The HTTP status code that the instance responds with. */
@property (readonly, nonatomic) NSInteger statusCode;

/*! The chunks count hint that the instance was initialized with. */
@property (readonly, nonatomic) NSUInteger chunkCountHint;

/*! The delay in seconds that the instance waits between sending chunks. */
@property (readonly, nonatomic) NSTimeInterval delayBetweenChunks;

/*!
 @abstract Initializes a newly-created UMKMockHTTPResponseResponder instance with the specified status code, headers, body, chunk count hint,
     and delay between chunks.
 @param statusCode The HTTP status code to respond with.
 @param headers The HTTP headers to respond with.
 @param body The HTTP body to respond with.
 @param hint A hint as to how many chunks the HTTP body should be broken into when responding. The actual number of chunks depends
     on the size of the body and the whims of the NSURL system. May not be 0.
 @param delay The amount of time the responder should wait between sending chunks of data. This is only used if chunks is more
     than 1. Must be non-negative.
 @result A newly initialized UMKMockHTTPResponseResponder with the specified parameters.
 */
- (instancetype)initWithStatusCode:(NSInteger)statusCode headers:(NSDictionary *)headers body:(NSData *)body
                    chunkCountHint:(NSUInteger)hint delayBetweenChunks:(NSTimeInterval)delay;

@end


#pragma mark - Base Class Implementation

@implementation UMKMockHTTPResponder

+ (instancetype)mockHTTPResponderWithError:(NSError *)error
{
    NSParameterAssert(error);
    return [[UMKMockHTTPErrorResponder alloc] initWithError:error];
}


+ (instancetype)mockHTTPResponderWithStatusCode:(NSInteger)statusCode
{
    return [self mockHTTPResponderWithStatusCode:statusCode headers:nil body:nil chunkCountHint:1 delayBetweenChunks:0.0];
}


+ (instancetype)mockHTTPResponderWithStatusCode:(NSInteger)statusCode headers:(NSDictionary *)headers
{
    return [self mockHTTPResponderWithStatusCode:statusCode headers:headers body:nil chunkCountHint:1 delayBetweenChunks:0.0];
}


+ (instancetype)mockHTTPResponderWithStatusCode:(NSInteger)statusCode body:(NSData *)body
{
    return [self mockHTTPResponderWithStatusCode:statusCode headers:nil body:body chunkCountHint:1 delayBetweenChunks:0.0];
}


+ (instancetype)mockHTTPResponderWithStatusCode:(NSInteger)statusCode headers:(NSDictionary *)headers body:(NSData *)body
{
    return [self mockHTTPResponderWithStatusCode:statusCode headers:headers body:body chunkCountHint:1 delayBetweenChunks:0.0];
}


+ (instancetype)mockHTTPResponderWithStatusCode:(NSInteger)statusCode headers:(NSDictionary *)headers body:(NSData *)body
                                 chunkCountHint:(NSUInteger)chunkCountHint delayBetweenChunks:(NSTimeInterval)delay
{
    NSParameterAssert(chunkCountHint != 0);
    NSParameterAssert(delay >= 0.0);
    return [[UMKMockHTTPResponseResponder alloc] initWithStatusCode:statusCode headers:headers body:body
                                                     chunkCountHint:chunkCountHint delayBetweenChunks:delay];
}


- (void)respondToMockRequest:(id<UMKMockURLRequest>)request client:(id<NSURLProtocolClient>)client protocol:(NSURLProtocol *)protocol
{
    @throw [NSException umk_subclassResponsibilityExceptionWithReceiver:self selector:_cmd];
}


- (void)cancelResponse
{
    self.responding = NO;
}

@end


#pragma mark - Private Subclass Implementations

@implementation UMKMockHTTPErrorResponder

- (instancetype)initWithError:(NSError *)error
{
    self = [super init];
    if (self) {
        _error = error;
    }
    
    return self;
}


- (void)respondToMockRequest:(id<UMKMockURLRequest>)request client:(id<NSURLProtocolClient>)client protocol:(NSURLProtocol *)protocol
{
    self.responding = YES;
    [client URLProtocol:protocol didFailWithError:self.error];
    self.responding = NO;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"<UMKMockHTTPResponder: %p> error: %@", self, self.error];
}

@end


@implementation UMKMockHTTPResponseResponder

- (instancetype)initWithStatusCode:(NSInteger)statusCode headers:(NSDictionary *)headers body:(NSData *)body
                    chunkCountHint:(NSUInteger)hint delayBetweenChunks:(NSTimeInterval)delay
{
    NSParameterAssert(hint > 0);
    NSParameterAssert(delay >= 0.0);

    self = [super init];
    if (self) {
        self.body = body;
        self.headers = headers;
        _statusCode = statusCode;
        _chunkCountHint = hint;
        _delayBetweenChunks = delay;
    }
    
    return self;
}


- (void)respondToMockRequest:(id<UMKMockURLRequest>)request client:(id<NSURLProtocolClient>)client protocol:(NSURLProtocol *)protocol
{
    self.responding = YES;

    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:protocol.request.URL statusCode:self.statusCode
                                                             HTTPVersion:kUMKHTTP11VersionString headerFields:self.headers];

    // Stop if we were canceled in another thread.
    if (!self.responding) return;

    [client URLProtocol:protocol didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];

    if (self.body) {
        // Don't break the data into more chunks than there are bytes. If the body length is below the minimum, just use one chunk.
        NSUInteger chunkCount = self.body.length >= kUMKMinimumBodyLengthToChunk ? MIN(self.body.length, self.chunkCountHint) : 1;

        // If we have more than one chunk, delay at least the minimum amount. Otherwise don't delay
        NSTimeInterval delay = chunkCount > 1 ? MAX(kUMKMinimumDelayBetweenChunks, self.delayBetweenChunks) : 0.0;

        // Because body.length may not be evenly divisible by chunkCount, we write all but the last chunk out in
        // bytesPerChunk-sized chunks. On the last chunk, we just write whatever's left.
        NSUInteger bytesPerChunk = self.body.length / chunkCount;
        
        for (NSUInteger i = 0; i < chunkCount - 1 && self.responding; ++i) {
            [client URLProtocol:protocol didLoadData:[self.body subdataWithRange:NSMakeRange(i * bytesPerChunk, bytesPerChunk)]];

            if (delay > 0.0) {
                [NSThread sleepForTimeInterval:delay];
            }
        }

        if (!self.responding) return;

        NSUInteger startingLocation = (chunkCount - 1) * bytesPerChunk;
        [client URLProtocol:protocol didLoadData:[self.body subdataWithRange:NSMakeRange(startingLocation, self.body.length - startingLocation)]];
    }
    
    if (!self.responding) return;

    [client URLProtocolDidFinishLoading:protocol];
    self.responding = NO;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"<UMKMockHTTPResponder: %p> statusCode: %ld; headers = %@; body: %p; chunkCountHint: %lu, delayBetweenChunks: %.4f",
                self, (unsigned long)self.statusCode, self.headers, self.body, (unsigned long)self.chunkCountHint, self.delayBetweenChunks];
}

@end
