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

//TODO: this sorely needs setting up as bindings in the nib rather than doing this through code.
@interface BooksWindowController : NSWindowController <AuthorsWindowControllerDelegate,
                                                       SubjectWindowControllerDelegate> {
    NSTextField*                txt_search;

    NSTextField*                txt_isbn10;
    NSTextField*                txt_isbn13;
    NSComboBox*                 txt_title;
    NSComboBox*                 txt_titleLong;
    NSComboBox*                 txt_author;
    NSComboBox*                 txt_publisher;
    NSComboBox*                 txt_subject;
    NSTextField*                txt_edition;
    NSComboBox*                 txt_physicalDescrip;
    NSTextField*                txt_dewey;
    NSTextField*                txt_deweyNormal;
    NSTextField*                txt_lccNumber;
    NSTextField*                txt_language;
    NSTextField*                txt_noOfCopies;
    NSStepper*                  step_noOfCopies;

    NSTextView*                 txt_summary;
    NSTextView*                 txt_notes;
    NSTextView*                 txt_awards;
    NSTextView*                 txt_urls;

    NSTextView*                 txt_toc;

    NSButton*                   btn_search;
    NSButton*                   btn_clear;
    NSButton*                   btn_save;
    NSButton*                   btn_cancel;

    //for the summary tab
    NSTextField*                lbl_summary_isbn10;
    NSTextField*                lbl_summary_isbn13;
    NSTextField*                lbl_summary_title;
    NSTextField*                lbl_summary_titleLong;
    NSTextField*                lbl_summary_author;
    NSTextField*                lbl_summary_publisher;
    NSTextField*                lbl_summary_subject;
    NSTextField*                lbl_summary_edition;
    NSTextField*                lbl_summary_physicalDescrip;
    NSTextField*                lbl_summary_dewey;
    NSTextField*                lbl_summary_deweyNormal;
    NSTextField*                lbl_summary_lccNumber;
    NSTextField*                lbl_summary_language;
    NSTextField*                lbl_summary_noOfCopies;
    NSTextField*                lbl_summary_summary;

    NSImageView*                img_summary_cover;
    NSImageView*                img_cover;

    NSTableView*                authorsTableView;
    NSTableView*                subjectsTableView;
    NSProgressIndicator*        progIndicator;

    //top level objects
    NSManagedObjectContext*     managedObjectContext;
    NSObjectController*         bookObjectController;
    NSArrayController*          authorsArrayController;
    NSArrayController*          subjectsArrayController;
    SimilarBooksViewController* similarBooksController;
    ReviewsViewController*      reviewsController;
    NSPanel*                    progressSheet;

    NSTextField*                errorLabel;
    NSMutableArray*             isbnSearchErrors;

    book*                                obj;
    author*                              doubleClickedAuthor;
    subject*                             doubleClickedSubject;
    SofiaApplication*                    sofiaApplication;
    id<BooksWindowControllerDelegate>    delegate;
    BOOL                                 displaySearch;
}

@property (nonatomic, retain) book *obj;
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) BOOL displaySearch;

@property (nonatomic, assign) IBOutlet NSTextField*                txt_search;

@property (nonatomic, assign) IBOutlet NSTextField*                txt_isbn10;
@property (nonatomic, assign) IBOutlet NSTextField*                txt_isbn13;
@property (nonatomic, assign) IBOutlet NSComboBox*                 txt_title;
@property (nonatomic, assign) IBOutlet NSComboBox*                 txt_titleLong;
@property (nonatomic, assign) IBOutlet NSComboBox*                 txt_author;
@property (nonatomic, assign) IBOutlet NSComboBox*                 txt_publisher;
@property (nonatomic, assign) IBOutlet NSComboBox*                 txt_subject;
@property (nonatomic, assign) IBOutlet NSTextField*                txt_edition;
@property (nonatomic, assign) IBOutlet NSComboBox*                 txt_physicalDescrip;
@property (nonatomic, assign) IBOutlet NSTextField*                txt_dewey;
@property (nonatomic, assign) IBOutlet NSTextField*                txt_deweyNormal;
@property (nonatomic, assign) IBOutlet NSTextField*                txt_lccNumber;
@property (nonatomic, assign) IBOutlet NSTextField*                txt_language;
@property (nonatomic, assign) IBOutlet NSTextField*                txt_noOfCopies;
@property (nonatomic, assign) IBOutlet NSStepper*                  step_noOfCopies;

@property (nonatomic, assign) IBOutlet NSTextView*                 txt_summary;
@property (nonatomic, assign) IBOutlet NSTextView*                 txt_notes;
@property (nonatomic, assign) IBOutlet NSTextView*                 txt_awards;
@property (nonatomic, assign) IBOutlet NSTextView*                 txt_urls;

@property (nonatomic, assign) IBOutlet NSTextView*                 txt_toc;

@property (nonatomic, assign) IBOutlet NSButton*                   btn_search;
@property (nonatomic, assign) IBOutlet NSButton*                   btn_clear;
@property (nonatomic, assign) IBOutlet NSButton*                   btn_save;
@property (nonatomic, assign) IBOutlet NSButton*                   btn_cancel;

//for the summary tab
@property (nonatomic, assign) IBOutlet NSTextField*                lbl_summary_isbn10;
@property (nonatomic, assign) IBOutlet NSTextField*                lbl_summary_isbn13;
@property (nonatomic, assign) IBOutlet NSTextField*                lbl_summary_title;
@property (nonatomic, assign) IBOutlet NSTextField*                lbl_summary_titleLong;
@property (nonatomic, assign) IBOutlet NSTextField*                lbl_summary_author;
@property (nonatomic, assign) IBOutlet NSTextField*                lbl_summary_publisher;
@property (nonatomic, assign) IBOutlet NSTextField*                lbl_summary_subject;
@property (nonatomic, assign) IBOutlet NSTextField*                lbl_summary_edition;
@property (nonatomic, assign) IBOutlet NSTextField*                lbl_summary_physicalDescrip;
@property (nonatomic, assign) IBOutlet NSTextField*                lbl_summary_dewey;
@property (nonatomic, assign) IBOutlet NSTextField*                lbl_summary_deweyNormal;
@property (nonatomic, assign) IBOutlet NSTextField*                lbl_summary_lccNumber;
@property (nonatomic, assign) IBOutlet NSTextField*                lbl_summary_language;
@property (nonatomic, assign) IBOutlet NSTextField*                lbl_summary_noOfCopies;
@property (nonatomic, assign) IBOutlet NSTextField*                lbl_summary_summary;

@property (nonatomic, assign) IBOutlet NSImageView*                img_summary_cover;
@property (nonatomic, assign) IBOutlet NSImageView*                img_cover;

@property (nonatomic, assign) IBOutlet NSTableView*                authorsTableView;
@property (nonatomic, assign) IBOutlet NSTableView*                subjectsTableView;
@property (nonatomic, assign) IBOutlet NSProgressIndicator*        progIndicator;

//top level objects
@property (nonatomic, assign) IBOutlet NSManagedObjectContext*     managedObjectContext;
@property (nonatomic, assign) IBOutlet NSObjectController*         bookObjectController;
@property (nonatomic, assign) IBOutlet NSArrayController*          authorsArrayController;
@property (nonatomic, assign) IBOutlet NSArrayController*          subjectsArrayController;
@property (nonatomic, assign) IBOutlet SimilarBooksViewController* similarBooksController;
@property (nonatomic, assign) IBOutlet ReviewsViewController*      reviewsController;
@property (nonatomic, assign) IBOutlet NSPanel*                    progressSheet;

@property (nonatomic, assign) IBOutlet NSTextField*                errorLabel;

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
- (id)initWithManagedObject:(book*)object withApp:(SofiaApplication*)app withSearch:(BOOL)withSearch;
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
