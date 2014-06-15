//
//  ZKCommentingOperation.h
//  ZKDocumenter
//
//  Created by Zeeshan Khan on 20/04/14.
//  Copyright (c) 2014 Zeeshan Khan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletionHandler) (NSString *path, NSError *error);

@interface ZKCommentingOperation : NSOperation

- (instancetype)initWithPath:(NSString*)path completionHandler:(CompletionHandler)block;

@end
