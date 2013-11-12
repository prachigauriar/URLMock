//
//  UMOURLConnectionDelegateValidator.h
//  URLMock
//
//  Created by Prachi Gauriar on 11/12/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UMOURLConnectionDelegateValidator : NSObject <NSURLConnectionDataDelegate>

@property (readonly, strong, nonatomic) id messageCountingProxy;
@property (readonly, strong, nonatomic) NSURLResponse *response;
@property (readonly, strong, nonatomic) NSError *error;
@property (readonly, strong, nonatomic) NSData *body;

@end
