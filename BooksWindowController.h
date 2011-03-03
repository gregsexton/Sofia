//
// BooksWindowController.h
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
/*#import <GData/GDataBooks.h>*/
#import <QuartzCore/QuartzCore.h>
#import "book.h"
#import "author.h"
#import "subject.h"
#import "amazonInterface.h"
#import "BooksWindowControllerDelegate.h"
#import "AuthorsWindowControllerDelegate.h"
#import "SubjectWindowControllerDelegate.h"
#import "isbnExtractor.h"
#import "isbndbInterface.h"
#import "AuthorsWindowController.h"
#import "SubjectWindowController.h"
#import "NSString+Sofia.h"
#import "SimilarBooksViewController.h"
#import "ReviewsViewController.h"

@interface BooksWindowController : NSObjectController <AuthorsWindowControllerDelegate, SubjectWindowControllerDelegate> {
    IBOutlet NSTextField *txt_search;

    IBOutlet NSTextField    *txt_isbn10;
    IBOutlet NSTextField    *txt_isbn13;
    IBOutlet NSComboBox	    *txt_title;
    IBOutlet NSComboBox     *txt_titleLong;
    IBOutlet NSComboBox     *txt_author;
    IBOutlet NSComboBox     *txt_publisher;
    IBOutlet NSComboBox	    *txt_subject;
    IBOutlet NSTextField    *txt_edition;
    IBOutlet NSComboBox     *txt_physicalDescrip;
    IBOutlet NSTextField    *txt_dewey;
    IBOutlet NSTextField    *txt_deweyNormal;
    IBOutlet NSTextField    *txt_lccNumber;
    IBOutlet NSTextField    *txt_language;
    IBOutlet NSTextField    *txt_noOfCopies;
    IBOutlet NSStepper	    *step_noOfCopies;

    IBOutlet NSTextView     *txt_summary;
    IBOutlet NSTextView     *txt_notes;
    IBOutlet NSTextView     *txt_awards;
    IBOutlet NSTextView     *txt_urls;

    IBOutlet NSTextView	    *txt_toc;

    IBOutlet NSButton	    *btn_search;
    IBOutlet NSButton 	    *btn_clear;
    IBOutlet NSButton 	    *btn_save;
    IBOutlet NSButton 	    *btn_cancel;

    IBOutlet NSWindow	    *window;
    IBOutlet NSPanel	    *progressSheet;

    IBOutlet NSProgressIndicator *progIndicator;

    //for the summary tab
    IBOutlet NSTextField    *lbl_summary_isbn10;
    IBOutlet NSTextField    *lbl_summary_isbn13;
    IBOutlet NSTextField    *lbl_summary_title;
    IBOutlet NSTextField    *lbl_summary_titleLong;
    IBOutlet NSTextField    *lbl_summary_author;
    IBOutlet NSTextField    *lbl_summary_publisher;
    IBOutlet NSTextField    *lbl_summary_subject;
    IBOutlet NSTextField    *lbl_summary_edition;
    IBOutlet NSTextField    *lbl_summary_physicalDescrip;
    IBOutlet NSTextField    *lbl_summary_dewey;
    IBOutlet NSTextField    *lbl_summary_deweyNormal;
    IBOutlet NSTextField    *lbl_summary_lccNumber;
    IBOutlet NSTextField    *lbl_summary_language;
    IBOutlet NSTextField    *lbl_summary_noOfCopies;
    IBOutlet NSTextField    *lbl_summary_summary;

    IBOutlet NSImageView    *img_summary_cover;
    IBOutlet NSImageView    *img_cover;

    IBOutlet NSTableView	*authorsTableView;
    IBOutlet NSTableView	*subjectsTableView;
    IBOutlet NSArrayController	*authorsArrayController;
    IBOutlet NSArrayController	*subjectsArrayController;
    IBOutlet SimilarBooksViewController *similarBooksController;
    IBOutlet ReviewsViewController *reviewsController;

    IBOutlet NSTextField    *errorLabel;
    NSMutableArray	    *isbnSearchErrors;

    book				*obj;
    author				*doubleClickedAuthor;
    subject				*doubleClickedSubject;
    NSManagedObjectContext		*managedObjectContext;
    id<BooksWindowControllerDelegate>   delegate;
    BOOL				displaySearch;
}

@property (nonatomic, assign) book *obj;
@property (nonatomic, assign) id delegate;
@property (nonatomic) BOOL displaySearch;

- (IBAction)addAuthorClicked:(id)sender;
- (IBAction)addSubjectClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;
- (IBAction)clearClicked:(id)sender;
- (IBAction)copiesValueChanged:(id)sender;
- (IBAction)removeErrorMessage:(id)sender;
- (IBAction)saveClicked:(id)sender;
- (IBAction)searchClicked:(id)sender;

- (BOOL)bookExistsInLibraryWithISBN:(NSString*)searchedISBN;
- (BOOL)updateUIFromAmazonWithISBN:(NSString*)searchedISBN;
- (BOOL)updateUIFromISBNDbWithISBN:(NSString*)searchedISBN;
- (NSFetchRequest*)authorExistsWithName:(NSString*)authorName;
- (NSFetchRequest*)entity:(NSString*)entity existsWithName:(NSString*)entityName;
- (NSFetchRequest*)subjectExistsWithName:(NSString*)subjectName;
- (book*)bookInLibraryWithISBN:(NSString*)searchedISBN;
- (id)initWithManagedObject:(book*)object withSearch:(BOOL)withSearch;
- (void)clearAllFields;
- (void)displayErrorMessage:(NSString*)error;
- (void)displayManagedAuthorsWithSelectedAuthor:(author*)authorObj;
- (void)displayManagedSubjectsWithSelectedSubject:(subject*)subjectObj;
- (void)saveManagedObjectContext:(NSManagedObjectContext*)context;
- (void)searchForISBN:(NSString*)isbn;
- (void)selectFirstItemInComboBox:(NSComboBox*)combo;
- (void)updateAuthorsAndSubjectsFromISBNDb:(isbndbInterface*)isbndb;
- (void)updateManagedObjectFromUI;
- (void)updateSummaryTabView;
- (void)updateUIFromManagedObject;
@end
