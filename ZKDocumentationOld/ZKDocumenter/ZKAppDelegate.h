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

#define kSettingsSinceKey @"kSettingsSinceKey"
#define kSettingsAuthorKey @"kSettingsAuthorKey"
#define kSettingsRemoveCheckKey @"kSettingsRemoveCheckKey"

@interface ZKAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property (assign) IBOutlet NSWindow *window;

// Brwowse
@property (assign) IBOutlet NSTextField *pathTextField;
@property (assign) IBOutlet NSButton *browseButton;

// Settings
@property (assign) IBOutlet NSButton *sinceCheckbox;
@property (assign) IBOutlet NSButton *authorCheckbox;

// Search Add Delete
@property (assign) IBOutlet NSTableView *resultsTableView;
@property (assign) IBOutlet NSProgressIndicator *processIndicator;
@property (assign) IBOutlet NSButton *searchButton;

@property (assign) IBOutlet NSButton *resultCheckButton;
@property (assign) IBOutlet NSButton *addFileButton;
@property (assign) IBOutlet NSButton *removeFileButton;

@property (assign) IBOutlet NSPanel *removeActionSeet;
@property (assign) IBOutlet NSTextField *removeMessageTextField;
@property (assign) IBOutlet NSButton *removeMessageCheckbox;


// Comment
@property (assign) IBOutlet NSButton *insertCommentButton;

// App Status
@property (assign) IBOutlet NSTextField *statusLabel;

@end

@interface ZKFile : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *path;
@property (assign, nonatomic) BOOL *check;
@property (strong, nonatomic) NSString *size;
@property (strong, nonatomic) NSNumber *actualSize;
@property (strong, nonatomic) NSString *status;
@end