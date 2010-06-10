//
//  BooksTableViewController.m
//  books
//
//  Created by Greg on 09/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BooksTableViewController.h"


@implementation BooksTableViewController

//TODO: have a read? column

- (void)awakeFromNib {
    [tableView setDoubleAction:@selector(doubleClickAction:)];
    [tableView setTarget:self]; 
    [tableView setDelegate:self];
    [tableView setDataSource:self];
}

- (IBAction) doubleClickAction:(id)sender {
    //TODO: is anything selected? getting array out of bounds errors
    //use the first object if multiple are selected
    book *obj = [[arrayController selectedObjects] objectAtIndex:0];

    BooksWindowController *detailWin = [[BooksWindowController alloc] initWithManagedObject:obj
										 withSearch:NO];
    if (![NSBundle loadNibNamed:@"Detail" owner:detailWin]) {
	NSLog(@"Error loading Nib!");
    }
} 

// Delegate Methods //////////////////////////////////////////////////////

//alow the tableview to be a drag and drop source
- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard{
    [pboard declareTypes:[NSArray arrayWithObject:SofiaDragType] owner:tableView];

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


@end
