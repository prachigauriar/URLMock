//
//  UMKURLEncodedParameterStringParser.h
//  URLMock
//
//  Created by Prachi Gauriar on 1/5/2014.
//  Copyright (c) 2014 Prachi Gauriar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UMKURLEncodedParameterStringParser : NSObject

@property (nonatomic, strong, readonly) NSString *string;
@property (nonatomic, assign, readonly) NSStringEncoding encoding;

- (instancetype)initWithString:(NSString *)string encoding:(NSStringEncoding)encoding;

- (NSDictionary *)parse;

@end
