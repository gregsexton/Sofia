//
// AuthorsWindowController.h
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
#import "author.h"
#import "AuthorsWindowControllerDelegate.h"
@class SofiaApplication;


@interface AuthorsWindowController : NSWindowController {

    NSArrayController*            bookArrayController;
    NSTableView*                  bookTableView;
    NSArrayController*            authorArrayController;
    NSTableView*                  authorTableView;
    NSButton*                     saveButton;
    NSManagedObjectContext*       managedObjectContext;

    SofiaApplication*             sofiaApplication;

    NSPersistentStoreCoordinator* coordinator;
    author*                       initialSelection;
    BOOL			  useSelectButton;

    id<AuthorsWindowControllerDelegate>	delegate;
}
@property (nonatomic, assign) id<AuthorsWindowControllerDelegate> delegate;
@property (nonatomic, assign) IBOutlet NSArrayController*      bookArrayController;
@property (nonatomic, assign) IBOutlet NSTableView*            bookTableView;
@property (nonatomic, assign) IBOutlet NSArrayController*      authorArrayController;
@property (nonatomic, assign) IBOutlet NSTableView*            authorTableView;
@property (nonatomic, assign) IBOutlet NSButton*               saveButton;
@property (nonatomic, assign) IBOutlet NSManagedObjectContext* managedObjectContext;

- (IBAction)addAuthorAction:(id)sender;
- (IBAction)cancelClicked:(id)sender;
- (IBAction)doubleClickBookAction:(id)sender;
- (IBAction)saveClicked:(id)sender;
- (id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator*)coord application:(SofiaApplication*)app;
- (id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator*)coord
                             application:(SofiaApplication*)app
                          selectedAuthor:(author*)authorInput
                            selectButton:(BOOL)withSelect;
- (void)loadWindow;
- (void)saveManagedObjectContext:(NSManagedObjectContext*)context;
- (void)selectAndScrollToAuthor:(author*)authorObj;
@end


@interface AuthorsTableView : NSTableView {

    IBOutlet NSArrayController	*authorArrayController;

}

@end
