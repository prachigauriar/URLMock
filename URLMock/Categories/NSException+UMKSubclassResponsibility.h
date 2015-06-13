//
//  NSException+UMKSubclassResponsibility.h
//  URLMock
//
//  Created by Prachi Gauriar on 1/5/2014.
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
 The UMKSubclassResponsibility category of NSException provides a convenience factory method for creating
 exceptions when implementing a given method is a subclass's responsibility.
 */
@interface NSException (UMKSubclassResponsibility)

/*!
 @abstract Creates and returns a new NSInternalInconsistencyException indicating that implementing
     the method specified by the given receiver-selector pair is a subclass's responsibility.
 @param receiver The object responding to the selector. This is typically self.
 @param selector The selector to which the receiver will be responding. This is typically _cmd.
 @result A new NSInternalInconsistencyException
 */
+ (instancetype)umk_subclassResponsibilityExceptionWithReceiver:(id)receiver selector:(SEL)selector;

@end
