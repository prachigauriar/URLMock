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

static NSString *const kUMOHTTP11VersionString = @"HTTP/1.1";


#pragma mark - Private Subclass Interfaces

@interface UMOMockHTTPErrorResponse : UMOMockHTTPResponse

@property (readonly, strong, nonatomic) NSError *error;

- (instancetype)initWithError:(NSError *)error;

@end


@interface UMOMockHTTPDataResponse : UMOMockHTTPResponse

@property (readonly, nonatomic) NSInteger statusCode;
@property (readonly, nonatomic) NSUInteger chunkCount;

- (instancetype)initWithStatusCode:(NSInteger)statusCode headers:(NSDictionary *)headers body:(NSData *)body chunkCount:(NSUInteger)chunkCount;

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


+ (instancetype)mockResponseWithStatusCode:(NSInteger)statusCode headers:(NSDictionary *)headers
{
    return [self mockResponseWithStatusCode:statusCode headers:headers body:nil chunkCount:1];
}


+ (instancetype)mockResponseWithStatusCode:(NSInteger)statusCode body:(NSData *)body
{
    return [self mockResponseWithStatusCode:statusCode headers:nil body:body chunkCount:1];
}


+ (instancetype)mockResponseWithStatusCode:(NSInteger)statusCode headers:(NSDictionary *)headers body:(NSData *)body
{
    
    
    return [self mockResponseWithStatusCode:statusCode headers:headers body:body chunkCount:1];
}


+ (instancetype)mockResponseWithStatusCode:(NSInteger)statusCode headers:(NSDictionary *)headers body:(NSData *)body chunkCount:(NSUInteger)chunkCount;
{
    if (chunkCount == 0) {
        [NSException raise:NSInvalidArgumentException format:@"%@", PGExceptionString(self, _cmd, @"chunkCount must be positive")];
    }
    
    return [[UMOMockHTTPDataResponse alloc] initWithStatusCode:statusCode headers:headers body:body chunkCount:chunkCount];
}


- (void)respondToMockRequest:(UMOMockHTTPRequest *)request client:(id <NSURLProtocolClient>)client protocol:(NSURLProtocol *)protocol
{
    [NSException raise:NSInternalInconsistencyException format:@"%@", PGExceptionString(self, _cmd, @"subclass responsibility")];
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
    [client URLProtocol:protocol didFailWithError:self.error];
}

@end


@implementation UMOMockHTTPDataResponse

- (instancetype)initWithStatusCode:(NSInteger)statusCode headers:(NSDictionary *)headers body:(NSData *)body chunkCount:(NSUInteger)chunkCount
{
    NSParameterAssert(chunkCount > 0);
    
    self = [super init];
    if (self) {
        _statusCode = statusCode;
        _chunkCount = chunkCount;
        self.body = body;
        self.headers = headers;
    }
    
    return self;
}


- (void)respondToMockRequest:(UMOMockHTTPRequest *)request client:(id <NSURLProtocolClient>)client protocol:(NSURLProtocol *)protocol
{
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:request.URL
                                                              statusCode:self.statusCode
                                                             HTTPVersion:kUMOHTTP11VersionString
                                                            headerFields:self.headers];
    
    [client URLProtocol:protocol didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];

    if (self.body) {
        // Because body.length may not be evenly divisible by chunkCount, we write all but the last chunk out in
        // bytesPerChunk-sized chunks. On the last chunk, we just write whatever's left.
        NSUInteger bytesPerChunk = self.body.length / self.chunkCount;
        
        for (NSUInteger i = 0; i < self.chunkCount - 1; ++i) {
            [client URLProtocol:protocol didLoadData:[self.body subdataWithRange:NSMakeRange(i * bytesPerChunk, bytesPerChunk)]];
        }

        NSUInteger startingLocation = (self.chunkCount - 1) * bytesPerChunk;
        [client URLProtocol:protocol didLoadData:[self.body subdataWithRange:NSMakeRange(startingLocation, self.body.length - startingLocation)]];
    }
    
    [client URLProtocolDidFinishLoading:protocol];
}

@end
