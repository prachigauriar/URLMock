//
//  UMKTestUtilities.m
//
//  Created by Prachi Gauriar on 5/29/2013.
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

#import "UMKTestUtilities.h"

NSString *UMKRandomAlphanumericString(void)
{
    return UMKRandomAlphanumericStringWithLength(1 + random() % 128);
}


NSString *UMKRandomAlphanumericStringWithLength(NSUInteger length)
{
    NSCParameterAssert(length > 0);

    static const char *alphanumericCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    static const NSUInteger alphanumericCharacterCount = 62;

    char *randomCString = calloc(length, sizeof(char) + 1);
    for (NSUInteger i = 0; i < length; ++i) {
        randomCString[i] = alphanumericCharacters[random() % alphanumericCharacterCount];
    }
    
    return [NSString stringWithUTF8String:randomCString];
}


BOOL UMKRandomBoolean()
{
    return random() & 01;
}


NSNumber *UMKRandomUnsignedNumber(void)
{
    return [NSNumber numberWithUnsignedInteger:random()];
}


NSNumber *UMKRandomUnsignedNumberInRange(NSRange range)
{
    NSCParameterAssert(range.length > 0);
    return [NSNumber numberWithUnsignedInteger:(range.location + random() % range.length)];
}


BOOL UMKWaitForCondition(NSTimeInterval timeoutInterval, BOOL (^condition)(void))
{
    NSCParameterAssert(timeoutInterval >= 0.0);
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];

    BOOL conditionResult = NO;
    while(!(conditionResult = condition()) && [NSDate timeIntervalSinceReferenceDate] - start <= timeoutInterval) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
    }

    return conditionResult;
}
