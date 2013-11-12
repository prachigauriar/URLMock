//
//  UMOMessageCountingProxy.h
//  URLMock
//
//  Created by Prachi Gauriar on 11/12/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UMOMessageCountingProxy : NSProxy

@property (readonly, strong, nonatomic) NSObject *object;

+ (instancetype)messageCountingProxyWithObject:(NSObject *)object;

- (BOOL)hasReceivedSelector:(SEL)selector;
- (NSUInteger)receivedMessageCountForSelector:(SEL)selector;

@end
