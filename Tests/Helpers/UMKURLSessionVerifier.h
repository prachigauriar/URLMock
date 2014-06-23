//
//  UMKURLSessionVerifier.h
//  URLMock
//
//  Created by Prachi Gauriar on 6/23/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UMKURLSessionVerifier : NSObject <NSURLSessionDataDelegate>

@property (nonatomic, assign, readonly, getter = isComplete) BOOL complete;

/*! The instance's session's response. */
@property (nonatomic, strong, readonly) NSURLResponse *response;

/*! The instance's connection's error. This is set if the connection failed with an error. */
@property (nonatomic, strong, readonly) NSError *error;

/*! The body that was returned from the instance's connection. This is set when the connection has finished loading. */
@property (nonatomic, copy, readonly) NSData *body;

@end
