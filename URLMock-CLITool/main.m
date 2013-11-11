//
//  main.m
//  URLMock-CLITool
//
//  Created by Prachi Gauriar on 11/10/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <URLMock/URLMock.h>

int main(int argc, const char *argv[])
{
    @autoreleasepool {
        [UMOMockURLProtocol enable];

        UMOMockHTTPRequest *request = [UMOMockHTTPRequest mockGetRequestWithURLString:@"http://api.host.com:1234/v1/blah"];
        [request setBodyByURLEncodingParameters:@{ @"param1" : @"value1", @"param2" : @"value2" };
        
         
    }

    return 0;
}

