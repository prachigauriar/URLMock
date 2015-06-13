//
//  UMKURLSessionDataTaskVerifier.m
//  URLMock
//
//  Created by Prachi Gauriar on 6/23/2014.
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

#import "UMKURLSessionDataTaskVerifier.h"


@interface UMKURLSessionDataTaskVerifier ()

@property (nonatomic, assign, readwrite, getter = isComplete) BOOL complete;
@property (nonatomic, strong, readwrite) NSURLResponse *response;
@property (nonatomic, strong, readwrite) NSError *error;
@property (nonatomic, copy, readwrite) NSData *body;

@property (nonatomic, strong) NSMutableData *dataBeingBuilt;
@property (nonatomic, strong, readonly) NSCondition *completeCondition;

@end


#pragma mark -

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
