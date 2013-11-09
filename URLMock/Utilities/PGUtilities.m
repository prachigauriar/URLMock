//
//  PGUtilities.m
//
//  Created by Prachi Gauriar on 12/6/2012.
//  Copyright (c) 2013 Prachi Gauriar.
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

#import "PGUtilities.h"

#pragma mark Constants

NSString *const PGErrorDomain = @"PGErrorDomain";


#pragma mark - Functions

NSArray *PGCommandLineArgumentsAsStrings(int argc, const char *argv[])
{
    NSMutableArray *args = [NSMutableArray arrayWithCapacity:argc];
    for (NSUInteger i = 0; i < argc; ++i) {
        [args addObject:@(argv[i])];
    }
    
    return args;
}


NSString *PGPrettySelector(id receiver, SEL selector)
{
    char methodType = [receiver isMemberOfClass:[receiver class]] ? '-' : '+';
    return [NSString stringWithFormat:@"%c%@", methodType, NSStringFromSelector(selector)];
}


NSString *PGPrettyMethodName(id receiver, SEL selector)
{
    char methodType = [receiver isMemberOfClass:[receiver class]] ? '-' : '+';
    return [NSString stringWithFormat:@"%c[%@ %@]", methodType, NSStringFromClass([receiver class]), NSStringFromSelector(selector)];
}


NSString *PGAssertionString(id receiver, SEL selector, NSString *format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    NSString *messageString = [[NSString alloc] initWithFormat:format arguments:arguments];
    va_end(arguments);
    
    return [NSString stringWithFormat:@"*** %@: %@", PGPrettyMethodName(receiver, selector), messageString];
}


NSString *PGExceptionString(id receiver, SEL selector, NSString *format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    NSString *messageString = [[NSString alloc] initWithFormat:format arguments:arguments];
    va_end(arguments);

    return [NSString stringWithFormat:@"*** %@: %@", PGPrettyMethodName(receiver, selector), messageString];
}
