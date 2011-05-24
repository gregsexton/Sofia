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

@interface SofiaApplication : NSObject <BooksWindowControllerDelegate,
                                        ImportBooksControllerDelegate,
                                        NSWindowDelegate> {

	NSWindow                     *window;
	NSTextField                  *summaryText;
	NSArrayController            *arrayController;
	NSApplication                *theApplication;
	NSSegmentedControl           *addRemoveButtons;
	NSSegmentedControl           *changeViewButtons;
	SidebarOutlineView           *sideBar;
	NSSlider                     *zoomSlider;

	BooksTableView               *tableView;
	BooksImageBrowserView        *imagesView;
	BooksCoverflowController     *coverflowController;

        NSView                       *mainViewContainerView;
	NSView                       *mainView;
	NSView                       *mainTableView; //this includes the scrollview
	NSView                       *mainImagesView;
	NSView                       *mainCoverflowView;
	NSView                       *currentView;

	NSPersistentStoreCoordinator *persistentStoreCoordinator;
	NSManagedObjectModel         *managedObjectModel;
	NSManagedObjectContext       *managedObjectContext;

        NSViewAnimation              *revealFilterAnimation;
        NSViewAnimation              *hideFilterAnimation;

        NSMenu                       *viewMenu;

}

@property (nonatomic, assign) IBOutlet NSWindow                 *window;
@property (nonatomic, assign) IBOutlet NSTextField              *summaryText;
@property (nonatomic, assign) IBOutlet NSArrayController        *arrayController;
@property (nonatomic, assign) IBOutlet NSApplication            *theApplication;
@property (nonatomic, assign) IBOutlet NSSegmentedControl       *addRemoveButtons;
@property (nonatomic, assign) IBOutlet NSSegmentedControl       *changeViewButtons;
@property (nonatomic, assign) IBOutlet SidebarOutlineView       *sideBar;
@property (nonatomic, assign) IBOutlet NSSlider                 *zoomSlider;

@property (nonatomic, assign) IBOutlet BooksTableView           *tableView;
@property (nonatomic, assign) IBOutlet BooksImageBrowserView    *imagesView;
@property (nonatomic, assign) IBOutlet BooksCoverflowController *coverflowController;

@property (nonatomic, assign) IBOutlet NSView                   *mainViewContainerView;
@property (nonatomic, assign) IBOutlet NSView                   *mainView;
@property (nonatomic, assign) IBOutlet NSView                   *mainTableView; //this includes the scrollview
@property (nonatomic, assign) IBOutlet NSView                   *mainImagesView;
@property (nonatomic, assign) IBOutlet NSView                   *mainCoverflowView;
@property (nonatomic, assign) IBOutlet NSMenu                   *viewMenu;

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

- (BOOL)checkCompatabilityOfPersistentStore:(NSPersistentStoreCoordinator*)psc withURL:(NSURL*)url
                                  storeType:(NSString*)storeType;
- (BOOL)migratePersistentStoreSourceMetadata:(NSDictionary*)sourceMetadata destModel:(NSManagedObjectModel*)destModel
                                                                           sourceURL:(NSURL*)srcUrl
                                                                          sourceType:(NSString*)storeType;
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
