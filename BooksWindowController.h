//
//  BooksWindowController.h
//
//  Created by Greg Sexton on 26/07/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <GData/GDataBooks.h>
#import "book.h"

@interface BooksWindowController : NSObjectController {
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

    IBOutlet NSTextField    *txt_summary;
    IBOutlet NSTextField    *txt_notes;
    IBOutlet NSTextField    *txt_awards;
    IBOutlet NSTextField    *txt_urls;

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

    IBOutlet NSTableView	*authorsTableView;
    IBOutlet NSTableView	*subjectsTableView;
    IBOutlet NSArrayController	*authorsArrayController;
    IBOutlet NSArrayController	*subjectsArrayController;

    book	    	    *obj;
    NSManagedObjectContext  *managedObjectContext; //TODO: use this instead of [obj managedObjectContext]
    id			    *delegate;
}

@property (nonatomic, assign) book *obj;
@property (nonatomic, assign) id *delegate;

- (IBAction)searchClicked:(id)sender;
- (IBAction)clearClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;
- (IBAction)saveClicked:(id)sender;
- (IBAction)copiesValueChanged:(id)sender;

- (void) updateUIFromManagedObject;
- (id) initWithManagedObject:(book*)object;
- (void) clearAllFields;
- (void) saveManagedObjectContext:(NSManagedObjectContext*)context;
- (BOOL) updateUIFromISBNDb;
- (void) updateManagedObjectFromUI;
- (void) updateSummaryTabView;
@end
