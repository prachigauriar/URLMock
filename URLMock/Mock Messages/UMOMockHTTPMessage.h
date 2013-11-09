//
//  UMOMockHTTPMessage.h
//  URLMock
//
//  Created by Prachi Gauriar on 11/9/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
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

#pragma mark Constants

extern NSString *const kUMOMockHTTPMessageAcceptsHeaderField;
extern NSString *const kUMOMockHTTPMessageContentTypeHeaderField;
extern NSString *const kUMOMockHTTPMessageCookieHeaderField;
extern NSString *const kUMOMockHTTPMessageSetCookieHeaderField;

extern NSString *const kUMOMockHTTPMessageUTF8JSONContentTypeHeaderValue;
extern NSString *const kUMOMockHTTPMessageUTF8WWWFormURLEncodedContentTypeHeaderValue;


#pragma mark -

@interface UMOMockHTTPMessage : NSObject {
@protected
    NSMutableDictionary *_headers;
}

@property (readwrite, copy, nonatomic) NSData *body;
@property (readwrite, copy, nonatomic) NSDictionary *headers;

- (void)setValue:(NSString *)value forHeaderField:(NSString *)field;
- (void)removeValueForHeaderField:(NSString *)field;

- (void)setJSONBody:(id)JSONObject;
- (void)setStringBody:(NSString *)string;
- (void)setStringBody:(NSString *)string encoding:(NSStringEncoding)encoding;

@end
