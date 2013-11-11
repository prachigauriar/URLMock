//
//  UMOMockURLProtocol.h
//  URLMock
//
//  Created by Prachi Gauriar on 11/9/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UMOMockHTTPRequest, UMOMockHTTPResponse;

@interface UMOMockURLProtocol : NSURLProtocol

+ (void)enable;
+ (void)resetAndEnable;
+ (void)reset;
+ (void)resetAndDisable;
+ (void)disable;

+ (BOOL)interceptsAllRequests;
+ (void)setInterceptsAllRequests:(BOOL)interceptsAllRequests;

+ (NSURL *)canonicalURLForURL:(NSURL *)URL;

+ (void)expectMockRequest:(UMOMockHTTPRequest *)request;
+ (BOOL)hasRespondedToMockRequest:(UMOMockHTTPRequest *)request;

@end
