//
//  ZKAppDelegate.h
//  ZKDocumentation
//
//  Created by Zeeshan Khan on 17/04/14.
//  Copyright (c) 2014 Zeeshan Khan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSUInteger, ZKDocumenterState) {
    ZKDocumenterStateIdle = 0,
    ZKDocumenterStateBrowsing,
    ZKDocumenterStateSearching,
    ZKDocumenterStateCommenting
};

#define kSettingsRemoveCheckKey @"kSettingsRemoveCheckKey"

@interface ZKAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate, NSDrawerDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet NSView *settingsView;
@property (assign) IBOutlet NSDrawer *settingsDrawer;

// Brwowse
@property (assign) IBOutlet NSTextField *pathTextField;
@property (assign) IBOutlet NSButton *browseButton;

// Search Add Delete
@property (assign) IBOutlet NSTableView *resultsTableView;
@property (assign) IBOutlet NSProgressIndicator *processIndicator;
@property (assign) IBOutlet NSButton *searchButton;

@property (assign) IBOutlet NSButton *resultCheckButton;
@property (assign) IBOutlet NSButton *addFileButton;
@property (assign) IBOutlet NSButton *removeFileButton;

@property (strong) NSAlert *removeAlert;

// Comment
@property (assign) IBOutlet NSButton *insertCommentButton;

// App Status
@property (assign) IBOutlet NSTextField *statusLabel;

// Settings
@property (assign) IBOutlet NSButton *btnInsertCommentOnCfunctions;
@property (assign) IBOutlet NSButton *btnInsertCommentOnProperties;
@property (assign) IBOutlet NSButton *btnInsertCommentOnCEnums;
@property (assign) IBOutlet NSButton *btnInsertCommentOnCStuctMacro;

@property (assign) IBOutlet NSButton *btnAddSinceToComment;
@property (assign) IBOutlet NSButton *btnAddAuthorToComment;

@property (assign) IBOutlet NSButton *btnUseHeaderDoc;
@property (assign) IBOutlet NSButton *btnBlankLinesBetweenSections;
@property (assign) IBOutlet NSButton *btnAlightArgumentComments;

@property (assign) IBOutlet NSMatrix *mtxPrefixOptions;
@property (assign) IBOutlet NSButtonCell *btnPrefixWithWhitespace;
@property (assign) IBOutlet NSButtonCell *btnPrefixWithStar;
@property (assign) IBOutlet NSButtonCell *btnPrefixWithSlashes;

@property (assign) IBOutlet NSButton *btnRemoveItemCheckbox;

@end

@interface ZKFile : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *path;
@property (assign, nonatomic) BOOL *check;
@property (strong, nonatomic) NSString *size;
@property (strong, nonatomic) NSNumber *actualSize;
@property (strong, nonatomic) NSString *status;
@end