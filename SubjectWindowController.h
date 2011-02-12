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


@interface SubjectWindowController : NSObject {
    IBOutlet NSWindow		*window;

    IBOutlet NSArrayController	*bookArrayController;
    IBOutlet NSTableView	*bookTableView;
    IBOutlet NSArrayController	*subjectArrayController;
    IBOutlet NSTableView	*subjectTableView;
    IBOutlet NSButton		*saveButton;

    subject			*initialSelection;
    BOOL			useSelectButton;
    NSManagedObjectContext	*managedObjectContext;

    id<SubjectWindowControllerDelegate> delegate;
}
@property (nonatomic, assign) id<SubjectWindowControllerDelegate> delegate;

- (IBAction)saveClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;
- (IBAction)doubleClickBookAction:(id)sender;
- (IBAction)addSubjectAction:(id)sender;
- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context;
- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context selectedSubject:(subject*)subjectInput selectButton:(BOOL)withSelect;
- (void)saveManagedObjectContext:(NSManagedObjectContext*)context;
- (void)selectAndScrollToSubject:(subject*)subjectObj;

@end

@interface SubjectsTableView : NSTableView {

    IBOutlet NSArrayController	*subjectArrayController;

}

@end
