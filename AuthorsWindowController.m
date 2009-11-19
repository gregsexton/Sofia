//
//  AuthorsWindowController.m
//  books
//
//  Created by Greg on 19/11/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AuthorsWindowController.h"


@implementation AuthorsWindowController

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context {
    managedObjectContext = context;
    return self;
}

- (void) awakeFromNib {
    [window makeKeyAndOrderFront:self];
}

- (NSManagedObjectContext *) managedObjectContext{
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
}

- (IBAction)saveClicked:(id)sender {
    [self saveManagedObjectContext:managedObjectContext];
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
@end
