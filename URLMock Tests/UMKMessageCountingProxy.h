//
//  UMKMessageCountingProxy.h
//  URLMock
//
//  Created by Prachi Gauriar on 11/12/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 Instances of UMKMessageCountingProxy count how many times their associated objects have received messages.
 This is useful when testing that APIs are actually being invoked.
 
 Message counting proxies only count messages when the message is sent through the proxy. If the message is
 sent directly to the proxy's object, the proxy can't count that message.
 */
@interface UMKMessageCountingProxy : NSProxy

/*! The instance's object. */
@property (readonly, strong, nonatomic) NSObject *object;

/*!
 @abstract Initializes a newly allocated proxy to count messages for the specified object.
 @discussion This is the only initializer for this class. It does not respond to -init.
 @param object The object for which the proxy will count messages. May not be nil.
 @result An initialized proxy object that counts the messages for the specified object.
 */
- (id)initWithObject:(NSObject *)object;

/*! 
 @abstract Creates and returns a proxy that counts messages for the specified object.
 @param object The object for which the proxy will count messages. May not be nil.
 @result An new proxy object that counts the messages for the specified object.
 */
+ (instancetype)messageCountingProxyWithObject:(NSObject *)object;


/*!
 @abstract Returns whether the receiver's object has received the specified selector.
 @discussion This is equivalent to checking if the return value of -receivedMessageCountForSelector:
     is non-zero.
 @param selector The selector.
 @result Whether the receiver's object has received the specified selector.
 */
- (BOOL)hasReceivedSelector:(SEL)selector;

/*!
 @abstract Returns the number of times the receiver's object has received the specified selector.
 @discussion This count only reflects the messages that have passed through the receiver to its
     object. Messages sent directly to the object are not counted.
 @param selector The selector.
 @result The number of times the receiver's object has received the specified selector.
 */
- (NSUInteger)receivedMessageCountForSelector:(SEL)selector;

@end
