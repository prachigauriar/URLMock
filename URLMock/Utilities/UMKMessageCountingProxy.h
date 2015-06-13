//
//  UMKMessageCountingProxy.h
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

#import <Foundation/Foundation.h>


/*!
 Instances of UMKMessageCountingProxy count how many times their associated objects have received messages.
 This is useful when testing that APIs are actually being invoked.
 
 Message counting proxies only count messages when the message is sent through the proxy. If the message is
 sent directly to the proxy's object, the proxy can't count that message.
 */
@interface UMKMessageCountingProxy : NSProxy

/*! The instance's object. */
@property (nonatomic, strong, readonly) NSObject *object;

/*!
 @abstract Initializes a newly allocated proxy to count messages for the specified object.
 @discussion This is the only initializer for this class. It does not respond to -init.
 @param object The object for which the proxy will count messages. May not be nil.
 @result An initialized proxy object that counts the messages for the specified object.
 */
- (instancetype)initWithObject:(NSObject *)object;

/*! 
 @abstract Creates and returns a proxy that counts messages for the specified object.
 @param object The object for which the proxy will count messages. May not be nil.
 @result A new proxy object that counts the messages for the specified object.
 */
+ (instancetype)messageCountingProxyWithObject:(NSObject *)object;


/*! @methodgroup Counting messages */

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
