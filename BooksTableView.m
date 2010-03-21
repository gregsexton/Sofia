//
//  BooksTableView.m
//  books
//
//  Created by Greg on 21/03/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BooksTableView.h"


@implementation BooksTableView

- (void)awakeFromNib {
    [self setDoubleAction:@selector(doubleClickAction:)];
    [self setTarget:self]; 
    [self setDelegate:self];
    [self setDataSource:self];
}

- (IBAction) doubleClickAction:(id)sender {
    //use the first object if multiple are selected
    book *obj = [[arrayController selectedObjects] objectAtIndex:0];

    //TODO: add a readonly field to constructor to get rid of search box and buttons
    BooksWindowController *detailWin = [[BooksWindowController alloc] initWithManagedObject:obj];
    if (![NSBundle loadNibNamed:@"Detail" owner:detailWin]) {
	NSLog(@"Error loading Nib!");
    }
} 

// Delegate Methods //////////////////////////////////////////////////////

//alow the tableview to be a drag and drop source
- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard{
    [pboard declareTypes:[NSArray arrayWithObject:SofiaDragType] owner:self];

    //get an array of URIs for the selected objects
    NSMutableArray* rows = [NSMutableArray array];
    NSArray* selectedObjects = [[arrayController arrangedObjects] objectsAtIndexes:rowIndexes];

    for (NSManagedObject* o in selectedObjects) {
	[rows addObject:[[o objectID] URIRepresentation]];
    }

    NSData* encodedIDs = [NSKeyedArchiver archivedDataWithRootObject:rows];

    [pboard setData:encodedIDs forType:SofiaDragType];
    return true;
}

// Overridden Methods //////////////////////////////////////////////////////

- (void)keyDown:(NSEvent *)theEvent{
    //NSLog(@"SidebarOutlineView: keyDown: %c", [[theEvent characters] characterAtIndex:0]);
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];

    if (key == NSDeleteCharacter || key == NSBackspaceCharacter){
	id item = [sideBar selectedItem];
	if([item isKindOfClass:[list class]]){
	    NSArray* selectedBooks = [arrayController selectedObjects];
	    [item removeBooks:[NSSet setWithArray:selectedBooks]];
	    [arrayController fetch:self]; //reload filter
	}

	if([item isKindOfClass:[Library class]]){
	    [application removeBookAction:self];
	}
    }

    //TODO: pass on to next first responder if not going to handle it
}
@end
