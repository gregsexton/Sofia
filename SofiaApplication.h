//
//  SofiaApplication.h
//
//  Created by Greg Sexton on 14/09/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BooksWindowController.h"
#import "book.h"
#import "author.h"
#import "subject.h"
#import "AuthorsWindowController.h"
#import "SubjectWindowController.h"
#import "AccessKeyViewController.h"
#import "GeneralViewController.h"
#import "MBPreferencesController.h"
#import "Library.h"
@class BooksTableView;
@class SidebarOutlineView;

@interface SofiaApplication : NSObject {
	
	IBOutlet NSWindow *window;
	IBOutlet BooksTableView *tableView;
	IBOutlet NSTextField *summaryText;
	IBOutlet NSArrayController *arrayController;
	IBOutlet NSApplication *theApplication;
	IBOutlet NSSegmentedControl *addRemoveButtons;
	IBOutlet SidebarOutlineView *sideBar;
	
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
	NSManagedObjectModel *managedObjectModel;
	NSManagedObjectContext *managedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

- (IBAction) saveAction:sender;
- (IBAction) addRemoveClickAction:(id)sender;
- (IBAction) addBookAction:(id)sender;
- (IBAction) removeBookAction:(id)sender;
- (IBAction) aboutClickAction:(id)sender;
- (IBAction) manageAuthorsClickAction:(id)sender;
- (IBAction) manageSubjectsClickAction:(id)sender;
- (IBAction) displayPreferencesClickAction:(id)sender;
- (IBAction) search:(id)sender;
- (void) updateSummaryText;

@end
