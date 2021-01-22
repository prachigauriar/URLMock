//
//  UMKErrorUtilities.m
//  URLMock
//
//  Created by Prachi Gauriar on 12/6/2012.
//  Copyright (c) 2015 Prachi Gauriar.
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

#import <URLMock/UMKErrorUtilities.h>

#import <objc/runtime.h>


NSString *UMKPrettySelector(id receiver, SEL selector)
{
    char methodType = class_isMetaClass([receiver class]) ? '+' : '-';
    return [NSString stringWithFormat:@"%c%@", methodType, NSStringFromSelector(selector)];
}


NSString *UMKPrettyMethodName(id receiver, SEL selector)
{
    char methodType = class_isMetaClass([receiver class]) ? '+' : '-';
    return [NSString stringWithFormat:@"%c[%@ %@]", methodType, NSStringFromClass([receiver class]), NSStringFromSelector(selector)];
}


NSString *UMKAssertionString(id receiver, SEL selector, NSString *format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    NSString *messageString = [[NSString alloc] initWithFormat:format arguments:arguments];
    va_end(arguments);
    
    return [NSString stringWithFormat:@"*** %@: %@", UMKPrettyMethodName(receiver, selector), messageString];
}


NSString *UMKExceptionString(id receiver, SEL selector, NSString *format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    NSString *messageString = [[NSString alloc] initWithFormat:format arguments:arguments];
    va_end(arguments);

    return [NSString stringWithFormat:@"*** %@: %@", UMKPrettyMethodName(receiver, selector), messageString];
}
