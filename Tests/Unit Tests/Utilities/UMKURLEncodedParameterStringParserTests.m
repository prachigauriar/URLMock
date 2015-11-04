//
//  UMKURLEncodedParameterStringParserTests.m
//  URLMock
//
//  Created by Prachi Gauriar on 1/5/2014.
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

#import "UMKRandomizedTestCase.h"

#import <URLMock/UMKURLEncodedParameterStringParser.h>


@interface UMKURLEncodedParameterStringParserTests : UMKRandomizedTestCase

- (void)testInit;
- (void)testParse;

@end


@implementation UMKURLEncodedParameterStringParserTests

- (void)testInit
{
    NSString *string = UMKRandomUnicodeString();

    UMKURLEncodedParameterStringParser *parser = [[UMKURLEncodedParameterStringParser alloc] initWithString:string];
    
    XCTAssertNotNil(parser, @"Returns nil");
    XCTAssertEqualObjects(parser.string, string, @"String is not set correctly");
}


- (void)testParse
{
    for (NSUInteger i = 0; i < UMKIterationCount; ++i) {
        NSUInteger maxNestingDepth = random() % 3 + 1;
        NSUInteger maxElementCountPerCollection = random() % 3 + 1;
        
        NSDictionary *dictionary = UMKRandomURLEncodedParameterDictionary(maxNestingDepth, maxElementCountPerCollection);
        NSString *string = [dictionary umk_URLEncodedParameterString];
        
        UMKURLEncodedParameterStringParser *parser = [[UMKURLEncodedParameterStringParser alloc] initWithString:string];
        NSDictionary *parsedDictionary = [parser parse];
        XCTAssertEqualObjects(dictionary, parsedDictionary, @"Incorrect parse result");
    }
}


- (void)testParseWithDoubleAmpersand
{
    NSURL *doubleAmpersandURL = [NSURL URLWithString:@"https://hostname.com/a/b/c?d=e&c&f=g"];
    NSDictionary *parsedDictionary = [NSDictionary umk_dictionaryWithURLEncodedParameterString:doubleAmpersandURL.query];
    XCTAssertNotNil(parsedDictionary, @"parsed dictionary is nil");
}


- (void)testParse1
{
    NSDictionary *dictionary = @{ @"x" : @{ @"y" : @{ @"z" : @"10" } } };
    NSString *generatedString = [dictionary umk_URLEncodedParameterString];
    NSString *string = @"x[y][z]=10";
    
    UMKURLEncodedParameterStringParser *parser = [[UMKURLEncodedParameterStringParser alloc] initWithString:generatedString];
    NSDictionary *parsedDictionary = [parser parse];
    XCTAssertEqualObjects(dictionary, parsedDictionary, @"Incorrect parse result");
    XCTAssertEqualObjects(string, generatedString, @"Incorrect parameter string");
}


- (void)testParse2
{
    NSDictionary *dictionary = @{ @"x" : @{ @"y" : @{ @"z" : @[ @"10" ] } } };
    NSString *generatedString = [dictionary umk_URLEncodedParameterString];
    NSString *string = @"x[y][z][]=10";
    
    UMKURLEncodedParameterStringParser *parser = [[UMKURLEncodedParameterStringParser alloc] initWithString:generatedString];
    NSDictionary *parsedDictionary = [parser parse];
    XCTAssertEqualObjects(dictionary, parsedDictionary, @"Incorrect parse result");
    XCTAssertEqualObjects(string, generatedString, @"Incorrect parameter string");
}


- (void)testParse3
{
    NSDictionary *dictionary = @{ @"x" : @{ @"y" : @{ @"z" : @[ @"10", @"5" ] } } };
    NSString *generatedString = [dictionary umk_URLEncodedParameterString];
    NSString *string = @"x[y][z][]=10&x[y][z][]=5";
    
    UMKURLEncodedParameterStringParser *parser = [[UMKURLEncodedParameterStringParser alloc] initWithString:generatedString];
    NSDictionary *parsedDictionary = [parser parse];
    XCTAssertEqualObjects(dictionary, parsedDictionary, @"Incorrect parse result");
    XCTAssertEqualObjects(string, generatedString, @"Incorrect parameter string");
}


- (void)testParse4
{
    NSDictionary *dictionary = @{ @"x" : @{ @"y" : @[ @{ @"z" : @"10" } ] } };
    NSString *generatedString = [dictionary umk_URLEncodedParameterString];
    NSString *string = @"x[y][][z]=10";
    
    UMKURLEncodedParameterStringParser *parser = [[UMKURLEncodedParameterStringParser alloc] initWithString:generatedString];
    NSDictionary *parsedDictionary = [parser parse];
    XCTAssertEqualObjects(dictionary, parsedDictionary, @"Incorrect parse result");
    XCTAssertEqualObjects(string, generatedString, @"Incorrect parameter string");
}


- (void)testParse5
{
    NSDictionary *dictionary = @{ @"x" : @{ @"y" : @[ @{ @"z" : @"10", @"w" : @"10" } ] } };
    NSString *generatedString = [dictionary umk_URLEncodedParameterString];
    NSString *string = @"x[y][][w]=10&x[y][][z]=10";
    
    UMKURLEncodedParameterStringParser *parser = [[UMKURLEncodedParameterStringParser alloc] initWithString:generatedString];
    NSDictionary *parsedDictionary = [parser parse];
    XCTAssertEqualObjects(dictionary, parsedDictionary, @"Incorrect parse result");
    XCTAssertEqualObjects(string, generatedString, @"Incorrect parameter string");
}


- (void)testParse6
{
    NSDictionary *dictionary = @{ @"x" : @{ @"y" : @[ @{ @"v" : @{ @"w" : @"10" } } ] } };
    NSString *generatedString = [dictionary umk_URLEncodedParameterString];
    NSString *string = @"x[y][][v][w]=10";
    
    UMKURLEncodedParameterStringParser *parser = [[UMKURLEncodedParameterStringParser alloc] initWithString:generatedString];
    NSDictionary *parsedDictionary = [parser parse];
    XCTAssertEqualObjects(dictionary, parsedDictionary, @"Incorrect parse result");
    XCTAssertEqualObjects(string, generatedString, @"Incorrect parameter string");
}


- (void)testParse7
{
    NSDictionary *dictionary = @{ @"x" : @{ @"y" : @[ @{ @"z" : @"10", @"v" : @{ @"w" : @"10" } } ] } };
    NSString *generatedString = [dictionary umk_URLEncodedParameterString];
    NSString *string = @"x[y][][v][w]=10&x[y][][z]=10";
    
    UMKURLEncodedParameterStringParser *parser = [[UMKURLEncodedParameterStringParser alloc] initWithString:generatedString];
    NSDictionary *parsedDictionary = [parser parse];
    XCTAssertEqualObjects(dictionary, parsedDictionary, @"Incorrect parse result");
    XCTAssertEqualObjects(string, generatedString, @"Incorrect parameter string");
}


- (void)testParse8
{
    NSDictionary *dictionary = @{ @"x": @{ @"y" : @[ @{ @"z" : @"10" }, @{ @"z" : @"20" } ] } };
    NSString *generatedString = [dictionary umk_URLEncodedParameterString];
    NSString *string = @"x[y][][z]=10&x[y][][z]=20";

    UMKURLEncodedParameterStringParser *parser = [[UMKURLEncodedParameterStringParser alloc] initWithString:generatedString];
    NSDictionary *parsedDictionary = [parser parse];
    XCTAssertEqualObjects(dictionary, parsedDictionary, @"Incorrect parse result");
    XCTAssertEqualObjects(string, generatedString, @"Incorrect parameter string");
}


- (void)testParse9
{
    NSDictionary *dictionary = @{ @"x" : @{ @"y" : @[ @{ @"z" : @"10", @"w" : @"a" }, @{ @"z" : @"20", @"w" : @"b" } ] } };
    NSString *generatedString = [dictionary umk_URLEncodedParameterString];
    NSString *string = @"x[y][][w]=a&x[y][][z]=10&x[y][][w]=b&x[y][][z]=20";
    
    UMKURLEncodedParameterStringParser *parser = [[UMKURLEncodedParameterStringParser alloc] initWithString:generatedString];
    NSDictionary *parsedDictionary = [parser parse];
    XCTAssertEqualObjects(dictionary, parsedDictionary, @"Incorrect parse result");
    XCTAssertEqualObjects(string, generatedString, @"Incorrect parameter string");
}


- (void)testParse10
{
    NSDictionary *dictionary = @{ @"foo" : @"bar", @"baz" : @"" };
    NSString *generatedString = [dictionary umk_URLEncodedParameterString];
    NSString *string = @"baz=&foo=bar";

    UMKURLEncodedParameterStringParser *parser = [[UMKURLEncodedParameterStringParser alloc] initWithString:generatedString];
    NSDictionary *parsedDictionary = [parser parse];
    XCTAssertEqualObjects(dictionary, parsedDictionary, @"Incorrect parse result");
    XCTAssertEqualObjects(string, generatedString, @"Incorrect parameter string");
}


- (void)testParse11
{
    NSDictionary *dictionary = @{ @"foo" : @"bar", @"baz" : @[ @"1", @"2", @"3" ] };
    NSString *generatedString = [dictionary umk_URLEncodedParameterString];
    NSString *string = @"baz[]=1&baz[]=2&baz[]=3&foo=bar";

    UMKURLEncodedParameterStringParser *parser = [[UMKURLEncodedParameterStringParser alloc] initWithString:generatedString];
    NSDictionary *parsedDictionary = [parser parse];
    XCTAssertEqualObjects(dictionary, parsedDictionary, @"Incorrect parse result");
    XCTAssertEqualObjects(string, generatedString, @"Incorrect parameter string");
}


- (void)testParse12
{
    NSDictionary *dictionary = @{ @"foo" : @[ @"bar" ], @"baz" : @[ @"1", @"2", @"3" ] };
    NSString *generatedString = [dictionary umk_URLEncodedParameterString];
    NSString *string = @"baz[]=1&baz[]=2&baz[]=3&foo[]=bar";

    UMKURLEncodedParameterStringParser *parser = [[UMKURLEncodedParameterStringParser alloc] initWithString:generatedString];
    NSDictionary *parsedDictionary = [parser parse];
    XCTAssertEqualObjects(dictionary, parsedDictionary, @"Incorrect parse result");
    XCTAssertEqualObjects(string, generatedString, @"Incorrect parameter string");
}


- (void)testParse13
{
    NSString *string = @"x=a&x=b";
    NSDictionary *dictionary = @{ @"x" : @"b" };

    UMKURLEncodedParameterStringParser *parser = [[UMKURLEncodedParameterStringParser alloc] initWithString:string];
    NSDictionary *parsedDictionary = [parser parse];
    XCTAssertEqualObjects(dictionary, parsedDictionary, @"Incorrect parse result");
}


- (void)testParse14
{
    NSString *string = @"x[y]=a&x[y]=b";
    NSDictionary *dictionary = @{ @"x" : @{ @"y" : @"b" } };

    UMKURLEncodedParameterStringParser *parser = [[UMKURLEncodedParameterStringParser alloc] initWithString:string];
    NSDictionary *parsedDictionary = [parser parse];
    XCTAssertEqualObjects(dictionary, parsedDictionary, @"Incorrect parse result");
}


- (void)testParse15
{
    NSString *string = @"a[b[][c]]=d";
    NSDictionary *dictionary = @{ @"a" : @{ @"b" : @[ @{ @"c" : @"d" } ] } };

    UMKURLEncodedParameterStringParser *parser = [[UMKURLEncodedParameterStringParser alloc] initWithString:string];
    NSDictionary *parsedDictionary = [parser parse];
    XCTAssertEqualObjects(dictionary, parsedDictionary, @"Incorrect parse result");
}


- (void)testParse16
{
    NSString *string = @"x[]=a&x[]=b";
    NSDictionary *dictionary = @{ @"x" : @[ @"a", @"b" ] };

    UMKURLEncodedParameterStringParser *parser = [[UMKURLEncodedParameterStringParser alloc] initWithString:string];
    NSDictionary *parsedDictionary = [parser parse];
    XCTAssertEqualObjects(dictionary, parsedDictionary, @"Incorrect parse result");
}


- (void)testParse17
{
    NSString *string = @"a][b=c";
    NSDictionary *dictionary = @{ @"a" : @{ @"b" : @"c" } };

    UMKURLEncodedParameterStringParser *parser = [[UMKURLEncodedParameterStringParser alloc] initWithString:string];
    NSDictionary *parsedDictionary = [parser parse];
    XCTAssertEqualObjects(dictionary, parsedDictionary, @"Incorrect parse result");
}


- (void)testParse18
{
    NSString *string = @"a]=b";
    NSDictionary *dictionary = @{ @"a" : @"b" };

    UMKURLEncodedParameterStringParser *parser = [[UMKURLEncodedParameterStringParser alloc] initWithString:string];
    NSDictionary *parsedDictionary = [parser parse];
    XCTAssertEqualObjects(dictionary, parsedDictionary, @"Incorrect parse result");
}


- (void)testParse19
{
    NSString *string = @"a[=b";
    NSDictionary *dictionary = @{ @"a" : @{} };

    UMKURLEncodedParameterStringParser *parser = [[UMKURLEncodedParameterStringParser alloc] initWithString:string];
    NSDictionary *parsedDictionary = [parser parse];
    XCTAssertEqualObjects(dictionary, parsedDictionary, @"Incorrect parse result");
}


- (void)testParse20
{
    NSString *string = @"a]c[=b";
    NSDictionary *dictionary = @{ @"a" : @{ @"c" : @{} } };

    UMKURLEncodedParameterStringParser *parser = [[UMKURLEncodedParameterStringParser alloc] initWithString:string];
    NSDictionary *parsedDictionary = [parser parse];
    XCTAssertEqualObjects(dictionary, parsedDictionary, @"Incorrect parse result");
}


- (void)testParse21
{
    NSString *string = @"a_./[*)@(ಠ_ಠ=b";
    NSDictionary *dictionary = @{ @"a_./" : @{ @"*)@(ಠ_ಠ" : @"b" } };

    UMKURLEncodedParameterStringParser *parser = [[UMKURLEncodedParameterStringParser alloc] initWithString:string];
    NSDictionary *parsedDictionary = [parser parse];
    XCTAssertEqualObjects(dictionary, parsedDictionary, @"Incorrect parse result");
}

@end
