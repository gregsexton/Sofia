//
//  SubjectWindowController.h
//  books
//
//  Created by Greg on 28/11/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "subject.h"
#import "book.h"
#import "BooksWindowController.h"


@interface SubjectWindowController : NSObject {
    IBOutlet NSWindow		*window;

    IBOutlet NSArrayController	*bookArrayController;
    IBOutlet NSTableView	*bookTableView;
    IBOutlet NSArrayController	*subjectArrayController;
    IBOutlet NSTableView	*subjectTableView;

    subject			*initialSelection;
    NSManagedObjectContext	*managedObjectContext;

    id				*delegate;
}
@property (nonatomic, assign) id *delegate;

- (IBAction)saveClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;
- (IBAction) doubleClickBookAction:(id)sender;
- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context;
- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context selectedSubject:(subject*)subjectInput;
- (void) saveManagedObjectContext:(NSManagedObjectContext*)context;

@end
