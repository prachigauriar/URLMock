//
//  UMKURLConnectionDelegateValidator.m
//  URLMock
//
//  Created by Prachi Gauriar on 11/12/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import "UMKURLConnectionDelegateValidator.h"
#import "UMKMessageCountingProxy.h"

@interface UMKURLConnectionDelegateValidator ()

@property (readwrite, strong, nonatomic) NSURLResponse *response;
@property (readwrite, strong, nonatomic) NSError *error;
@property (readwrite, strong, nonatomic) NSData *body;
@property (strong, nonatomic) NSMutableData *dataBeingBuilt;

@end


@implementation UMKURLConnectionDelegateValidator

- (instancetype)init
{
    self = [super init];
    if (self) {
        _messageCountingProxy = [UMKMessageCountingProxy messageCountingProxyWithObject:self];
    }

    return self;
}


- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.error = error;
}


- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (!self.dataBeingBuilt) {
        self.dataBeingBuilt = [[NSMutableData alloc] init];
    }

    [self.dataBeingBuilt appendData:data];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.response = response;
}


- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
}


- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.body = [self.dataBeingBuilt copy];
    self.dataBeingBuilt = nil;
}


@end
