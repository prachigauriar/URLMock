//
//  UMKRandomizedTestCase.m
//  URLMock
//
//  Created by Prachi Gauriar on 12/14/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import "UMKRandomizedTestCase.h"

@implementation UMKRandomizedTestCase

+ (void)setUp
{
    [super setUp];
    srandomdev();
}


- (void)setUp
{
    [super setUp];
    unsigned seed = (unsigned)random();
    NSLog(@"Using seed %d", seed);
    srandom(seed);
}

@end
