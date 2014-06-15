//
//  ZKCommenter.m
//  ZKDocumentation
//
//  Created by Zeeshan Khan on 17/04/14.
//  Copyright (c) 2014 Zeeshan Khan. All rights reserved.
//

#import "ZKCommenter.h"
#import "ZKAppDelegate.h"

#import "NSString+VVSyntax.h"
#import "NSString+PDRegex.h"

@implementation ZKCommenter

- (id) initWithIndentString:(NSString *)indent codeString:(NSString *)code {

    self = [super init];
    if (self) {
        
        self.isEnum = NO;
        
        if ([code vv_isEnum]) {
            self.code = code;
            self.isEnum = YES;
        }
        else {
            
            //Trim the space around the braces
            //Then trim the new line character
            NSString *newCode = [[code vv_stringByReplacingRegexPattern:@"\\s*(\\(.*\?\\))\\s*" withString:@"$1"]
                                 vv_stringByReplacingRegexPattern:@"\\s*\n\\s*"           withString:@" "];
            
            self.code = [newCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        
        self.indent = indent;
        self.arguments = [NSMutableArray array];
        self.space = [@"" stringByPaddingToLength:2 withString:@" " startingAtIndex:0];
    }
    return self;
}

- (NSString *) startComment {
    NSString *start = [NSString stringWithFormat:@"%@/**\n%@<#Description#>\n", self.indent, self.prefixString];
    return start;
}

- (NSString *) argumentsComment {

    if (self.arguments.count == 0)
        return @"";

    // start off with an empty line
    NSMutableString *result = [NSMutableString stringWithFormat:@"%@", self.emptyLine];

    int longestNameLength = [[self.arguments valueForKeyPath:@"@max.name.length"] intValue];

    for (ZKArgument *arg in self.arguments) {

        NSString *name = arg.name;

        // AlignArgumentComments
        name = [name stringByPaddingToLength:longestNameLength withString:@" " startingAtIndex:0];

        [result appendFormat:@"%@@param %@ <#%@ description#>\n", self.prefixString, name, arg.name];
    }
    return result;
}

- (NSString *) returnComment {
    NSString *returnCom = @"";
    if (self.hasReturn) {
        returnCom = [NSString stringWithFormat:@"%@%@@return <#return value description#>\n", self.emptyLine, self.prefixString];
    }
    return returnCom;
}

- (NSString *) sinceComment {
    NSString * since = @"";
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsSinceKey])
        since = [NSString stringWithFormat:@"%@%@@since <#version number#>\n", self.emptyLine, self.prefixString];
    return since;
}

- (NSString *) authorComment {
    NSString * author = @"";
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsAuthorKey])
        author = [NSString stringWithFormat:@"%@%@@author <#name#>\n", self.emptyLine, self.prefixString];
    return author;
}

- (NSString *) endComment {
    NSString *end = [NSString stringWithFormat:@"%@ */",self.indent];
    return end;
}

- (NSString *) document {
    
    NSString * comment = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                          [self startComment],
                          [self argumentsComment],
                          [self returnComment],
                          [self sinceComment],
                          [self authorComment],
                          [self endComment]];

    // The last line of the comment should be adjacent to the next line of code,
    // back off the newline from the last comment component.
//    return [comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return comment;
}

- (NSString *) emptyLine {
    // Add blank line between sections
    NSString *line = [[NSString stringWithFormat:@"%@\n", self.prefixString] vv_stringByTrimEndSpaces];
    return line;
}

- (NSString *) prefixString {
    NSString *prefix = [NSString stringWithFormat:@"%@ *%@", self.indent, self.space];
    return prefix;
}

- (void) parseArgumentsInputArgs:(NSString *)rawArgsCode {

    [self.arguments removeAllObjects];
    
    if (rawArgsCode.length == 0) {
        return;
    }

    NSArray *argumentStrings = [rawArgsCode componentsSeparatedByString:@","];
    for (__strong NSString *argumentString in argumentStrings) {

        ZKArgument *arg = [[ZKArgument alloc] init];
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

        NSLog(@"arg type: %@", arg.type);
        NSLog(@"arg name: %@", arg.name);

        [self.arguments addObject:arg];
        
        [arg release]; arg = nil;
        [tempArgs release]; tempArgs = nil;
    }
}

@end

@implementation ZKArgument

- (void)setType:(NSString *)type {
    if (type != _type) {
        _type = [[[type vv_stringByReplacingRegexPattern:@"&$" withString:@""]
                  vv_stringByReplacingRegexPattern:@"\\s*\\*$" withString:@""]
                 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
}

- (void)setName:(NSString *)name {
    if (name != _name) {
        _name = [[[[[[[name vv_stringByReplacingRegexPattern:@"\\(|\\)" withString:@""]
                      vv_stringByReplacingRegexPattern:@"^&" withString:@""]
                     vv_stringByReplacingRegexPattern:@"^\\*+" withString:@""]
                    vv_stringByReplacingRegexPattern:@"\\[.*$" withString:@""]
                   vv_stringByReplacingRegexPattern:@",$" withString:@""]
                  vv_stringByReplacingRegexPattern:@";$" withString:@""]
                 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
}

@end

@implementation ZKMethodCommenter

- (id) initWithCode:(NSString *)code {
    
    self = [super initWithIndentString:[self baseIndentation] codeString:code];
    if (self) {}
    return self;
}

- (NSString *) baseIndentation {
    NSArray *matchedSpaces = [self.code vv_stringsByExtractingGroupsUsingRegexPattern:@"^(\\s*)"];
    if (matchedSpaces.count > 0) {
        return matchedSpaces[0];
    } else {
        return @"";
    }
}

- (void) captureReturnType {

    NSArray * matchedTypes = [self.code vv_stringsByExtractingGroupsUsingRegexPattern:@"^\\s*[+-]\\s*\\(([^\\(\\)]*)\\)"];
    
    if (matchedTypes.count == 1) {
        if (![matchedTypes[0] vv_matchesPatternRegexPattern:@"^\\s*void\\s*[^*]*\\s*$"] &&
            ![matchedTypes[0] vv_matchesPatternRegexPattern:@"^\\s*IBAction\\s*$"]) {
            self.hasReturn = YES;
        }
    }
}

- (void) captureParameters {

    NSArray * matchedParams = [self.code vv_stringsByExtractingGroupsUsingRegexPattern:@"\\:\\(([^:]+)\\)(\\w+)"];
    //NSLog(@"matchedParams: %@",matchedParams);
    for (int i = 0; i < (int)matchedParams.count - 1; i = i + 2) {
        ZKArgument *arg = [[ZKArgument alloc] init];
        arg.type = [matchedParams[i] vv_stringByReplacingRegexPattern:@"[\\s*;.*]" withString:@""];
        arg.name = [matchedParams[i + 1] vv_stringByReplacingRegexPattern:@"[\\s*;.*]" withString:@""];
        [self.arguments addObject:arg];
        [arg release]; arg = nil;
    }
}

- (NSString *) document {

    [self captureReturnType];
    [self captureParameters];
    
    return [super document];
}

@end