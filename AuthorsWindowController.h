//
//  AuthorsWindowController.h
//
//  Created by Greg on 19/11/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "author.h"


@interface AuthorsWindowController : NSObject {
    IBOutlet NSWindow		*window;

    IBOutlet NSArrayController	*bookArrayController;
    IBOutlet NSTableView	*bookTableView;
    IBOutlet NSArrayController	*authorArrayController;
    IBOutlet NSTableView	*authorTableView;

    author			*initialSelection;
    NSManagedObjectContext	*managedObjectContext;
}

- (IBAction)saveClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;
- (IBAction) doubleClickBookAction:(id)sender;
- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context;
- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context selectedAuthor:(author*)authorInput;
- (void) saveManagedObjectContext:(NSManagedObjectContext*)context;
@end
