//
//  UMKMockURLProtocol.h
//  URLMock
//
//  Created by Prachi Gauriar on 11/9/2013.
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

#import <Foundation/Foundation.h>

@protocol UMKMockURLRequest, UMKMockURLResponder;

/*!
 UMKMockURLProtocol is the primary class in the URLMock framework. It has methods for enabling and disabling
 mock responses, adding and removing expected mock requests, and configuring the behavior of the framework.
 */
@interface UMKMockURLProtocol : NSURLProtocol

/*!
 @abstract Enables mock responses by registering the mock protocol with the NSURL system.
 */
+ (void)enable;

/*!
 @abstract Disables mock responses by unregistering the mock protocol with the NSURL system.
 */
+ (void)disable;

/*!
 @abstract Removes all expected mock requests and information about serviced requests.
 */
+ (void)reset;


/*!
 @abstract Returns whether the mock protocol intercepts all requests.
 @discussion This is NO by default. If YES, the protocol intercepts all requests that go through the NSURL 
     system and raises an exception whenever an unexpected request is received.
 @result Whether the mock protocol intercepts all requests.
 */
+ (BOOL)interceptsAllRequests;

/*!
 @abstract Sets whether the mock protocol intercepts all requests.
 @discussion This is NO by default. If YES, the protocol intercepts all requests that go through the NSURL
     system and raises an exception whenever an unexpected request is received.
 @param interceptsAllRequests Whether the protocol should intercept all requests.
 */
+ (void)setInterceptsAllRequests:(BOOL)interceptsAllRequests;


/*!
 @abstract Returns whether the mock protocol automatically removes serviced mock requests from the set of 
     expected mock requests.
 @discussion This is NO by default. If YES, the protocol will only service a given mock request once. 
     Servicing the same request again will require that it be added again using +expectMockRequest:.
 @result Whether the mock protocol automatically removes serviced mock requests.
 */
+ (BOOL)automaticallyRemovesServicedMockRequests;

/*!
 @abstract Sets whether the mock protocol automatically removes serviced mock requests from the set of
     expected mock requests.
 @discussion This is NO by default. If YES, the protocol will only service a given mock request once.
     Servicing the same request again will require that it be added again using +expectMockRequest:.
 @param removesServicedRequest Whether the protocol should remove serviced mock requests.
 */
+ (void)setAutomaticallyRemovesServicedMockRequests:(BOOL)removesServicedRequests;

/*!
 @abstract Returns all expected mock requests.
 @result An array of all mock requests that are currently expected.
 */
+ (NSArray *)allExpectedMockRequests;

/*!
 @abstract Adds the specified mock request to the protocol's set of expected mock requests.
 @discussion This is how mock requests are registered with the mock protocol.
 @param request The mock request to expect. May not be nil.
 */
+ (void)expectMockRequest:(id <UMKMockURLRequest>)request;

/*!
 @abstract Removes the specified mock request from the protocol's set of expected mock requests.
 @discussion This is how mock requests are unregistered from the mock protocol.
 @param request The mock request to expect.
 */
+ (void)removeExpectedMockRequest:(id <UMKMockURLRequest>)request;


/*!
 @abstract Returns all serviced mock requests since the last reset.
 @result A set of all mock requests that have been serviced since the receiver last received the +reset message.
 */
+ (NSSet *)allServicedMockRequests;

/*!
 @abstract Returns whether the specified mock request has been serviced.
 @param request The mock request.
 @result Whether a response to the specified mock request has been sent.
 */
+ (BOOL)hasServicedMockRequest:(id <UMKMockURLRequest>)request;


/*!
 @abstract Returns the canonical version of the specified URL.
 @param URL The URL. May not be nil.
 @result The canonical version of the specified URL.
 */
+ (NSURL *)canonicalURLForURL:(NSURL *)URL;

@end


#pragma mark

/*!
 The UMKMockURLRequest protocol declares messages that mock requests in the MockURL system must respond to.
 */
@protocol UMKMockURLRequest <NSObject>

/*!
 @abstract Returns whether the receiver matches the specified URL request.
 @param request The URL request. May not be nil.
 @result Whether the receiver matches the specified URL request.
 */
- (BOOL)matchesURLRequest:(NSURLRequest *)request;

/*!
 @abstract Returns a suitable mock URL responder for the specified URL request.
 @discussion This will only be invoked on the receiver with requests for which the receiver returns
     true for -matchesURLRequest:.
 @param request The URL request. May not be nil.
 @result A mock URL responder for the specified request.
 */
- (id <UMKMockURLResponder>)responderForURLRequest:(NSURLRequest *)request;

@end


#pragma mark

/*!
 The UMKMockURLResponder protocol declares messages that responders to mock requests in the MockURL system must respond to.
 */
@protocol UMKMockURLResponder <NSObject>

/*!
 @abstract Responds to the specified mock request on behalf of the specified protocol object.
 @discussion The receiver should respond to this message by sending the client methods in the NSURLProtocolClient protocol.
     It should stop responding after it receives the -cancelResponse message.
 @param request The mock request. May not be nil.
 @param client The protocol client. May not be nil.
 @param protocol The URL protocol. May not be nil.
 */
- (void)respondToMockRequest:(id <UMKMockURLRequest>)request client:(id <NSURLProtocolClient>)client protocol:(NSURLProtocol *)protocol;

/*!
 @abstract Cancels any current mock request responses.
 @discussion Does nothing if the receiver is not currently responding to any mock requests.
 */
- (void)cancelResponse;

@end
