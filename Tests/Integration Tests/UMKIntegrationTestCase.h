//
//  UMKlIntegrationTestCase.h
//  URLMock
//
//  Created by Prachi Gauriar on 2/1/2014.
//  Copyright (c) 2014 Prachi Gauriar.
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

#import "UMKRandomizedTestCase.h"

/*!
 UMKIntegrationTestCase is the base class for URLMock integration tests. It enables UMKMockURLProtocol on
 +setUp, resets it on -setUp, and disables it on +tearDown.
 
 Additionally, it provides a connection queue for connection operations and can start a connection for a 
 URL request on that queue and return a verifier for that connection.
 */
@interface UMKIntegrationTestCase : UMKRandomizedTestCase

/*!
 @abstract Returns the operation queue for connections started by this class.
 @discussion Connections started with -verifierForConnectionWithURLRequest: use this queue.
 @result An operation queue for URL connections.
 */
+ (NSOperationQueue *)connectionOperationQueue;

/*!
 @abstract Starts a connection for the specified URL request and returns a verifier for that connection.
 @discussion The connection is started using the operation queue returned by +connectionOperationQueue.
 @param request The URL request for the connection.
 @result A UMKURLConnectionVerifier for the URL connection.
 */
- (id)verifierForConnectionWithURLRequest:(NSURLRequest *)request;

@end
