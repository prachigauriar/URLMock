//
//  UMKParameterPair.h
//  URLMock
//
//  Created by Prachi Gauriar on 1/5/2014.
//  Copyright (c) 2014 Prachi Gauriar, (c) 2013 AFNetworking (http://afnetworking.com/)
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

#import <Foundation/Foundation.h>

/*!
 @note Much of this code is adapted or borrowed from AFNetworking.
 */
@interface UMKParameterPair : NSObject

@property (nonatomic, strong) id key;
@property (nonatomic, strong) id value;

- (instancetype)initWithKey:(id)key value:(id)value;
- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)encoding;

@end



@interface NSObject (UMKParameterPairs)

- (NSArray *)umk_parameterPairsWithKey:(NSString *)key;

@end


@interface NSArray (UMKParameterPairs)

- (NSArray *)umk_parameterPairsWithKey:(NSString *)key;

@end


@interface NSDictionary (UMKParameterPairs)

- (NSArray *)umk_parameterPairsWithKey:(NSString *)key;

@end


@interface NSSet (UMKParameterPairs)

- (NSArray *)umk_parameterPairsWithKey:(NSString *)key;

@end
