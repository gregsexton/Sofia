//
// BooksMainViewController.m
//
// Copyright 2010 Greg Sexton
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

#import "BooksMainViewController.h"


@implementation BooksMainViewController

- (void)removeSelectedItems{
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

- (void)writeBooksWithIndexes:(NSIndexSet*)rowIndexes toPasteboard:(NSPasteboard*)pboard{
    [pboard declareTypes:[NSArray arrayWithObject:SofiaDragType] owner:self];

    //get an array of URIs for the selected objects
    NSMutableArray* rows = [NSMutableArray array];
    NSArray* selectedObjects = [[arrayController arrangedObjects] objectsAtIndexes:rowIndexes];

    for (NSManagedObject* o in selectedObjects) {
	[rows addObject:[[o objectID] URIRepresentation]];
    }

    NSData* encodedIDs = [NSKeyedArchiver archivedDataWithRootObject:rows];

    [pboard setData:encodedIDs forType:SofiaDragType];
}

- (void)openDetailWindowForBook:(book*)obj{
    BooksWindowController *detailWin = [[BooksWindowController alloc] initWithManagedObject:obj
										 withSearch:NO];
    if (![NSBundle loadNibNamed:@"Detail" owner:[detailWin autorelease]]) {
	NSLog(@"Error loading Nib!");
    }
}

// menu functions ////////////////////////////////////////////////////////

- (NSMenu*)menuForBook:(book*)bookObj{
    NSMenu *theMenu = [[[NSMenu alloc] initWithTitle:@"Contextual Menu"] autorelease];

    [theMenu insertItemWithTitle:@"View Detail"
			  action:@selector(menuOpenDetailWindowForBook:)
		   keyEquivalent:@""
			 atIndex:0];
    [[theMenu itemAtIndex:0] setRepresentedObject:bookObj];
    [[theMenu itemAtIndex:0] setTarget:self];

    [theMenu insertItem:[NSMenuItem separatorItem]
		atIndex:1];

    [theMenu insertItemWithTitle:@"Remove Book"
			  action:@selector(removeSelectedItems)
		   keyEquivalent:@""
			 atIndex:2];
    [[theMenu itemAtIndex:2] setTarget:self];

    return theMenu;
}

- (IBAction)menuOpenDetailWindowForBook:(id)sender{
    [self openDetailWindowForBook:[sender representedObject]];
}

@end
