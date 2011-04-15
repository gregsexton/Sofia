//
// AuthorsWindowController.m
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

#import "AuthorsWindowController.h"
#import "book.h"
#import "author.h"
#import "BooksWindowController.h"

@implementation AuthorsWindowController
@synthesize delegate;
@synthesize bookArrayController;
@synthesize bookTableView;
@synthesize authorArrayController;
@synthesize authorTableView;
@synthesize saveButton;
@synthesize managedObjectContext;

- (id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator*)coord {
    coordinator          = coord;
    initialSelection     = nil;
    useSelectButton      = false;
    return self;
}

- (id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator*)coord
                          selectedAuthor:(author*)authorInput
                            selectButton:(BOOL)withSelect{
    coordinator          = coord;
    initialSelection     = authorInput;
    useSelectButton      = withSelect;
    return self;
}

- (void)awakeFromNib {
    [[self window] makeKeyAndOrderFront:self];

    [bookTableView setDoubleAction:@selector(doubleClickBookAction:)];
    [bookTableView setTarget:self];

    [managedObjectContext setPersistentStoreCoordinator:coordinator];

    //guarantees loaded as next instruction doesn't execute until afterwards
    NSError *error;
    [authorArrayController fetchWithRequest:nil merge:NO error:&error];

    //sort two tables
    [authorTableView setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                   ascending:true]]];
    [bookTableView   setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                                                   ascending:true]]];

    if(initialSelection != nil){
	[self selectAndScrollToAuthor:initialSelection];
    }

    if(useSelectButton){
	[saveButton setTitle:@"Select"];
    }

}

- (void)dealloc{
    [authorArrayController release];
    [bookArrayController release];
    [managedObjectContext release];

    [super dealloc];
}

- (void)loadWindow{
    if (![NSBundle loadNibNamed:@"AuthorDetail" owner:self]) {
        NSLog(@"Error loading Nib!");
        return;
    }
}

- (void)selectAndScrollToAuthor:(author*)authorObj{
    //linear search -- this is a hack and won't work for mulitple authors with the same name FIXME
    NSUInteger idx = NSNotFound;
    NSUInteger count = 0;
    for(author* a in [authorArrayController arrangedObjects]){
        if([[a name] isEqualToString:[authorObj name]]){
            idx = count;
            break;
        }
        count++;
    }
    if(idx == NSNotFound){
        return;
    }

    NSIndexSet *index = [NSIndexSet indexSetWithIndex:idx];
    [authorTableView selectRowIndexes:index byExtendingSelection:NO];
    [authorTableView scrollRowToVisible:[index firstIndex]];
}

- (void)beginEditingCurrentlySelectedItemInAuthorsTable{
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
    [[self window] performClose:self];
}

- (IBAction)cancelClicked:(id)sender {
    [[self window] performClose:self];
}

- (void)saveManagedObjectContext:(NSManagedObjectContext*)context {
    NSError *error = nil;
    if (![context save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (IBAction)doubleClickBookAction:(id)sender {
    //use the first object if multiple are selected
    book *obj = [[bookArrayController selectedObjects] objectAtIndex:0];

    BooksWindowController *detailWin = [[BooksWindowController alloc] initWithManagedObject:obj
										 withSearch:false];
    if (![NSBundle loadNibNamed:@"Detail" owner:[detailWin autorelease]]) {
	NSLog(@"Error loading Nib!");
    }
}

- (IBAction)addAuthorAction:(id)sender{
    author* authorObj = [[authorArrayController newObject] autorelease];
    [authorArrayController addObject:authorObj];
    [self selectAndScrollToAuthor:authorObj];
    [self beginEditingCurrentlySelectedItemInAuthorsTable];
}
@end

//custom NSTableView
@implementation AuthorsTableView

- (void)keyDown:(NSEvent *)theEvent{
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];

    if (key == NSDeleteCharacter || key == NSBackspaceCharacter){
	[authorArrayController remove:self];
    }else{
	//pass on to next first responder if not going to handle it
	[super keyDown:theEvent];
    }
}

@end
