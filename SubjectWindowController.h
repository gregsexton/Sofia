//
//  SubjectWindowController.h
//  books
//
//  Created by Greg on 28/11/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "subject.h"


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

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context;

@end
