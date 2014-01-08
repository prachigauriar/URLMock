//
//  UMKURLEncodedParameterStringParserTests.m
//  URLMock
//
//  Created by Prachi Gauriar on 1/5/2014.
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

#import <XCTest/XCTest.h>
#import <URLMock/URLMock.h>
#import <URLMock/UMKURLEncodedParameterStringParser.h>

static const NSUInteger UMKIterationCount = 512;

@interface UMKURLEncodedParameterStringParserTests : UMKRandomizedTestCase

- (void)testInit;
- (void)testParse;

@end


@implementation UMKURLEncodedParameterStringParserTests

- (void)testInit
{
    NSString *string = UMKRandomUnicodeString();
    NSStringEncoding encoding = random() % 16 + 1;
    
    UMKURLEncodedParameterStringParser *parser = [[UMKURLEncodedParameterStringParser alloc] initWithString:string encoding:encoding];
    
    XCTAssertNotNil(parser, @"Returns nil");
    XCTAssertEqualObjects(parser.string, string, @"String is not set correctly");
    XCTAssertEqual(parser.encoding, encoding, @"Encoding is not set correctly");
}


- (void)testParse
{
    for (NSUInteger i = 0; i < UMKIterationCount; ++i) {
        NSUInteger maxNestingDepth = random() % 3 + 1;
        NSUInteger maxElementCountPerCollection = random() % 3 + 1;
        
        NSDictionary *dictionary = UMKRandomURLEncodedParameterDictionary(maxNestingDepth, maxElementCountPerCollection);
        NSString *string = [dictionary umk_URLEncodedParameterString];
        
        UMKURLEncodedParameterStringParser *parser = [[UMKURLEncodedParameterStringParser alloc] initWithString:string encoding:NSUTF8StringEncoding];
        NSDictionary *parsedDictionary = [parser parse];
        XCTAssertEqualObjects(dictionary, parsedDictionary, @"Incorrect parse result");
    }
}

@end
