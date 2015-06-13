//
//  UMKURLConnectionVerifier.h
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
 UMKURLConnectionVerifier objects help validate that NSURLConnections are receiving the correct responses. They
 are designed to be used as a connection's delegate. They save the connection's response, error, and body, and can
 indicate if a connection is complete, i.e., it has finished loading or failed with an error.
 
 When used with a UMKMessageCountingProxy, connection verifiers can be used to ensure that a connection delegate
 received the correct delegate messages.
 
 If the verifier's connection uses a delegate operation queue, or delegate methods are being invoked on their own
 thread, you can use -waitForCompletion or -waitForCompletionWithTimeout: to efficiently wait until the connection
 is complete. This is very useful when using connection verifiers in unit testing.
 
 Note that connection verifiers are only meant to be used once per connection. Create a new instance if you need 
 to verify another connection.
 */
@interface UMKURLConnectionVerifier : NSObject <NSURLConnectionDataDelegate>

/*! Whether the instance's connection has finished loading or failed with an error. */
@property (nonatomic, assign, readonly, getter = isComplete) BOOL complete;

/*! The instance's connection's response. */
@property (nonatomic, strong, readonly) NSURLResponse *response;

/*! The instance's connection's error. This is set if the connection failed with an error. */
@property (nonatomic, strong, readonly) NSError *error;

/*! The body that was returned from the instance's connection. This is set when the connection has finished loading. */
@property (nonatomic, copy, readonly) NSData *body;


/*! @methodgroup Waiting for completion */

/*!
 @abstract Blocks the current thread and returns when the instance’s connection has completed.
 @discussion Returns immediately if the connection is already complete. This should only be invoked if the
     connection uses a delegate operation queue or if the calling thread is not the same as the thread the 
     connection was started on.
 */
- (void)waitForCompletion;

/*!
 @abstract Blocks the current thread and returns when the instance’s connection has completed or the timeout
     has elapsed.
 @discussion Returns immediately if the connection is already complete. This should only be invoked if the
     connection uses a delegate operation queue or if the calling thread is not the same as the thread the
     connection was started on.
 @param timeout The maximum time interval that the instance should wait for its connection to complete.
 @result Whether the instance's connection is complete.
 */
- (BOOL)waitForCompletionWithTimeout:(NSTimeInterval)timeout;

@end
