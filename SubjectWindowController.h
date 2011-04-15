//
// SubjectWindowController.h
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
#import "subject.h"
#import "book.h"
#import "BooksWindowController.h"
#import "SubjectWindowControllerDelegate.h"


@interface SubjectWindowController : NSWindowController {
    NSManagedObjectContext*        managedObjectContext;
    NSArrayController*             bookArrayController;
    NSTableView*                   bookTableView;
    NSArrayController*             subjectArrayController;
    NSTableView*                   subjectTableView;
    NSButton*                      saveButton;

    subject*                       initialSelection;
    BOOL                           useSelectButton;
    NSPersistentStoreCoordinator*  coordinator;

    id<SubjectWindowControllerDelegate> delegate;
}
@property (nonatomic, assign) id<SubjectWindowControllerDelegate> delegate;
@property (nonatomic, assign) IBOutlet NSManagedObjectContext* managedObjectContext;
@property (nonatomic, assign) IBOutlet NSArrayController*      bookArrayController;
@property (nonatomic, assign) IBOutlet NSTableView*            bookTableView;
@property (nonatomic, assign) IBOutlet NSArrayController*      subjectArrayController;
@property (nonatomic, assign) IBOutlet NSTableView*            subjectTableView;
@property (nonatomic, assign) IBOutlet NSButton*               saveButton;

- (IBAction)saveClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;
- (IBAction)doubleClickBookAction:(id)sender;
- (IBAction)addSubjectAction:(id)sender;
- (id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator*)context;
- (id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator*)context selectedSubject:(subject*)subjectInput selectButton:(BOOL)withSelect;
- (void)saveManagedObjectContext:(NSManagedObjectContext*)context;
- (void)selectAndScrollToSubject:(subject*)subjectObj;

@end

@interface SubjectsTableView : NSTableView {

    IBOutlet NSArrayController  *subjectArrayController;

}

@end
