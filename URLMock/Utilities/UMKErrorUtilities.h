//
//  UMKErrorUtilities.h
//  URLMock
//
//  Created by Prachi Gauriar on 12/6/2012.
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

/*!
 @header UMKErrorUtilities
 @abstract Defines utility functions and categories for use when creating assertions and exceptions.
 @discussion The utility functions allow for easily formatting selectors, method names, and assertion/exception reasons,
     among other tasks.
 */

#import <Foundation/Foundation.h>


/*!
 @abstract Returns an NSString representation of the selector.
 @discussion This simply returns the result of NSStringFromSelector(selector), prefixed with a '+' if receiver is 
     a class and '-' otherwise.
 @param receiver The object responding to the selector.
 @param selector The selector to which the receiver will be responding.
 @result A pretty-printed NSString representation of the selector.
 */
extern NSString *UMKPrettySelector(id receiver, SEL selector);

/*!
 @abstract Returns an NSString representation of the selector.
 @discussion The string is of the form \@"+[receiver selector]" for class methods and \@"-[receiverClassName selector]"
     for instance methods.
 @param receiver The object responding to the selector.
 @param selector The selector to which the receiver will be responding.
 @result A pretty-printed NSString representation of the method name, including the receiving class.
 */
extern NSString *UMKPrettyMethodName(id receiver, SEL selector);

/*!
 @abstract Returns an NSString that is formatted suitably for use as an assertion message.
 @discussion Formatting is consistent with Apple's own assertion messages.
 @param receiver The object responding to the selector. This is typically self.
 @param selector The selector to which the receiver will be responding. This is typically _cmd.
 @param format A format string describing the reason for the assertion.
 @result An NSString formatted suitable for use as an assertion message.
 */
extern NSString *UMKAssertionString(id receiver, SEL selector, NSString *format, ...) NS_FORMAT_FUNCTION(3, 4);

/*!
 @abstract Returns an NSString that is formatted suitably for use as an exception message.
 @discussion Formatting is consistent with Apple's own exception messages.
 @param receiver The object responding to the selector. This is typically self.
 @param selector The selector to which the receiver will be responding. This is typically _cmd.
 @param format A format string describing the reason for the exception.
 @result An NSString formatted suitable for use as an exception message.
 */
extern NSString *UMKExceptionString(id receiver, SEL selector, NSString *format, ...) NS_FORMAT_FUNCTION(3, 4);
