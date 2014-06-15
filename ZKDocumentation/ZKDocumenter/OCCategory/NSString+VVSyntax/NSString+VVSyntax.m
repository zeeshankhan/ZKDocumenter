//
//  NSString+VVSyntax.m
//  CommentTest
//
//  Created by 王 巍 on 13-7-18.
//  Copyright (c) 2013年 OneV's Den. All rights reserved.
//
/*
 Copyright (c) 2013 Wei Wang (@onevcat)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
 Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */



#import "NSString+VVSyntax.h"

@implementation NSString (VVSyntax)

-(NSString *) vv_stringByConvertingToUniform
{
    return [[self vv_stringByReplacingRegexPattern:@"\\s*(\\(.*\?\\))\\s*" withString:@"$1"]
                  vv_stringByReplacingRegexPattern:@"\\s*\n\\s*"           withString:@" "];
}

-(NSString *) vv_stringByTrimEndSpaces
{
    return [self vv_stringByReplacingRegexPattern:@"\\s*\n" withString:@"\n"];
}

-(BOOL) vv_isObjCMethod
{
    return [self vv_matchesPatternRegexPattern:@"^\\s*[+-]"];
}

-(BOOL) vv_isCFunction
{
    return ![self vv_isEnum] && ![self vv_isMacro] && ![self vv_isObjCMethod] && ![self vv_isProperty] && ![self vv_isComplieKeyword] && [self vv_matchesPatternRegexPattern:@".+\\s+.+\\("];
}

-(BOOL) vv_isProperty
{
	return [self vv_matchesPatternRegexPattern:@"^\\s*\\@property"];
}

-(BOOL) vv_isMacro
{
    return [self vv_matchesPatternRegexPattern:@"^\\s*\\#define"];
}

-(BOOL) vv_isStruct
{
    return [self vv_matchesPatternRegexPattern:@"^\\s*(\\w+\\s)?struct.*\\{"];
}

-(BOOL) vv_isEnum
{
    return [self vv_matchesPatternRegexPattern:@"^\\s*(\\w+\\s+)?NS_(ENUM|OPTIONS)\\b"];
}

-(BOOL) vv_isUnion
{
    return [self vv_matchesPatternRegexPattern:@"^\\s*(\\w+\\s)?union.*\\{"];
}

-(BOOL) vv_isComplieKeyword
{
    return ![self vv_isProperty] && [self vv_matchesPatternRegexPattern:@"^\\s*\\@"];
}

@end
