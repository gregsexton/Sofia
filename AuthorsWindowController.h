//
//  AuthorsWindowController.h
//  books
//
//  Created by Greg on 19/11/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AuthorsWindowController : NSObject {
    IBOutlet NSWindow	    *window;

    NSManagedObjectContext  *managedObjectContext;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context;
- (IBAction)saveClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;
- (void) saveManagedObjectContext:(NSManagedObjectContext*)context;
@end
