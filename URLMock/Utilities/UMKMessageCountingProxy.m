//
//  UMKMessageCountingProxy.m
//  URLMock
//
//  Created by Prachi Gauriar on 11/12/2013.
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

#import <URLMock/UMKMessageCountingProxy.h>


@interface UMKMessageCountingProxy ()

@property (nonatomic, strong) NSMutableDictionary *receivedMessageCounts;

@end


#pragma mark -

@implementation UMKMessageCountingProxy

+ (instancetype)messageCountingProxyWithObject:(NSObject *)object
{
    return [[self alloc] initWithObject:object];
}


- (instancetype)initWithObject:(NSObject *)object
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
