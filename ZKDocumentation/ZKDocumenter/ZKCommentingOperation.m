//
//  ZKCommentingOperation.m
//  ZKDocumenter
//
//  Created by Zeeshan Khan on 20/04/14.
//  Copyright (c) 2014 Zeeshan Khan. All rights reserved.
//

#import "ZKCommentingOperation.h"
#import "VVDocumenter.h"

@interface ZKCommentingOperation ()
@property (nonatomic, copy) CompletionHandler completionBlock;
@property (nonatomic, strong) NSString * filePath;
@end

@implementation ZKCommentingOperation

// Constant strings
NSString const * kMethodRangeKey = @"kMethodRangeKey";
NSString const * kMethodNameKey = @"kMethodNameKey";

- (instancetype)initWithPath:(NSString*)path completionHandler:(CompletionHandler)block {

    self = [super init];
    if (self) {
        self.filePath = path;
        self.completionBlock = block;
    }
    return self;

}

- (void)main {
    
    if ([self isCancelled])
        return;
    
    @autoreleasepool {
        
        // Read file content
        NSString *fileCont = [self getFileContentFromPath:self.filePath];
        if (fileCont) {
            
            NSMutableString *content = [fileCont mutableCopy];
            
            NSArray *arrMethods = [self methodsInFileWithPath:self.filePath];
            //NSLog(@"Method Cont: %lu, For Path: %@", arrMethods.count, self.filePath);
            int x = 0;
            for (NSDictionary *dicMethod in arrMethods) {
                
                NSString *strMethod = [dicMethod objectForKey:kMethodNameKey];
                
                VVDocumenter *documenter = [[VVDocumenter alloc] initWithCode:strMethod];
                NSString *strComment = [documenter document];
                [documenter release]; documenter = nil;
//                ZKMethodCommenter * commenter = [[ZKMethodCommenter alloc] initWithCode:strMethod];
//                NSString *strComment = [commenter document];
//                [commenter release]; commenter = nil;
                
                // whitespaceAndNewlineCharacterSet
                //            strComment = [strComment stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                strComment = [NSString stringWithFormat:@"\n%@\n", strComment];
                
                if (x == 0) {
                    NSRange methodRange = [[dicMethod objectForKey:kMethodRangeKey] rangeValue];
                    [content insertString:strComment atIndex:methodRange.location];
                }
                else {
                    NSArray *matches = [self getRegExMatchesForContent:content];
                    if (matches == nil) {
                        NSLog(@"New Matches are nil");
                    }
                    
                    // Iterate through the matches and print them
                    for (NSTextCheckingResult *match in matches) {
                        NSString *found = [content substringFromIndex:match.range.location];
                        found = [found substringToIndex:[found rangeOfString:@"{"].location + 1];
                        if ([found rangeOfString:strMethod options:0].location != NSNotFound) {
                            [content insertString:strComment atIndex:match.range.location];
                            break;
                        }
                    }
                    
                }
                x++;
                //NSLog(@"Comment For Method:%@%@", strComment, strMethod);
            }
            
            //NSLog(@"Final Content of File With Path: %@ \n%@", path, content);
            NSError *err = nil;
            [content writeToFile:self.filePath atomically:YES encoding:NSUTF8StringEncoding error:&err];
            if (err) {
                NSLog(@"File Write Failed for Path: %@ \t %@", self.filePath, err);
            }
            [self giveCallbackWithError:err];
            
            [content release]; content = nil;
        }
        else {
            NSLog(@"File Content is nil.");
            NSError *err = [NSError errorWithDomain:@"File Content is nil." code:100 userInfo:nil];
            [self giveCallbackWithError:err];
        }
    }
}

- (void)giveCallbackWithError:(NSError*)err {
//    NSLog(@"%s",__PRETTY_FUNCTION__);

    if (self.completionBlock) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.completionBlock(self.filePath, err);
//        });
        self.completionBlock(self.filePath, err);
    }
}

- (NSArray*)methodsInFileWithPath:(NSString*)filePath {
    
    if (filePath == nil) return nil;
    
    // Read file content
    NSString *strContent = [self getFileContentFromPath:filePath];
    if (strContent == nil) return nil;
    
    // Find matches
    NSArray *matches = [self getRegExMatchesForContent:strContent];
    if (matches == nil) return nil;
    
    NSMutableArray *methods = [NSMutableArray new];
    
    // Iterate through the matches and print them
    for (NSTextCheckingResult *match in matches) {
        
        NSString *found = [strContent substringFromIndex:match.range.location];
        found = [found substringToIndex:[found rangeOfString:@"{"].location + 1];
        
        //        found = [found stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        //        found = [found stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        //        found = [found stringByReplacingOccurrencesOfString:@"\t" withString:@" "];
        //        found = [found stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
        
        //NSLog(@"Meth Loc: %lu %@", (unsigned long)match.range.location, found);
        NSDictionary *dicMethod = @{kMethodRangeKey: [NSValue valueWithRange:match.range], kMethodNameKey: found};
        [methods addObject:dicMethod];
    }
    
    return [methods autorelease];
}

- (NSString*)getFileContentFromPath:(NSString*)path {
    
    NSError *err = nil;
    NSString *content = nil;
    content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    if (err) {
        NSLog(@"File Read Failed for Path: %@ \t %@", path, err);
        content = nil;
    }
    return content;
}

- (NSArray*)getRegExMatchesForContent:(NSString*)content {
    
    //NSRegularExpressionDotMatchesLineSeparators | NSRegularExpressionAllowCommentsAndWhitespace | NSRegularExpressionCaseInsensitive
    NSRegularExpressionOptions regexOptions =  NSRegularExpressionCaseInsensitive;
    NSString *pattern = nil;
    
    /* This below pattern has some flaws:
     1. It does not match methods with new line character (when new line added through ENTER key, not \n). I have tried different NSRegularExpressionOptions but it didn't work.
     2. Quick fix added, need to varify again. FOR It matches ++) { written in a for loop, which should not, I have tried {1} or ? or + with [+-] but didn't work.
     3. I need to check other best RegEx solution for better performance.
     */
    
    // Just removed \\s* from front
    //    pattern = [NSString stringWithFormat:@"[+-]\\s*[(]+.*\\s*\\r*\\n*\\s*[{]"];
    
    // New
    pattern = @"[+-]\\s*[(]+[a-z0-9_\\s*$:()]*.*\\s*[{]"; // Check for ; ended as well but later
    
    //    NSPredicate *fromPatternTest1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    //    BOOL is = [fromPatternTest1 evaluateWithObject:content];
    
    NSError *err = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:&err];
    if (err) {
        NSLog(@"Couldn't create regex with given string and options");
        return nil;
    }
    
    NSRange visibleTextRange = NSMakeRange(0, content.length);
    NSInteger count = [regex numberOfMatchesInString:content options:0 range:visibleTextRange];
    //NSLog(@"Total Match Found: %ld", (long)count);
    
    if (count == 0) return nil;
    
    // 5: Find matches
    NSArray *matches = [regex matchesInString:content options:NSMatchingReportProgress range:visibleTextRange];
    return matches;
}


@end
