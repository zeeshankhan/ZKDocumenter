//
//  ZKAppDelegate.m
//  ZKDocumentation
//
//  Created by Zeeshan Khan on 17/04/14.
//  Copyright (c) 2014 Zeeshan Khan. All rights reserved.
//

#import "ZKAppDelegate.h"
#import "ZKCommentingOperation.h"
#import "NSTableView+ContextMenu.h"

@implementation ZKFile
@end

@interface ZKAppDelegate()

@property (strong, nonatomic) NSString * selectedIdentifier;

@property (strong, nonatomic) NSMutableArray *arrResults;

@property (strong, nonatomic) NSOperationQueue *queue;

// Stores the file data to avoid re-reading files, using a lock to make it thread-safe.
@property (strong, nonatomic) NSMutableDictionary *fileData;
@property (strong, nonatomic) NSLock *fileDataLock;

// The search directory path
@property(strong, nonatomic) NSString *searchDirectoryPath;

@property (strong, nonatomic) NSDictionary *dicToBeRemoved;

@end


@implementation ZKAppDelegate

#define kColumnIdentifierStatus                    @"Status"
#define kColumnIdentifierFileName                @"FileName"
#define kColumnIdentifierFullPath                   @"FullPath"
#define kColumnIdentifierCheck                      @"Check"
#define kColumnIdentifierSize                        @"Size"
#define kColumnIdentifierActualSize               @"ActualSize"

#define kCommentStateUncommented    @"Uncommented"
#define kCommentStateCommented       @"Commented"

#define kMaxOperationCount 20

#pragma mark - Application Delegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    // Setup settings
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.sinceCheckbox.state = [userDefaults boolForKey:kSettingsSinceKey];
    self.authorCheckbox.state = [userDefaults boolForKey:kSettingsAuthorKey];
    self.removeMessageCheckbox.state = [userDefaults boolForKey:kSettingsRemoveCheckKey];
    
    // Setup the results array
    self.arrResults = [[[NSMutableArray alloc] init] autorelease];
    
    // Setup the queue
    self.queue = [[[NSOperationQueue alloc] init] autorelease];
    //self.queue.maxConcurrentOperationCount = kMaxOperationCount;
    
    // Setup table view
    self.resultsTableView.delegate = self;
    self.resultsTableView.dataSource = self;
    
    // Setup double click
    [self.resultsTableView setDoubleAction:@selector(tableViewDoubleClicked)];
    
    // Disable selection of all rows when user selects any column
    
    // If we do this, we were not able to select column then - Now enabled as i have found the work around for this... using table view's mouse down method
     [self.resultsTableView setAllowsColumnSelection:NO];
    
    // Set up table view column sort descriptor
    for (NSTableColumn *tableColumn in self.resultsTableView.tableColumns ) {
        
        SEL compare = nil;
        if ([tableColumn.identifier isEqualToString:kColumnIdentifierCheck] || [tableColumn.identifier isEqualToString:kColumnIdentifierSize])
            compare = @selector(compare:);
        else
            compare = @selector(caseInsensitiveCompare:);
        
        if (compare) {
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:tableColumn.identifier ascending:YES selector:compare];
            [tableColumn setSortDescriptorPrototype:sortDescriptor];
        }
    }
    
    // Setup status labels
    [self.statusLabel setTextColor:[NSColor grayColor]];
    [self.statusLabel setStringValue:@""];
    
    // Setup search button
    [self.searchButton setBezelStyle:NSRoundedBezelStyle];
    [self.searchButton setKeyEquivalent:@"\r"];
	
    [self.insertCommentButton setBezelStyle:NSRoundedBezelStyle];
    [self.insertCommentButton setKeyEquivalent:@"\r"];
    
    // Setup file data
	self.fileData = [[NSMutableDictionary new] autorelease];
	self.fileDataLock = [[NSLock new] autorelease];
    
    [self setUIForState:ZKDocumenterStateIdle];
}

- (void)dealloc {
    
    self.selectedIdentifier = nil;
    self.arrResults = nil;
    self.queue = nil;
    self.fileData = nil;
    self.fileDataLock = nil;
    self.searchDirectoryPath = nil;
    self.dicToBeRemoved = nil;
    
    [super dealloc];
}

#pragma mark - Show / Open actions

- (IBAction)showFinderAction:(NSMenuItem *)sender {
    
//    NSLog(@"selected row %lu", _resultsTableView.selectedRow);
//    NSLog(@"clicked row %lu", _resultsTableView.clickedRow);
    
    if (_arrResults.count > [_resultsTableView selectedRow]) {
        NSString *path = [[_arrResults objectAtIndex:[_resultsTableView selectedRow]] objectForKey:kColumnIdentifierFullPath];
        
        [[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:nil];
    }
}

- (IBAction)openWithXcodeAction:(NSMenuItem *)sender {
    if (_arrResults.count > [_resultsTableView selectedRow]) {
        NSString *path = [[_arrResults objectAtIndex:[_resultsTableView selectedRow]] objectForKey:kColumnIdentifierFullPath];
        [self openFileInXcode:path];
    }
    
}

- (void)tableViewDoubleClicked {
    //    NSLog(@"Clicked for view: %lu", [_resultsTableView clickedRow]);
    if (_arrResults.count > [_resultsTableView clickedRow]) {
        NSString *path = [[_arrResults objectAtIndex:[_resultsTableView clickedRow]] objectForKey:kColumnIdentifierFullPath];
        [self openFileInXcode:path];
    }
}

- (void)openFileInXcode:(NSString*)filePath {
    if (filePath) {
        [[NSWorkspace sharedWorkspace] openFile:filePath withApplication:@"Xcode"];
    }
}

#pragma mark - Add Actions

- (IBAction)addItemsFromMenuAction:(NSMenuItem *)sender {
    [self addItemAction:nil];
}

- (IBAction)addItemAction:(id)sender {
    
    [self setUIForState:ZKDocumenterStateBrowsing];
    
    // Show an open panel
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    [openPanel setCanChooseDirectories:NO];
    [openPanel setCanChooseFiles:YES];
    [openPanel setAllowedFileTypes:@[@"m"]];
    [openPanel setAllowsMultipleSelection:YES];
    
    //    NSInteger result = [openPanel runModal]; // as a seperate window
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        
        if (result == NSFileHandlingPanelOKButton) { //NSOKButton
            
            //NSLog(@"Directory: %@", [[openPanel directoryURL] path]);
            for (NSURL* url in [openPanel URLs]) {
                //NSLog(@"URL: %@", url.absoluteString);
                [self addNewResult:url.absoluteString];
            }
            
            [self sortTableViewWithKey:kColumnIdentifierFileName ascending:YES];
            [_statusLabel setStringValue:[NSString stringWithFormat:@"Total Files: %ld", (unsigned long)[_arrResults count]]];
        }
        else {
            [self.statusLabel setStringValue:@""];
        }
        
        [self setUIForState:ZKDocumenterStateIdle];
        
    }];
}

#pragma mark - Remove Item from Table View

- (IBAction)removeItemFromMenuAction:(NSMenuItem *)sender {
    [self removeItemAction:nil];
}

- (IBAction)removeItemAction:(NSButton *)sender {
    if (_arrResults.count > [_resultsTableView selectedRow]) {
        
        self.dicToBeRemoved = [_arrResults objectAtIndex:[_resultsTableView selectedRow]];
        NSLog(@"Remove msg checkbox: %lu", self.removeMessageCheckbox.state);
        if (self.removeMessageCheckbox.state == NO) {
            
            NSString *path = [self.dicToBeRemoved objectForKey:kColumnIdentifierFullPath];
            NSString *fileName = [path lastPathComponent];
            NSString *removeMessage = [NSString stringWithFormat:@"Do you want to delete %@",fileName];
            [self.removeMessageTextField setStringValue:removeMessage];
            [NSApp beginSheet:self.removeActionSeet modalForWindow:self.window modalDelegate:self didEndSelector:nil contextInfo:nil];
        }
        else {
            [self removeItem];
        }
    }
}

- (IBAction)doneSheetAction:(id)sender {
	[self.removeActionSeet orderOut:nil];
	[NSApp endSheet:self.removeActionSeet];
    [self removeItem];
}

- (IBAction)cancelRemoveSheetAction:(id)sender {
	[self.removeActionSeet orderOut:nil];
	[NSApp endSheet:self.removeActionSeet];
}

- (void)removeItem {
    if (self.dicToBeRemoved) {
        if ([self.arrResults indexOfObject:self.dicToBeRemoved] != NSNotFound) {
            [self.arrResults removeObject:self.dicToBeRemoved];
            [self.resultsTableView reloadData];
            [_statusLabel setStringValue:[NSString stringWithFormat:@"Total Files: %ld", (unsigned long)[_arrResults count]]];
        }
        self.dicToBeRemoved = nil;
    }
}

- (IBAction)removeItemCheckboxAction:(NSButton*)removeCheckBtn {
    [[NSUserDefaults standardUserDefaults] setBool:removeCheckBtn.state forKey:kSettingsRemoveCheckKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Comment Settings

- (IBAction)sinceCheckboxAction:(NSButton*)sinceBtn {
    [[NSUserDefaults standardUserDefaults] setBool:sinceBtn.state forKey:kSettingsSinceKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)authorCheckboxAction:(NSButton*)authorBtn {
    [[NSUserDefaults standardUserDefaults] setBool:authorBtn.state forKey:kSettingsAuthorKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Browse action

- (IBAction)browseButtonSelected:(id)sender {
    
    [self setUIForState:ZKDocumenterStateBrowsing];
    
    // Show an open panel
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:NO];
    
    //    NSInteger result = [openPanel runModal]; // as a seperate window
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        
        if (result == NSFileHandlingPanelOKButton) { //NSOKButton
            
            //NSLog(@"Directory: %@", [openPanel URLs]);
            
            // Store the path
            self.searchDirectoryPath = [[openPanel directoryURL] path];
            
            // Update the path text field
            [self.pathTextField setStringValue:self.searchDirectoryPath];
            [self.statusLabel setStringValue:@"Directory Path Set."];
        }
        else {
            [self.statusLabel setStringValue:@""];
        }
        
        [self setUIForState:ZKDocumenterStateIdle];
        
    }];
    
}

#pragma mark - Search action

- (IBAction)startSearch:(id)sender {
    
    // Check for a path
    if (!self.searchDirectoryPath) {
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        [alert setMessageText:@"Project Path Error"];
        [alert setInformativeText:@"Please select a valid project folder!"];
        //        [alert runModal];
        //        [alert setShowsSuppressionButton:YES];
        [alert beginSheetModalForWindow:self.window completionHandler:NULL];
        
        return;
    }
    
    // Check the folder / file
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.searchDirectoryPath]) {
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        [alert setMessageText:@"Project Path Error"];
        [alert setInformativeText:@"Path is not valid!! Please select a valid project folder!"];
        //        [alert setShowsSuppressionButton:YES];
        //        [alert runModal];
        [alert beginSheetModalForWindow:self.window completionHandler:NULL];
        
        return;
    }
    
    // Update the path text field
    [self.pathTextField setStringValue:self.searchDirectoryPath];
    
    // Change the button text
    [self.searchButton setEnabled:NO];
    [self.searchButton setKeyEquivalent:@""];
    
    // Reset
    [self.arrResults removeAllObjects];
    
    // Reload table
    [self.resultsTableView reloadData];
    
    // Start the search
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(runFileSearch) object:nil];
    [self.queue addOperation:op];
    [op release]; op = nil;
    
}

- (void)runFileSearch {
    
    // Start the ui
    [self setUIForState:ZKDocumenterStateSearching];
    
    // Find all the .m files in the folder
    NSArray *files = [self filesAtDirectory:_searchDirectoryPath];
    //self.mFiles = files;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    for (NSString *path in files) {
        
        dispatch_group_async(group, queue, ^{
            
            // Check that the .m file path is not empty
            if(![path isEqualToString:@""]) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self addNewResult:path];
                });
            }
        });
        
    }
    
    
    dispatch_group_notify(group, queue, ^ {
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            [self sortTableViewWithKey:kColumnIdentifierFileName ascending:YES];
            
            [self setUIForState:ZKDocumenterStateIdle];
            
            [_statusLabel setStringValue:[NSString stringWithFormat:@"Search Completed, Total Found: %ld", (unsigned long)[_arrResults count]]];
            
            [_fileData removeAllObjects];
            
        });
    });
}

- (NSArray *)filesAtDirectory:(NSString *)directoryPath {
    
    // Create a find task
    NSTask *task = [[[NSTask alloc] init] autorelease];
    [task setLaunchPath: @"/usr/bin/find"];
    
    // Search for all .m files
    NSArray *argvals = [NSArray arrayWithObjects:directoryPath,@"-name",@"*.m", nil];
    [task setArguments: argvals];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    // Read the response
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
    
    // See if we can create a lines array
    NSArray *lines = [string componentsSeparatedByString:@"\n"];
    
    return lines;
}

- (void)addNewResult:(NSString *)mFilePath {
    
    if (mFilePath == nil || [mFilePath isEqualToString:@""] || [mFilePath length] == 0)
        return;
    
    NSString *filePath = [mFilePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    
    for (NSDictionary *row in self.arrResults) {
        NSString *oldPath = [row objectForKey:kColumnIdentifierFullPath];
        if ([oldPath isEqualToString:filePath]) {
            NSLog(@"Same path found!!");
            return; //break;
        }
    }
    
    // Add and reload
    NSUInteger fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
    //    NSLog(@"Path Size: %@, %@", [self stringFromFileSize:fileSize], filePath);
    
    [self.arrResults addObject:@{kColumnIdentifierCheck: [NSNumber numberWithBool:YES],
                                 kColumnIdentifierStatus: kCommentStateUncommented,
                                 kColumnIdentifierFileName: [filePath lastPathComponent],
                                 kColumnIdentifierFullPath: filePath,
                                 kColumnIdentifierSize: [self stringFromFileSize:fileSize],
                                 kColumnIdentifierActualSize: [NSNumber numberWithInteger:fileSize]
                                 }];
    
    // Reload
    [_resultsTableView reloadData];
    
    // Scroll to the bottom
    NSInteger numberOfRows = [_resultsTableView numberOfRows];
    if (numberOfRows > 0)
        [_resultsTableView scrollRowToVisible:numberOfRows - 1];
}

#pragma mark - Other Functions

- (void)sortTableViewWithKey:(NSString*)key ascending:(BOOL)yesNo {
    
    // Sorting results and refreshing table
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:key ascending:yesNo];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
    
    NSMutableArray *arrTemp = [[self.arrResults sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    self.arrResults = [NSMutableArray arrayWithArray:arrTemp];
    [arrTemp release]; arrTemp = nil;
    
    [_resultsTableView reloadData];
}

- (NSString *)stringFromFileSize:(NSUInteger)theSize {
    
	float floatSize = theSize;
    
    // bytes
	if (theSize<1023)
		return ([NSString stringWithFormat:@"%lu bytes",(unsigned long)theSize]);
	
    // KB
    floatSize = floatSize / 1024;
	if (floatSize<1023)
		return([NSString stringWithFormat:@"%1.1f KB",floatSize]);
	
    // MB
    floatSize = floatSize / 1024;
	if (floatSize<1023)
		return([NSString stringWithFormat:@"%1.1f MB",floatSize]);
	
    // GB
    floatSize = floatSize / 1024;
	return ([NSString stringWithFormat:@"%1.1f GB",floatSize]);
}

- (void)setUIForState:(ZKDocumenterState)state {
    
    if (self.searchDirectoryPath == nil) {
        [_searchButton setKeyEquivalent:@""];
    }
    else {
        [_searchButton setKeyEquivalent:@"\r"];
    }
    
    if (self.arrResults.count == 0) {
        [_insertCommentButton setKeyEquivalent:@""];
    }
    else {
        [_insertCommentButton setKeyEquivalent:@"\r"];
    }
    
    switch (state) {
        case ZKDocumenterStateIdle:
            //            [self.statusLabel setStringValue:@""];
            [self setUIEnabled:YES];
            break;
            
        case ZKDocumenterStateBrowsing:
            [self.statusLabel setStringValue:@"Browsing..."];
            [self setUIEnabled:NO];
            break;
            
        case ZKDocumenterStateSearching:
            [self.statusLabel setStringValue:@"Searching..."];
            [_searchButton setKeyEquivalent:@""];
            [self setUIEnabled:NO];
            break;
            
        case ZKDocumenterStateCommenting:
            [self.statusLabel setStringValue:@"Commenting..."];
            [_insertCommentButton setKeyEquivalent:@""];
            [self setUIEnabled:NO];
            break;
            
        default:
            [self setUIEnabled:YES];
            break;
    }
    
}

- (void)setUIEnabled:(BOOL)state {
    
    // Individual
    if(state) {
        [_processIndicator stopAnimation:self];
    }
    else {
        [_processIndicator startAnimation:self];
    }
    
    // Button groups
    [_searchButton setEnabled:state];
    [_insertCommentButton setEnabled:state];
    [_browseButton setEnabled:state];
    [_pathTextField setEnabled:state];
    [_sinceCheckbox setEnabled:state];
    [_authorCheckbox setEnabled:state];
    [_resultCheckButton setEnabled:state];
    [_addFileButton setEnabled:state];
    [_removeFileButton setEnabled:state];
}



#pragma mark - Commenting

- (IBAction)insertComment:(id)sender {
    
    [self setUIForState:ZKDocumenterStateCommenting];
    
    int x = 0;
    for (NSDictionary *rowObject in _arrResults) {
        
        if ([[rowObject objectForKey:kColumnIdentifierCheck] boolValue]) {
            
            ZKCommentingOperation *operation = [[ZKCommentingOperation alloc] initWithPath:[rowObject objectForKey:kColumnIdentifierFullPath] completionHandler:^(NSString *path, NSError *error) {
                
                NSUInteger cnt = self.queue.operationCount;
                BOOL isMainThread = [NSThread isMainThread];
                NSLog(@"[Inside Handler] OpCnt %lu | mainThread: %@", cnt, (isMainThread) ? @"YES" : @"NO");
                
                if (isMainThread && error == nil) {
                    
                    // Get completed object
                    NSArray *arrTemp = [NSArray arrayWithArray:self.arrResults];
                    int idx = 0;
                    for (NSDictionary *dicRow in arrTemp) {
                        if ([[dicRow objectForKey:kColumnIdentifierFullPath] isEqualToString:path]) {
                            
                            NSMutableDictionary *dicNewRow = [dicRow mutableCopy];
                            [dicNewRow setObject:kCommentStateCommented forKey:kColumnIdentifierStatus];
                            [dicNewRow setObject:[NSNumber numberWithBool:NO] forKey:kColumnIdentifierCheck];
                            
                            [_arrResults replaceObjectAtIndex:idx withObject:dicNewRow];
                            [dicNewRow release]; dicNewRow = nil;
                            break;
                        }
                        idx++;
                    }
                    
                    // Update table and status label
                    [_resultsTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:idx] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
                    
                    NSUInteger total = (unsigned long)_arrResults.count;
                    NSString *finalstatus = [NSString stringWithFormat:@"Commenting... %lu / %lu", total - cnt, total];
                    [self.statusLabel setStringValue:finalstatus];
                }
                
                if (cnt == 0) { //&& isMainThread
                    NSLog(@"All files commenting completed!!");
                    [self.statusLabel setStringValue:@"Comment Inserted"];
                    [self setUIForState:ZKDocumenterStateIdle];
                    [self.resultsTableView reloadData];
                }
                
            }];
            
            [self.queue addOperation:operation];
            [operation release]; operation = nil;
            
        }
        x++;
    }
    
}

- (IBAction)resultCheckAction:(NSButton *)sender {
    
    if (self.arrResults.count > 0) {
        
        //        NSString *title = [NSString stringWithFormat:@"%@", self.resultCheckButton.tag ? @"Select All" : @"De-Select All"];
        //        [self.resultCheckButton setTitle:title];
        
        if (sender.tag)
            [self.resultCheckButton setImage:[NSImage imageNamed:@"multicheck_off.tiff"]] ;
        else
            [self.resultCheckButton setImage:[NSImage imageNamed:@"multicheck_on.tiff"]] ;
        
        NSArray *arrTemp = [NSArray arrayWithArray:self.arrResults];
        for (int x=0; x<arrTemp.count; x++) {
            NSMutableDictionary *dicNew = [[arrTemp objectAtIndex:x] mutableCopy];
            [dicNew setObject:[NSNumber numberWithBool:!sender.tag] forKey:kColumnIdentifierCheck];
            [_arrResults replaceObjectAtIndex:x withObject:dicNew];
            [dicNew release]; dicNew = nil;
        }
        [self.resultsTableView reloadData];
        self.resultCheckButton.tag = !self.resultCheckButton.tag;
    }
}

#pragma mark - NSTableView Delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_arrResults count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex {
    
    NSDictionary *dic = [_arrResults objectAtIndex:rowIndex];
    return [dic objectForKey:[tableColumn identifier]];
}

- (NSCell*)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    NSTextFieldCell *cell = [tableColumn dataCell];
    
    if ([[tableColumn identifier] isEqualToString:kColumnIdentifierStatus] && [[[_arrResults objectAtIndex:row] objectForKey:kColumnIdentifierStatus] isEqualToString:kCommentStateUncommented])
        [cell setTextColor: [NSColor redColor]];
    else if ([[tableColumn identifier] isEqualToString:kColumnIdentifierStatus])
        [cell setTextColor: [NSColor blackColor]];
    
    return cell;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    if ([[tableColumn identifier] isEqualToString:kColumnIdentifierCheck]) {
        NSMutableDictionary *dicRow = [[_arrResults objectAtIndex:row] mutableCopy];
        [dicRow setObject:anObject forKey:kColumnIdentifierCheck];
        [_arrResults replaceObjectAtIndex:row withObject:dicRow];
        [dicRow release]; dicRow = nil;
    }
}

- (void)tableView:(NSTableView *)tableView mouseDownInHeaderOfTableColumn:(NSTableColumn *)tableColumn {
    if (!_selectedIdentifier || ![_selectedIdentifier isEqualToString:tableColumn.identifier]) {
        self.selectedIdentifier = tableColumn.identifier;
    }
}

- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors {

//    NSLog(@"selected column %lu", aTableView.selectedColumn);
//    NSLog(@"clicked column %lu", aTableView.clickedColumn);

    if (oldDescriptors == nil || oldDescriptors.count == 0)
        return;
    
    if (_selectedIdentifier && [_selectedIdentifier isEqualToString:kColumnIdentifierSize]) {
        for (NSSortDescriptor *desc in oldDescriptors) {
            if ([[desc key] isEqualToString:_selectedIdentifier]) {
                [self sortTableViewWithKey:kColumnIdentifierActualSize ascending:desc.ascending];
                self.selectedIdentifier = nil;
                break;
            }
        }
    }
    else {
        NSMutableArray *arrTemp = [[self.arrResults sortedArrayUsingDescriptors:oldDescriptors] mutableCopy];
        self.arrResults = [NSMutableArray arrayWithArray:arrTemp];
        [aTableView reloadData];
        [arrTemp release]; arrTemp = nil;
    }
}

@end
