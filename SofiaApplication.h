//
// SofiaApplication.h
//
// Copyright 2011 Greg Sexton
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
#import "ImportBooksController.h"
#import "BooksWindowControllerDelegate.h"
#import "ImportBooksControllerDelegate.h"
@class BooksCoverflowController;
@class BooksTableView;
@class SidebarOutlineView;

#define FILTER_NOTIFICATION_VIEW_HEIGHT 20

//used to save the current view for app restart
#define LIST_VIEW @"listView"
#define IMAGE_VIEW @"imageView"
#define COVER_VIEW @"coverflowView"
#define FIVE_MINUTES (60*5)

@interface SofiaApplication : NSObject <BooksWindowControllerDelegate, ImportBooksControllerDelegate, NSWindowDelegate> {

	IBOutlet NSWindow                 *window;
	IBOutlet NSTextField              *summaryText;
	IBOutlet NSArrayController        *arrayController;
	IBOutlet NSApplication            *theApplication;
	IBOutlet NSSegmentedControl       *addRemoveButtons;
	IBOutlet NSSegmentedControl       *changeViewButtons;
	IBOutlet SidebarOutlineView       *sideBar;
	IBOutlet NSSlider                 *zoomSlider;

	IBOutlet BooksTableView           *tableView;
	IBOutlet BooksImageBrowserView    *imagesView;
	IBOutlet BooksCoverflowController *coverflowController;

        IBOutlet NSView                   *mainViewContainerView;
	IBOutlet NSView                   *mainView;
	IBOutlet NSView                   *mainTableView; //this includes the scrollview
	IBOutlet NSView                   *mainImagesView;
	IBOutlet NSView                   *mainCoverflowView;
	NSView                            *currentView;

	NSPersistentStoreCoordinator      *persistentStoreCoordinator;
	NSManagedObjectModel              *managedObjectModel;
	NSManagedObjectContext            *managedObjectContext;

        NSViewAnimation                   *revealFilterAnimation;
        NSViewAnimation                   *hideFilterAnimation;

        IBOutlet NSMenu                   *viewMenu;

}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

- (IBAction)aboutClickAction:(id)sender;
- (IBAction)addBookAction:(id)sender;
- (IBAction)addRemoveClickAction:(id)sender;
- (IBAction)changeToCoverflowView:(id)sender;
- (IBAction)changeToImagesView:(id)sender;
- (IBAction)changeToListView:(id)sender;
- (IBAction)changeViewClickAction:(id)sender;
- (IBAction)displayPreferencesClickAction:(id)sender;
- (IBAction)importBooks:(id)sender;
- (IBAction)manageAuthorsClickAction:(id)sender;
- (IBAction)manageSubjectsClickAction:(id)sender;
- (IBAction)removeBookAction:(id)sender;
- (IBAction)saveAction:sender;
- (IBAction)search:(id)sender;
- (NSViewAnimation*)hideFilterAnimation;
- (NSViewAnimation*)revealFilterAnimation;
- (void)changeMainViewFor:(NSView*)viewToChangeTo;
- (void)hideFilterNotificationView;
- (void)revealFilterNotificationView;
- (void)updateSummaryText;

- (BooksWindowController*) createBookAndOpenDetailWindow;
@end
