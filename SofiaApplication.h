//
// SofiaApplication.h
//
// Copyright 2010 Greg Sexton
//
// This file is part of Sofia.
// 
// Sofia is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// Sofia is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with Sofia.  If not, see <http://www.gnu.org/licenses/>.
//

#import <Cocoa/Cocoa.h>
#import "BooksWindowController.h"
#import "BooksImageBrowserView.h"
#import "book.h"
#import "author.h"
#import "subject.h"
#import "AuthorsWindowController.h"
#import "SubjectWindowController.h"
#import "AccessKeyViewController.h"
#import "GeneralViewController.h"
#import "MBPreferencesController.h"
#import "Library.h"
#import "ImportBooksController.h"
#import "BooksWindowControllerDelegate.h"
@class BooksTableView;
@class SidebarOutlineView;

//used to save the current view for app restart
#define LIST_VIEW @"listView"
#define IMAGE_VIEW @"imageView"

@interface SofiaApplication : NSObject <BooksWindowControllerDelegate> {
	
	IBOutlet NSWindow *window;
	IBOutlet BooksTableView *tableView;
	IBOutlet BooksImageBrowserView *imagesView;
	IBOutlet NSTextField *summaryText;
	IBOutlet NSArrayController *arrayController;
	IBOutlet NSApplication *theApplication;
	IBOutlet NSSegmentedControl *addRemoveButtons;
	IBOutlet NSSegmentedControl *changeViewButtons;
	IBOutlet SidebarOutlineView *sideBar;
	IBOutlet NSSlider *zoomSlider;

	IBOutlet NSView* mainView;
	IBOutlet NSView* mainTableView; //this includes the scrollview
	IBOutlet NSView* mainImagesView;
	NSView* currentView;
	
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
- (IBAction) changeViewClickAction:(id)sender;
- (IBAction) changeToListView:(id)sender;
- (IBAction) changeToImagesView:(id)sender;
- (IBAction) importBooks:(id)sender;
- (void) updateSummaryText;
- (void) changeMainViewFor:(NSView*)viewToChangeTo;

- (BooksWindowController*) createBookAndOpenDetailWindow;
@end
