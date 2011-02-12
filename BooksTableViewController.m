//
// BooksTableViewController.m
//
// Copyright 2011 Greg Sexton
//
// This file is part of Sofia.
// 
// Sofia is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// Sofia is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with Sofia.  If not, see <http://www.gnu.org/licenses/>.
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

    book* obj = [self currentlySelectedBook];
    [self openDetailWindowForBook:obj];
} 

- (book*)currentlySelectedBook{
    NSArray* selectedObjects = [arrayController selectedObjects];

    if([selectedObjects count] > 0){
	book *obj = [selectedObjects objectAtIndex:0]; //use the first object if multiple are selected
	return obj;
    }

    return nil;
}

// Delegate Methods //////////////////////////////////////////////////////

//alow the tableview to be a drag and drop source
- (BOOL)tableView:(NSTableView *)aTableView 
	writeRowsWithIndexes:(NSIndexSet *)rowIndexes 
		toPasteboard:(NSPasteboard *)pboard{
			    
    [self writeBooksWithIndexes:rowIndexes toPasteboard:pboard];
    return true;
}

@end
