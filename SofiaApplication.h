//
//  SofiaApplication.h
//  books
//
//  Created by Greg Sexton on 14/09/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SofiaApplication : NSObject {
	
	IBOutlet NSWindow *window;
	IBOutlet NSTableView *tableView;
	IBOutlet NSSegmentedControl *addRemoveButtons;
	IBOutlet NSArrayController *arrayController;
	
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
	NSManagedObjectModel *managedObjectModel;
	NSManagedObjectContext *managedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

- (IBAction)saveAction:sender;
- (IBAction) doubleClickAction:(id)sender;
- (IBAction)addRemoveClickAction:(id)sender;

@end
