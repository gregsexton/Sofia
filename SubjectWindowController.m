//
//  SubjectWindowController.m
//  books
//
//  Created by Greg on 28/11/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SubjectWindowController.h"


@implementation SubjectWindowController

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context {
    managedObjectContext = context;
    initialSelection = nil;
    return self;
}

@end
