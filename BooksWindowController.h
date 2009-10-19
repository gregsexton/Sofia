//
//  BooksWindowController.h
//  books
//
//  Created by Greg Sexton on 26/07/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <GData/GDataBooks.h>

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

    NSManagedObject	    *obj;
}

@property (nonatomic, assign) NSManagedObject *obj;

- (IBAction)searchClicked:(id)sender;
- (IBAction)clearClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;
- (IBAction)saveClicked:(id)sender;
- (IBAction)copiesValueChanged:(id)sender;

- (void) updateUIFromManagedObject;
- (id) initWithManagedObject:(NSManagedObject*)object;
- (void) clearAllFields;
- (void) saveManagedObjectContext:(NSManagedObjectContext*)context;
- (BOOL) updateUIFromISBNDb;
- (void) updateManagedObjectFromUI;
@end
