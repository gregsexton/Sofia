//
//  AuthorsWindowController.m
//
//  Created by Greg on 19/11/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AuthorsWindowController.h"
#import "book.h"
#import "author.h"
#import "BooksWindowController.h"


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
}

- (NSManagedObjectContext *) managedObjectContext{
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
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

    BooksWindowController *detailWin = [[BooksWindowController alloc] initWithManagedObject:obj];
    if (![NSBundle loadNibNamed:@"Detail" owner:detailWin]) {
	NSLog(@"Error loading Nib!");
    }
} 
@end
