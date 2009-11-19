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
	IBOutlet NSTextField *summaryText;
	IBOutlet NSArrayController *arrayController;
	IBOutlet NSApplication *theApplication;
	IBOutlet NSSegmentedControl *addRemoveButtons;
	
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
	NSManagedObjectModel *managedObjectModel;
	NSManagedObjectContext *managedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

- (IBAction) saveAction:sender;
- (IBAction) doubleClickAction:(id)sender;
- (IBAction) addRemoveClickAction:(id)sender;
- (IBAction) addBookAction:(id)sender;
- (IBAction) removeBookAction:(id)sender;
- (IBAction) aboutClickAction:(id)sender;
- (IBAction) manageAuthorsClickAction:(id)sender;
- (void) updateSummaryText;

@end
