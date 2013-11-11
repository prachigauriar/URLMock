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

        [UMOMockURLProtocol setInterceptsAllRequests:YES];

        UMOMockHTTPRequest *request = [UMOMockHTTPRequest mockGetRequestWithURLString:@"http://api.host.com:1234/v1/path/to/resource"];

        // This automatically sets the content-type header if it hasn't previously been set
        [request setBodyByURLEncodingParameters:@{ @"param1" : @"value1", @"param2" : @"value2" }];

        // Respond with an error
        request.response = [UMOMockHTTPResponse mockResponseWithError:[NSError errorWithDomain:NSURLErrorDomain code:123 userInfo:nil]];

        // Respond with an actual body
        request.response = [UMOMockHTTPResponse mockResponseWithStatusCode:200 body:nil];

        // Also sets content-type header if it hasn't previously been set
        [request.response setBodyWithJSONObject:@{ @"mind" : @"blown", @"or": @"not" }];

        [UMOMockURLProtocol expectMockRequest:request];
        [UMOMockURLProtocol resetAndDisable];
    }

    return 0;
}

