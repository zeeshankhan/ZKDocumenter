//
//  ZKCommenter.h
//  ZKDocumentation
//
//  Created by Zeeshan Khan on 17/04/14.
//  Copyright (c) 2014 Zeeshan Khan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZKCommenter : NSObject

@property (nonatomic, strong) NSString *indent;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, assign) BOOL isEnum;
@property (nonatomic, strong) NSMutableArray *arguments;
@property (nonatomic, assign) BOOL hasReturn;
@property (nonatomic, strong) NSString *space;

- (id) initWithIndentString:(NSString *)indent codeString:(NSString *)code;
- (NSString *) document;

- (void) parseArgumentsInputArgs:(NSString *)rawArgsCode;

// Comment methods
- (NSString *) startComment;
- (NSString *) argumentsComment;
- (NSString *) endComment;
- (NSString *) returnComment;

@end

@interface ZKArgument : NSObject
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *name;
@end

@interface ZKMethodCommenter : ZKCommenter
- (id) initWithCode:(NSString *)code;
- (NSString *) baseIndentation;
@end
