//
//  UMKMessageCountingProxy.m
//  URLMock
//
//  Created by Prachi Gauriar on 11/12/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import "UMKMessageCountingProxy.h"

@interface UMKMessageCountingProxy ()
@property (readwrite, strong, nonatomic) NSMutableDictionary *receivedMessageCounts;
@end


@implementation UMKMessageCountingProxy

+ (instancetype)messageCountingProxyWithObject:(NSObject *)object
{
    return [[self alloc] initWithObject:object];
}


- (id)initWithObject:(NSObject *)object
{
    NSParameterAssert(object);

    // Don't call [super init], as NSProxy does not recognize -init.
    _object = object;
    _receivedMessageCounts = [[NSMutableDictionary alloc] init];

    return self;
}


- (BOOL)hasReceivedSelector:(SEL)selector
{
    return [self receivedMessageCountForSelector:selector] != 0;
}


- (NSUInteger)receivedMessageCountForSelector:(SEL)selector
{
    return [[self.receivedMessageCounts objectForKey:NSStringFromSelector(selector)] unsignedIntegerValue];
}


- (void)forwardInvocation:(NSInvocation *)invocation
{
    NSString *selectorString = NSStringFromSelector(invocation.selector);
    self.receivedMessageCounts[selectorString] = @([self.receivedMessageCounts[selectorString] unsignedIntegerValue] + 1);
    [invocation invokeWithTarget:self.object];
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    return [self.object methodSignatureForSelector:selector];
}

@end
