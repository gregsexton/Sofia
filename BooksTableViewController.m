//
//  BooksTableViewController.m
//  books
//
//  Created by Greg on 09/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BooksTableViewController.h"


@implementation BooksTableViewController

- (void)awakeFromNib {
    [tableView setDoubleAction:@selector(doubleClickAction:)];
    [tableView setTarget:self]; 
    [tableView setDelegate:self];
    [tableView setDataSource:self];
}

- (IBAction) doubleClickAction:(id)sender {

    NSArray* selectedObjects = [arrayController selectedObjects];

    if([selectedObjects count] > 0){
	book *obj = [selectedObjects objectAtIndex:0]; //use the first object if multiple are selected

	BooksWindowController *detailWin = [[BooksWindowController alloc] initWithManagedObject:obj
										     withSearch:NO];
	if (![NSBundle loadNibNamed:@"Detail" owner:detailWin]) {
	    NSLog(@"Error loading Nib!");
	}
    }
} 

// Delegate Methods //////////////////////////////////////////////////////

//alow the tableview to be a drag and drop source
- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard{
    [self writeBooksWithIndexes:rowIndexes toPasteboard:pboard];
    return true;
}


@end
