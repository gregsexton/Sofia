//
//  SubjectWindowController.m
//  books
//
//  Created by Greg on 28/11/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SubjectWindowController.h"


@implementation SubjectWindowController
@synthesize delegate;

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context {
    managedObjectContext = context;
    initialSelection = nil;
    return self;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context selectedSubject:(subject*)subjectInput{
    managedObjectContext = context;
    initialSelection = subjectInput;
    return self;
}

- (void) awakeFromNib {
    [window makeKeyAndOrderFront:self];

    [bookTableView setDoubleAction:@selector(doubleClickBookAction:)];
    [bookTableView setTarget:self]; 

    //guarantees loaded as next instruction doesn't execute until afterwards
    NSError *error;
    [subjectArrayController fetchWithRequest:nil merge:NO error:&error];

    if(initialSelection != nil){
	//assumes that the order of arrangedObjects is the same as the index of the rows in the tableview.
	//TODO: scroll to selected row.
	NSIndexSet *index = [NSIndexSet indexSetWithIndex:[[subjectArrayController arrangedObjects] indexOfObject:initialSelection]];
	[subjectTableView selectRowIndexes:index byExtendingSelection:NO];
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
    if([[self delegate] respondsToSelector:@selector(savedWithSubjectSelection:)]) {
	[[self delegate] savedWithSubjectSelection:[[subjectArrayController selectedObjects] objectAtIndex:0]];
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
