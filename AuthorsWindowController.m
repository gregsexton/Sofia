//
// AuthorsWindowController.m
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

#import "AuthorsWindowController.h"
#import "book.h"
#import "author.h"
#import "BooksWindowController.h"

//TODO: pressing backspace removes an author or book from author
//depending on selected tableview

@implementation AuthorsWindowController
@synthesize delegate;

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context {
    managedObjectContext = context;
    initialSelection = nil;
    return self;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context selectedAuthor:(author*)authorInput{
    managedObjectContext = context;
    initialSelection = authorInput;
    return self;
}

- (void) awakeFromNib {
    [window makeKeyAndOrderFront:self];

    [bookTableView setDoubleAction:@selector(doubleClickBookAction:)];
    [bookTableView setTarget:self]; 

    //guarantees loaded as next instruction doesn't execute until afterwards
    NSError *error;
    [authorArrayController fetchWithRequest:nil merge:NO error:&error];

    if(initialSelection != nil){
	//assumes that the order of arrangedObjects is the same as
	//the index of the rows in the tableview.
	//TODO: scroll to selected row.
	NSIndexSet *index = [NSIndexSet indexSetWithIndex:[[authorArrayController arrangedObjects] indexOfObject:initialSelection]];
	[authorTableView selectRowIndexes:index byExtendingSelection:NO];
    }

    //sort two tables
    [authorTableView setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:true]]];
    [bookTableView   setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:true]]];
    
}

- (NSManagedObjectContext *) managedObjectContext{
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    return nil;
}

- (void) beginEditingCurrentlySelectedItemInAuthorsTable{
    [authorTableView editColumn:0
			    row:[authorTableView selectedRow] 
		      withEvent:nil 
			 select:YES];
}

- (IBAction)saveClicked:(id)sender {
    [self saveManagedObjectContext:managedObjectContext];
    //let delegate know
    if([[self delegate] respondsToSelector:@selector(savedWithAuthorSelection:)]) {
	[[self delegate] savedWithAuthorSelection:[[authorArrayController selectedObjects] objectAtIndex:0]];
    }
    [window close];
}

- (IBAction)cancelClicked:(id)sender {
    [window close];
}

- (void) saveManagedObjectContext:(NSManagedObjectContext*)context {
    NSError *error = nil;
    if (![context save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (IBAction) doubleClickBookAction:(id)sender {
    //use the first object if multiple are selected
    book *obj = [[bookArrayController selectedObjects] objectAtIndex:0];

    BooksWindowController *detailWin = [[BooksWindowController alloc] initWithManagedObject:obj
										 withSearch:false];
    if (![NSBundle loadNibNamed:@"Detail" owner:[detailWin autorelease]]) {
	NSLog(@"Error loading Nib!");
    }
} 

- (IBAction)addAuthorAction:(id)sender{
    [authorArrayController add:self];
    //TODO: select the added item and begin editing it.
    //[self beginEditingCurrentlySelectedItemInAuthorsTable];
}
@end
