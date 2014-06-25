//
//  UMKURLSessionDataTaskVerifier.m
//  URLMock
//
//  Created by Prachi Gauriar on 6/23/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import "UMKURLSessionDataTaskVerifier.h"

@interface UMKURLSessionDataTaskVerifier ()

@property (nonatomic, assign, readwrite, getter = isComplete) BOOL complete;
@property (nonatomic, strong, readwrite) NSURLResponse *response;
@property (nonatomic, strong, readwrite) NSError *error;
@property (nonatomic, copy, readwrite) NSData *body;

@property (nonatomic, strong) NSMutableData *dataBeingBuilt;
@property (nonatomic, strong, readonly) NSCondition *completeCondition;

@end


@implementation UMKURLSessionDataTaskVerifier

- (instancetype)init
{
    self = [super init];
    if (self) {
        _completeCondition = [[NSCondition alloc] init];
    }

    return self;
}


- (void)waitForCompletion
{
    [self.completeCondition lock];

    while (!self.complete) {
        [self.completeCondition wait];
    }

    [self.completeCondition unlock];
}


- (BOOL)waitForCompletionWithTimeout:(NSTimeInterval)timeout
{
    NSDate *endDate = [[NSDate date] dateByAddingTimeInterval:timeout];
    [self.completeCondition lock];

    // Keep waiting until we're complete or we've timed out
    while (!self.complete && [self.completeCondition waitUntilDate:endDate]);

    [self.completeCondition unlock];
    return self.complete;
}


- (void)setComplete:(BOOL)complete
{
    [self.completeCondition lock];
    _complete = complete;
    [self.completeCondition broadcast];
    [self.completeCondition unlock];
}


#pragma mark - NSURLSessionDataDelegate methods

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    self.body = [self.dataBeingBuilt copy];
    self.dataBeingBuilt = nil;
    self.error = error;
    self.complete = YES;
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler
{
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler
{
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    self.response = response;
    completionHandler(NSURLSessionResponseAllow);
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    if (!self.dataBeingBuilt) {
        self.dataBeingBuilt = [[NSMutableData alloc] init];
    }

    [self.dataBeingBuilt appendData:data];
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
}

@end
