//
//  VVDocumenterSetting.m
//  VVDocumenter-Xcode
//
//  Created by 王 巍 on 13-8-3.
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


#import "VVDocumenterSetting.h"
#import <Carbon/Carbon.h>

NSString *const VVDDefaultTriggerString = @"///";

NSString *const kVVDUseSpaces = @"com.onevcat.VVDocumenter.useSpaces";
NSString *const kVVDSpaceCount = @"com.onevcat.VVDocumenter.spaceCount";
NSString *const kVVDTriggerString = @"com.onevcat.VVDocumenter.triggerString";
NSString *const kVVDPrefixWithStar = @"com.onevcat.VVDocumenter.prefixWithStar";
NSString *const kVVDPrefixWithSlashes = @"com.onevcat.VVDocumenter.prefixWithSlashes";
NSString *const kVVDAddSinceToComments = @"com.onevcat.VVDocumenter.addSinceToComments";
NSString *const kVVDAddAuthorToComments = @"com.onevcat.VVDocumenter.addAuthorToComments";
NSString *const kVVDUserHeaderDoc = @"com.onevcat.VVDocumenter.useHeaderDoc";
NSString *const kVVDNoBlankLinesBetweenFields = @"com.onevcat.VVDocumenter.noBlankLinesBetweenFields";
NSString *const kVVDNoArgumentPadding = @"com.onevcat.VVDocumenter.noArgumentPadding";

@implementation VVDocumenterSetting

+ (VVDocumenterSetting *)defaultSetting
{
    static dispatch_once_t once;
    static VVDocumenterSetting *defaultSetting;
    dispatch_once(&once, ^ {
        defaultSetting = [[VVDocumenterSetting alloc] init];
        
        NSDictionary *defaults = @{kVVDPrefixWithStar: @YES,
                                   kVVDUseSpaces: @YES};
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    });
    return defaultSetting;
}

-(BOOL) useSpaces
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kVVDUseSpaces];
}

-(void) setUseSpaces:(BOOL)useSpace
{
    [[NSUserDefaults standardUserDefaults] setBool:useSpace forKey:kVVDUseSpaces];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL) useDvorakLayout
{
    TISInputSourceRef inputSource = TISCopyCurrentKeyboardLayoutInputSource();
    NSString *layoutID = (__bridge NSString *)TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID);
    CFRelease(inputSource);
    
    if ([layoutID rangeOfString:@"Dvorak" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    } else {
        return NO;
    }
}

-(NSInteger) spaceCount
{
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:kVVDSpaceCount];
    return (count <= 0) ? 2 : count;
}

-(void) setSpaceCount:(NSInteger)spaceCount
{
    if (spaceCount < 1) {
        spaceCount = 1;
    } else if (spaceCount > 10) {
        spaceCount = 10;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:spaceCount forKey:kVVDSpaceCount];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//-(NSString *) triggerString
//{
//    NSString *s = [[NSUserDefaults standardUserDefaults] stringForKey:kVVDTriggerString];
//    if (s.length == 0) {
//        s = VVDDefaultTriggerString;
//    }
//    return s;
//}
//
//-(void) setTriggerString:(NSString *)triggerString
//{
//    if (triggerString.length == 0) {
//        [[NSUserDefaults standardUserDefaults] setObject:VVDDefaultTriggerString forKey:kVVDTriggerString];
//    } else {
//        [[NSUserDefaults standardUserDefaults] setObject:triggerString forKey:kVVDTriggerString];
//    }
//
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}

-(BOOL) prefixWithStar
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kVVDPrefixWithStar];
}

-(void) setPrefixWithStar:(BOOL)prefix
{
    [[NSUserDefaults standardUserDefaults] setBool:prefix forKey:kVVDPrefixWithStar];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL) prefixWithSlashes
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kVVDPrefixWithSlashes];
}

-(void) setPrefixWithSlashes:(BOOL)prefix
{
    [[NSUserDefaults standardUserDefaults] setBool:prefix forKey:kVVDPrefixWithSlashes];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL) addSinceToComments
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kVVDAddSinceToComments];
}

-(void) setAddSinceToComments:(BOOL)add
{
    [[NSUserDefaults standardUserDefaults] setBool:add forKey:kVVDAddSinceToComments];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL) addAuthorToComments
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kVVDAddAuthorToComments];
}

-(void) setAddAuthorToComments:(BOOL)add
{
    [[NSUserDefaults standardUserDefaults] setBool:add forKey:kVVDAddAuthorToComments];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL) useHeaderDoc
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kVVDUserHeaderDoc];
}
-(void) setUseHeaderDoc:(BOOL)use
{
    [[NSUserDefaults standardUserDefaults] setBool:use forKey:kVVDUserHeaderDoc];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL) blankLinesBetweenSections
{
    return ![[NSUserDefaults standardUserDefaults] boolForKey:kVVDNoBlankLinesBetweenFields];
}
-(void) setBlankLinesBetweenSections:(BOOL)blankLinesBetweenFields
{
    [[NSUserDefaults standardUserDefaults] setBool:!blankLinesBetweenFields forKey:kVVDNoBlankLinesBetweenFields];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL) alignArgumentComments
{
    return ![[NSUserDefaults standardUserDefaults] boolForKey:kVVDNoArgumentPadding];
}
-(void) setAlignArgumentComments:(BOOL)alignArgumentComments
{
    [[NSUserDefaults standardUserDefaults] setBool:!alignArgumentComments forKey:kVVDNoArgumentPadding];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString *) spacesString
{
    if ([self useSpaces]) {
        return [@"" stringByPaddingToLength:[self spaceCount] withString:@" " startingAtIndex:0];
    } else {
        return @"\t";
    }
}

@end
