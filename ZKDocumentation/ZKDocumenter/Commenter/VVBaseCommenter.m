//
//  VVBaseCommenter.m
//  VVDocumenter-Xcode
//
//  Created by 王 巍 on 13-7-17.
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



#import "VVBaseCommenter.h"
#import "VVArgument.h"
#import "VVDocumenterSetting.h"
#import "NSString+VVSyntax.h"
#import "NSString+PDRegex.h"

@interface VVBaseCommenter()
@property (nonatomic, copy) NSString *space;
@end

@implementation VVBaseCommenter
-(id) initWithIndentString:(NSString *)indent codeString:(NSString *)code
{
    self = [super init];
    if (self) {
        self.indent = indent;
        self.code = code;
        self.arguments = [NSMutableArray array];
        self.space = [[VVDocumenterSetting defaultSetting] spacesString];
    }
    return self;
}

-(NSString *) startComment
{
    if ([[VVDocumenterSetting defaultSetting] useHeaderDoc]) {
        return [NSString stringWithFormat:@"%@/*!\n%@<#Description#>\n", self.indent, self.prefixString];
    } else if ([[VVDocumenterSetting defaultSetting] prefixWithSlashes]) {
        return [NSString stringWithFormat:@"%@<#Description#>\n", self.prefixString];
    } else {
        return [NSString stringWithFormat:@"%@/**\n%@<#Description#>\n", self.indent, self.prefixString];
    }
}

-(NSString *) argumentsComment
{
    if (self.arguments.count == 0)
        return @"";

    // start off with an empty line
    NSMutableString *result = [NSMutableString stringWithFormat:@"%@", self.emptyLine];

    int longestNameLength = [[self.arguments valueForKeyPath:@"@max.name.length"] intValue];

    for (VVArgument *arg in self.arguments) {
        NSString *name = arg.name;

        if ([[VVDocumenterSetting defaultSetting] alignArgumentComments]) {
            name = [name stringByPaddingToLength:longestNameLength withString:@" " startingAtIndex:0];
        }

        [result appendFormat:@"%@@param %@ <#%@ description#>\n", self.prefixString, name, arg.name];
    }
    return result;
}

-(NSString *) returnComment
{
    if (!self.hasReturn) {
        return @"";
    } else {
        return [NSString stringWithFormat:@"%@%@@return <#return value description#>\n", self.emptyLine, self.prefixString];
    }
}

-(NSString *) sinceComment
{
    if ([[VVDocumenterSetting defaultSetting] addSinceToComments]) {
        return [NSString stringWithFormat:@"%@%@@since <#version number#>\n", self.emptyLine, self.prefixString];
    } else {
        return @"";
    }
}

-(NSString *) authorComment
{
    if ([[VVDocumenterSetting defaultSetting] addAuthorToComments]) {
        return [NSString stringWithFormat:@"%@%@@author <#author name#>\n", self.emptyLine, self.prefixString];
    } else {
        return @"";
    }
}

-(NSString *) endComment
{
    if ([[VVDocumenterSetting defaultSetting] prefixWithSlashes]) {
        return @"";
    } else {
        return [NSString stringWithFormat:@"%@ */",self.indent];
    }
}

-(NSString *) document
{
    NSString * comment = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                          [self startComment],
                          [self argumentsComment],
                          [self returnComment],
                          [self sinceComment],
                          [self authorComment],
                          [self endComment]];

    // The last line of the comment should be adjacent to the next line of code,
    // back off the newline from the last comment component.
    if ([[VVDocumenterSetting defaultSetting] prefixWithSlashes]) {
        return [comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    } else {
        return comment;
    }
}

-(NSString *) emptyLine
{
    if ([[VVDocumenterSetting defaultSetting] blankLinesBetweenSections]) {
        return [[NSString stringWithFormat:@"%@\n", self.prefixString] vv_stringByTrimEndSpaces];
    } else {
        return @"";
    }
}

-(NSString *) prefixString
{
    if ([[VVDocumenterSetting defaultSetting] prefixWithStar]) {
        return [NSString stringWithFormat:@"%@ *%@", self.indent, self.space];
    } else if ([[VVDocumenterSetting defaultSetting] prefixWithSlashes]) {
        return [NSString stringWithFormat:@"%@///%@", self.indent, self.space];
    } else {
        return [NSString stringWithFormat:@"%@ ", self.indent];
    }
}

-(void) parseArgumentsInputArgs:(NSString *)rawArgsCode
{
    [self.arguments removeAllObjects];
    if (rawArgsCode.length == 0) {
        return;
    }

    NSArray *argumentStrings = [rawArgsCode componentsSeparatedByString:@","];
    for (__strong NSString *argumentString in argumentStrings) {
        VVArgument *arg = [[VVArgument alloc] init];
        argumentString = [argumentString vv_stringByReplacingRegexPattern:@"=\\s*\\w*" withString:@""];
        argumentString = [argumentString vv_stringByReplacingRegexPattern:@"\\s+$" withString:@""];
        argumentString = [argumentString vv_stringByReplacingRegexPattern:@"\\s+" withString:@" "];
        NSMutableArray *tempArgs = [[argumentString componentsSeparatedByString:@" "] mutableCopy];
        while ([[tempArgs lastObject] isEqualToString:@" "]) {
            [tempArgs removeLastObject];
        }

        arg.name = [tempArgs lastObject];

        [tempArgs removeLastObject];
        arg.type = [tempArgs componentsJoinedByString:@" "];

//        NSLog(@"arg type: %@", arg.type);
//        NSLog(@"arg name: %@", arg.name);

        [self.arguments addObject:arg];
        [arg release]; arg = nil;
        [tempArgs release]; tempArgs = nil;
    }
}

@end
