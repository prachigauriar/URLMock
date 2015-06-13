//
//  UMKPatternMatchingMockRequest.h
//  URLMock
//
//  Created by Prachi Gauriar on 6/25/2014.
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

#import <Foundation/Foundation.h>
#import <URLMock/UMKMockURLProtocol.h>


/*!
 @abstract Block type that return whether a mock request matches a request.
 @discussion This block type is used by pattern-matching mock requests to determine if the mock request matches
     a request.
 @param request The request being matched
 @param parameters The URL pattern parameters that were parsed from the request’s URL
 @result Whether the request matches or not
 */
typedef BOOL(^UMKParameterizedRequestMatchingBlock)(NSURLRequest *request, NSDictionary *parameters);

/*!
 @abstract Block type for generating a responder based on a request and the specified URL path parameters.
 @discussion This block type is used by pattern-matching mock requests to generate a mock responder for the specified
     request and parameters. Users can analyze the request and parameters to build and return an appropriate mock 
     responder.
 @param request The request for which a mock responder is being generated.
 @param parameters The URL pattern parameters that were parsed from the request’s URL
 @result A mock responder that responds to the specified request. May not be nil.
 */
typedef id<UMKMockURLResponder>(^UMKParameterizedResponderGenerationBlock)(NSURLRequest *request, NSDictionary *parameters);


/*!
 UMKPatternMatchingMockRequest are mock requests that match URL requests based on a URL pattern. Each pattern-matching
 mock request has an associated URL pattern and a responder generation block. The URL pattern is a SOCKit pattern, e.g.,
 http://hostname.com/:directory/:subdirectory/:resource. When a URL request matches the receiver’s URL pattern, the
 receiver calls its responder generation block with the request and the URL pattern parameters parsed from the request’s
 URL. You can use this block to generate an appropriate responder based on the contents of the URL request.

 In addition to the URL pattern, you can optionally provide a set of HTTP methods and a request-matching block to
 perform further tests on a request before matching it. See the documentation below for more details.
 
 Note that due to the fact that a single pattern-matching mock request can match many actual requests, pattern-matching
 mock requests are not removed from UMKMockURLProtocol’s set of expected mock requests after they service a request. To
 remove a pattern-matching mock request, you can either remove the request manually using +[UMKMockURLProtocol
 removeExpectedMockRequest:] or reset UMKMockURLProtocol entirely using +[UMKMockURLProtocol reset].
 */
@interface UMKPatternMatchingMockRequest : NSObject <UMKMockURLRequest>

/*! 
 @abstract The instance's URL pattern.
 @discussion This pattern should be a valid SOCKit pattern. See the SOCKit documentation for more information.

     Note that only the part of the URL up to the query string is used to match the pattern. This simplifies issues
     related to query parameter ordering. If you need to examine the query parameters to determine whether to match a
     request, you can do so using a request-matching block.
 */
@property (nonatomic, copy, readonly) NSString *URLPattern;

/*!
 @abstract The HTTP methods that the instance matches.
 @discussion If nil, the instance does not check a request’s HTTP method when matching.
 */
@property (nonatomic, copy) NSSet *HTTPMethods;

/*! 
 @abstract The instance’s responder generation block.
 @discussion This block generates a mock responder for a given URL request and URL pattern parameters. It may not 
     return nil. The return value of this block is what is returned by -responderForURLRequest:.
 */
@property (nonatomic, copy) UMKParameterizedResponderGenerationBlock responderGenerationBlock;

/*!
 @abstract The instance’s request-matching block.
 @discussion By default, the instance will only determine whether a request matches using its URL pattern and HTTP
     methods. If you provide a request-matching block, it will be called afterwards so that you can perform
     additional tests on the URL request being matched. The return value of the block will determine if the instance
     matches the request or not.
 
     If a request has a non-nil HTTPBodyStream, your request matching block should not attempt to read it under any
     circumstances, even by using -umk_HTTPBodyData. Doing so will make the body unreadable on subsequent attempts,
     most notably by other potential mock requests or in the body of your responder generation block. This is due to
     the nature of data streams. If the request has a non-nil HTTPBody, you may freely read the body in your block.
 */
@property (nonatomic, copy) UMKParameterizedRequestMatchingBlock requestMatchingBlock;

/*!
 @abstract Initializes a newly allocated instance with the specified URL pattern and responder generation block.
 @discussion This is the class’s designated initializer.

 @param URLPattern The URL pattern for the new instance. May not be nil.
 @result An initialized pattern-matching mock request instance.
 */
- (instancetype)initWithURLPattern:(NSString *)URLPattern;

@end
