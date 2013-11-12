//
//  UMOMockHTTPResponse.m
//  URLMock
//
//  Created by Prachi Gauriar on 11/8/2013.
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

#import <URLMock/UMOMockHTTPResponse.h>
#import <URLMock/UMOMockHTTPRequest.h>
#import <URLMock/PGUtilities.h>

#pragma mark Constants

// This was arrived at empirically. The NSURL system appears to coalesce payloads smaller than 2048 bytes
static const NSUInteger kUMOMinimumBodyLengthToChunk = 2048;

// This was arrived at empirically as well
static const NSTimeInterval kUMOMinimumDelayBetweenChunks = 0.0001;

static NSString *const kUMOHTTP11VersionString = @"HTTP/1.1";


#pragma mark -

@interface UMOMockHTTPResponse ()
@property (nonatomic, getter = isResponding) BOOL responding;
@end


#pragma mark - Private Subclass Interfaces

@interface UMOMockHTTPErrorResponse : UMOMockHTTPResponse

@property (readonly, strong, nonatomic) NSError *error;

- (instancetype)initWithError:(NSError *)error;

@end


@interface UMOMockHTTPDataResponse : UMOMockHTTPResponse

@property (readonly, nonatomic) NSInteger statusCode;
@property (readonly, nonatomic) NSUInteger chunkCount;
@property (readonly, nonatomic) NSTimeInterval delay;

- (instancetype)initWithStatusCode:(NSInteger)statusCode headers:(NSDictionary *)headers body:(NSData *)body chunkCountHint:(NSUInteger)hint delayBetweenChunks:(NSTimeInterval)delay;

@end


#pragma mark - Base Class Implementation

@implementation UMOMockHTTPResponse

+ (instancetype)mockResponseWithError:(NSError *)error
{
    return [self mockResponseWithError:error delay:0.0];
}


+ (instancetype)mockResponseWithError:(NSError *)error delay:(NSTimeInterval)delay
{
    return [[UMOMockHTTPErrorResponse alloc] initWithError:error];
}


+ (instancetype)mockResponseWithStatusCode:(NSInteger)statusCode
{
    return [self mockResponseWithStatusCode:statusCode headers:nil body:nil chunkCountHint:1 delayBetweenChunks:0.0];
}


+ (instancetype)mockResponseWithStatusCode:(NSInteger)statusCode headers:(NSDictionary *)headers
{
    return [self mockResponseWithStatusCode:statusCode headers:headers body:nil chunkCountHint:1 delayBetweenChunks:0.0];
}


+ (instancetype)mockResponseWithStatusCode:(NSInteger)statusCode body:(NSData *)body
{
    return [self mockResponseWithStatusCode:statusCode headers:nil body:body chunkCountHint:1 delayBetweenChunks:0.0];
}


+ (instancetype)mockResponseWithStatusCode:(NSInteger)statusCode headers:(NSDictionary *)headers body:(NSData *)body
{
    
    
    return [self mockResponseWithStatusCode:statusCode headers:headers body:body chunkCountHint:1 delayBetweenChunks:0.0];
}


+ (instancetype)mockResponseWithStatusCode:(NSInteger)statusCode headers:(NSDictionary *)headers body:(NSData *)body chunkCountHint:(NSUInteger)chunkCountHint
{
    return [self mockResponseWithStatusCode:statusCode headers:headers body:body chunkCountHint:chunkCountHint delayBetweenChunks:0.0];
}


+ (instancetype)mockResponseWithStatusCode:(NSInteger)statusCode headers:(NSDictionary *)headers body:(NSData *)body chunkCountHint:(NSUInteger)chunkCountHint delayBetweenChunks:(NSTimeInterval)delay
{
    if (chunkCountHint == 0) {
        [NSException raise:NSInvalidArgumentException format:@"%@", PGExceptionString(self, _cmd, @"chunkCountHint must be positive")];
    } else if (delay < 0.0) {
        [NSException raise:NSInvalidArgumentException format:@"%@", PGExceptionString(self, _cmd, @"delay must be non-negative")];
    }

    return [[UMOMockHTTPDataResponse alloc] initWithStatusCode:statusCode headers:headers body:body chunkCountHint:chunkCountHint delayBetweenChunks:delay];
}

- (void)respondToMockRequest:(UMOMockHTTPRequest *)request client:(id <NSURLProtocolClient>)client protocol:(NSURLProtocol *)protocol
{
    [NSException raise:NSInternalInconsistencyException format:@"%@", PGExceptionString(self, _cmd, @"subclass responsibility")];
}


- (void)cancelResponse
{
    self.responding = NO;
}

@end


#pragma mark - Private Subclass Implementations

@implementation UMOMockHTTPErrorResponse

- (instancetype)initWithError:(NSError *)error
{
    self = [super init];
    if (self) {
        _error = error;
    }
    
    return self;
}


- (void)respondToMockRequest:(UMOMockHTTPRequest *)request client:(id <NSURLProtocolClient>)client protocol:(NSURLProtocol *)protocol
{
    self.responding = YES;
    [client URLProtocol:protocol didFailWithError:self.error];
    self.responding = NO;
}

@end


@implementation UMOMockHTTPDataResponse

- (instancetype)initWithStatusCode:(NSInteger)statusCode headers:(NSDictionary *)headers body:(NSData *)body chunkCountHint:(NSUInteger)hint delayBetweenChunks:(NSTimeInterval)delay
{
    NSParameterAssert(hint > 0);
    NSParameterAssert(delay >= 0.0);

    self = [super init];
    if (self) {
        self.body = body;
        self.headers = headers;
        _statusCode = statusCode;

        // If the body length exceeds the minimum to chunk, break the data into at least 1-byte chunks
        _chunkCount = body.length >= kUMOMinimumBodyLengthToChunk ? MAX(body.length, hint) : 1;

        // If we have more than one chunk, delay at least the minimum amount. Otherwise don't delay
        _delay = _chunkCount > 1 ? MAX(kUMOMinimumDelayBetweenChunks, _delay) : 0.0;
    }
    
    return self;
}


- (void)respondToMockRequest:(UMOMockHTTPRequest *)request client:(id <NSURLProtocolClient>)client protocol:(NSURLProtocol *)protocol
{
    self.responding = YES;

    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:self.statusCode
                                                             HTTPVersion:kUMOHTTP11VersionString headerFields:self.headers];

    // Stop if we were canceled
    if (!self.responding) return;

    [client URLProtocol:protocol didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];

    if (self.body) {
        // Because body.length may not be evenly divisible by chunkCount, we write all but the last chunk out in
        // bytesPerChunk-sized chunks. On the last chunk, we just write whatever's left.
        NSUInteger bytesPerChunk = self.body.length / self.chunkCount;
        
        for (NSUInteger i = 0; i < self.chunkCount - 1 && self.responding; ++i) {
            [client URLProtocol:protocol didLoadData:[self.body subdataWithRange:NSMakeRange(i * bytesPerChunk, bytesPerChunk)]];

            if (self.delay > 0.0) {
                [NSThread sleepForTimeInterval:self.delay];
            }
        }

        if (!self.responding) return;

        NSUInteger startingLocation = (self.chunkCount - 1) * bytesPerChunk;
        [client URLProtocol:protocol didLoadData:[self.body subdataWithRange:NSMakeRange(startingLocation, self.body.length - startingLocation)]];
    }
    
    if (!self.responding) return;

    [client URLProtocolDidFinishLoading:protocol];
    self.responding = NO;
}

@end
