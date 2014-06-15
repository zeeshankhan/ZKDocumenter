//
//  ZKAppDelegate+Settings.m
//  ZKDocumenter
//
//  Created by Zeeshan Khan on 04/05/14.
//  Copyright (c) 2014 Zeeshan Khan. All rights reserved.
//

#import "ZKAppDelegate+Settings.h"
#import "VVDocumenterSetting.h"

@implementation ZKAppDelegate (Settings)

- (IBAction)btnResetPressed:(id)sender {
    
    [[VVDocumenterSetting defaultSetting] setPrefixWithStar:YES];
    [[VVDocumenterSetting defaultSetting] setPrefixWithSlashes:NO];

    [[VVDocumenterSetting defaultSetting] setAddSinceToComments:NO];
    [[VVDocumenterSetting defaultSetting] setAddAuthorToComments:NO];
    
    [[VVDocumenterSetting defaultSetting] setUseHeaderDoc:NO];
    [[VVDocumenterSetting defaultSetting] setBlankLinesBetweenSections:YES];
    [[VVDocumenterSetting defaultSetting] setAlignArgumentComments:YES];
    
    self.btnPrefixWithWhitespace.state = NSOffState;
    self.btnPrefixWithStar.state = NSOnState;
    self.btnPrefixWithSlashes.state = NSOffState;
    
    self.btnAddSinceToComment.state = NSOffState;
    self.btnAddAuthorToComment.state = NSOffState;
    
    self.btnUseHeaderDoc.state = NSOffState;
    self.btnBlankLinesBetweenSections.state = NSOnState;
    self.btnAlightArgumentComments.state = NSOnState;

    self.btnRemoveItemCheckbox.state = NSOnState;
    
    self.btnPrefixWithSlashes.enabled = YES;
}

- (IBAction)btnAddSinceToCommentsPressed:(id)sender {
    [[VVDocumenterSetting defaultSetting] setAddSinceToComments:self.btnAddSinceToComment.state];
}

- (IBAction)btnAddAuthorToCommentsPressed:(id)sender {
    [[VVDocumenterSetting defaultSetting] setAddAuthorToComments:self.btnAddAuthorToComment.state];
}

- (IBAction)useHeaderDoc:(id)sender {
    [[VVDocumenterSetting defaultSetting] setUseHeaderDoc:self.btnUseHeaderDoc.state];
    
    if (self.btnUseHeaderDoc.state == NSOnState) {
        self.btnPrefixWithSlashes.enabled = NO;
        
        // If the slashes option was selected, change to the default stars
        if ([self.mtxPrefixOptions.selectedCell isEqual:self.btnPrefixWithSlashes]) {
            [self.mtxPrefixOptions selectCell:self.btnPrefixWithStar];
            
            // Update the settings in addition to the display
            [self.mtxPrefixOptions sendAction];
        }
    } else {
        self.btnPrefixWithSlashes.enabled = YES;
    }
}
- (IBAction)blankLinesBetweenSections:(id)sender {
    [[VVDocumenterSetting defaultSetting] setBlankLinesBetweenSections:self.btnBlankLinesBetweenSections.state];
}

- (IBAction)alignArgumentComments:(id)sender {
    [[VVDocumenterSetting defaultSetting] setAlignArgumentComments:self.btnAlightArgumentComments.state];
}

- (IBAction)mtxPrefixSettingPressed:(id)sender {
    id selectedCell = self.mtxPrefixOptions.selectedCell;
    [[VVDocumenterSetting defaultSetting] setPrefixWithStar:[selectedCell isEqual:self.btnPrefixWithStar]];
    [[VVDocumenterSetting defaultSetting] setPrefixWithSlashes:[selectedCell isEqual:self.btnPrefixWithSlashes]];
}


- (IBAction)btnRemoveItemCheckboxAction:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:kSettingsRemoveCheckKey] != self.btnRemoveItemCheckbox.state) {
        [defaults setBool:self.btnRemoveItemCheckbox.state forKey:kSettingsRemoveCheckKey];
        [defaults synchronize];
    }
}

@end
