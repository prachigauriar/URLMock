//
//  UMKMockURLProtocol.h
//  URLMock
//
//  Created by Prachi Gauriar on 11/9/2013.
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


/*! The error domain for the URLMock framework. */
extern NSString *const kUMKErrorDomain;

/*! The key used in NSError userInfo dictionaries whose value is an array of unexpected requests. */
extern NSString *const kUMKUnexpectedRequestsKey;

/*! The key used in NSError userInfo dictionaries whose value is an array of unserviced mock requests. */
extern NSString *const kUMKUnservicedMockRequestsKey;

/*! The error codes used by the URLMock framework. */
typedef NS_ENUM(NSInteger, UMKErrorCode) {
    /*! Indicates an error due to an unexpected request. */
    kUMKUnexpectedRequestErrorCode = 1001,

    /*! Indicates an error due to an unserviced mock request. */
    kUMKUnservicedMockRequestErrorCode = 1002,
};


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
 @abstract Removes all expected mock requests and information about unexpected and serviced requests.
 @discussion Due to the asynchronous nature of URL loading, care should be taken to ensure that there are no
     connections in progress when this method is invoked. Failure to do so could result in unexpected results,
     particularly if verification is enabled.
 */
+ (void)reset;


/*! @methodgroup Getting and setting expectations */

/*!
 @abstract Returns all expected mock requests.
 @result An array of all mock requests that are currently expected.
 */
+ (NSArray *)expectedMockRequests;

/*!
 @abstract Adds the specified mock request to the protocol's set of expected mock requests.
 @discussion This is how mock requests are registered with the mock protocol.
 @param request The mock request to expect. May not be nil.
 */
+ (void)expectMockRequest:(id<UMKMockURLRequest>)request;

/*!
 @abstract Removes the specified mock request from the protocol's set of expected mock requests.
 @discussion This is how mock requests are unregistered from the mock protocol.
 @param request The mock request to expect.
 */
+ (void)removeExpectedMockRequest:(id<UMKMockURLRequest>)request;


/*! @methodgroup Verification */

/*!
 @abstract Returns whether verification is enabled.
 @discussion Set to NO by default. See +setVerificationEnabled: for more information on what enabling 
     verification means.
 @result Whether verification is enabled.
 */
+ (BOOL)isVerificationEnabled;

/*!
 @abstract Enables or disables verification.
 @param enabled Whether to enable verification or not.
 @discussion By default, verification is disabled. When enabled, the behavior of UMKMockURLProtocol changes 
     to facilitate verifying expected behavior. In particular, mock requests are automatically removed from
     the set of expected requests when they are serviced, and unexpected requests receive error responses
     detailing that they were unexpected. Unexpected requests are accessible using +unexpectedRequests.

     When verification is enabled, +verifyWithError: may be used to determine if things are behaving as expected.
 */
+ (void)setVerificationEnabled:(BOOL)enabled;

/*!
 @abstract Verifies that mock requests are being serviced as expected.
 @discussion Returns YES if and only if all expected requests have been serviced and no unexpected requests 
     have been received since the last reset. Note: this method may only be used when verification is enabled.
     Invoking it otherwise will raise an exception.
 @param outError If an error occurs, upon return contains an NSError object that describes the problem.
     If verification fails because unexpected requests were received, those requests are accessible in the error
     object's userInfo dictionary via the kUMKUnexpectedRequestsKey key. If there were any unserviced mock 
     requests, they are accessible via the kUMKUnservicedMockRequestsKey key.
 @throws NSInternalInconsistencyException if verification is not enabled.
 @result Whether verification succeeded.
 */
+ (BOOL)verifyWithError:(NSError **)outError;

/*!
 @abstract Returns an array of unexpected requests received since the last reset.
 @result An array of unexpected requests received since the receiver last received the +reset message.
 */
+ (NSArray *)unexpectedRequests;

/*!
 @abstract Returns a dictionary of requests serviced since the last reset.
 @discussion The keys in this dictionary are the actual requests that were serviced; the values are the mock
     requests that serviced them.
 @result A dictionary of requests serviced since the receiver last received the +reset message.
 */
+ (NSDictionary *)servicedRequests;


/*! @methodgroup Getting canonical URLs */

/*!
 @abstract Returns the canonical version of the specified URL.
 @param URL The URL. May not be nil.
 @result The canonical version of the specified URL.
 */
+ (NSURL *)canonicalURLForURL:(NSURL *)URL;

@end


#pragma mark -

/*!
 The UMKMockURLRequest protocol declares messages that mock requests in the URLMock system must respond to.
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
 @result A mock URL responder for the specified request. May not be nil.
 */
- (id<UMKMockURLResponder>)responderForURLRequest:(NSURLRequest *)request;

@optional

/*!
 @abstract Returns whether the receiver should be removed from UMKMockURLProtocol’s set of
     expected mock requests after servicing the specified request.
 @discussion This message is only sent to mock requests when verification is enabled on 
     UMKMockURLProtocol. If a mock request does not respond to it, UMKMockURLProtocol will remove
     the request.
 @param request The request being serviced.
 @result Whether the receiver should remove the receiver from the set of expected mock requests
 */
- (BOOL)shouldRemoveAfterServicingRequest:(NSURLRequest *)request;

@end


#pragma mark -

/*!
 The UMKMockURLResponder protocol declares messages that responders to mock requests in the URLMock system
 must respond to.
 */
@protocol UMKMockURLResponder <NSObject>

/*!
 @abstract Responds to the specified mock request on behalf of the specified protocol object.
 @discussion The receiver should respond to this message by sending the client methods in the NSURLProtocolClient
     protocol. It should stop responding after it receives the -cancelResponse message.
 @param request The mock request. May not be nil.
 @param client The protocol client. May not be nil.
 @param protocol The URL protocol. May not be nil.
 */
- (void)respondToMockRequest:(id<UMKMockURLRequest>)request client:(id<NSURLProtocolClient>)client protocol:(NSURLProtocol *)protocol;

/*!
 @abstract Cancels any current mock request responses.
 @discussion Does nothing if the receiver is not currently responding to any mock requests.
 */
- (void)cancelResponse;

@end
