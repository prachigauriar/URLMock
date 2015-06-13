//
//  UMKURLSessionDataTaskVerifier.h
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

#import <Foundation/Foundation.h>


/*!
 UMKURLSessionDataTaskVerifier objects help validate that NSURLSession data tasks are receiving the correct 
 responses. They are designed to be used as a session data task’s delegate. They save the task’s response, 
 error, and body, and can indicate if a task is complete, i.e., it has finished loading or failed with an error.

 When used with a UMKMessageCountingProxy, data task verifiers can be used to ensure that a data task delegate
 received the correct delegate messages.

 If the verifier's session uses a delegate operation queue, or delegate methods are being invoked on their own
 thread, you can use -waitForCompletion or -waitForCompletionWithTimeout: to efficiently wait until the data task
 is complete. This is very useful when using data task verifiers in unit testing.

 Note that data task verifiers are only meant to be used once per data task. Create a new instance if you need
 to verify another data task.
 */
@interface UMKURLSessionDataTaskVerifier : NSObject <NSURLSessionDataDelegate>

/*! Whether the instance's task has finished loading or failed with an error. */
@property (nonatomic, assign, readonly, getter = isComplete) BOOL complete;

/*! The instance's task’s response. */
@property (nonatomic, strong, readonly) NSURLResponse *response;

/*! The instance's task’s error. This is set if the data task failed with an error. */
@property (nonatomic, strong, readonly) NSError *error;

/*! The body that was returned from the instance's data task. This is set when the task has finished loading. */
@property (nonatomic, copy, readonly) NSData *body;


/*! @methodgroup Waiting for completion */

/*!
 @abstract Blocks the current thread and returns when the instance’s data task has completed.
 @discussion Returns immediately if the task is already complete. This should only be invoked if the
     session uses a delegate operation queue or if the calling thread is not the same as the thread the
     data task was started on.
 */
- (void)waitForCompletion;

/*!
 @abstract Blocks the current thread and returns when the instance’s data task has completed or the timeout 
     has elapsed.
 @discussion Returns immediately if the task is already complete. This should only be invoked if the
     session uses a delegate operation queue or if the calling thread is not the same as the thread the
     data task was started on.
 @param timeout The maximum time interval that the instance should wait for its data task to complete.
 @result Whether the instance's data task is complete.
 */
- (BOOL)waitForCompletionWithTimeout:(NSTimeInterval)timeout;

@end
