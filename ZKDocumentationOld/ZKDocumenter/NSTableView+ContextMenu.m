//
//  NSTableView+ContextMenu.m
//  ZKDocumenter
//
//  Created by Zeeshan Khan on 27/04/14.
//  Copyright (c) 2014 Zeeshan Khan. All rights reserved.
//

#import "NSTableView+ContextMenu.h"

@implementation NSTableView (ContextMenu)

- (NSMenu*)menuForEvent:(NSEvent*)event {
    
	NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
	
    NSInteger row = [self rowAtPoint:location];
	if (!(row >= 0) || ([event type] != NSRightMouseDown)) {
		return [super menuForEvent:event];
	}
    
	NSIndexSet *selected = [self selectedRowIndexes];
	if (![selected containsIndex:row]) {
		selected = [NSIndexSet indexSetWithIndex:row];
		[self selectRowIndexes:selected byExtendingSelection:NO];
	}
	return [super menuForEvent:event];
    
/* // This code doesn't work
    NSInteger column = [self columnAtPoint:location];
	if (!(column >= 0) || ([event type] != NSLeftMouseDown)) {
		return [super menuForEvent:event];
	}
    
	NSIndexSet *selectedColumns = [self selectedColumnIndexes];
	if (![selectedColumns containsIndex:column]) {
		selectedColumns = [NSIndexSet indexSetWithIndex:column];
        [self selectColumnIndexes:selectedColumns byExtendingSelection:NO];
	}
	return [super menuForEvent:event];
 */
}

/*
- (void)mouseDown:(NSEvent *)theEvent {
    
    NSPoint globalLocation = [theEvent locationInWindow];
    NSPoint localLocation = [self convertPoint:globalLocation fromView:nil];
    
    NSInteger clickedCol = [self columnAtPoint:localLocation];
    
    [super mouseDown:theEvent];
 
}
*/

@end