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
    IBOutlet NSTextField    *txt_edition;
    IBOutlet NSComboBox     *txt_physicalDescrip;
    IBOutlet NSTextField    *txt_dewey;
    IBOutlet NSTextField    *txt_deweyNormal;
    IBOutlet NSTextField    *txt_lccNumber;
    IBOutlet NSTextField    *txt_language;

    IBOutlet NSTextField    *txt_summary;
    IBOutlet NSTextField    *txt_notes;
    IBOutlet NSTextField    *txt_awards;
    IBOutlet NSTextField    *txt_urls;

    IBOutlet NSButton	    *btn_search;
    IBOutlet NSButton 	    *btn_clear;
    IBOutlet NSButton 	    *btn_save;
    IBOutlet NSButton 	    *btn_cancel;

    IBOutlet NSWindow	    *window;

    NSManagedObject	    *obj;
}

@property (nonatomic,copy) NSManagedObject *obj;

- (IBAction)searchClicked:(id)sender;
- (IBAction)clearClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;
- (IBAction)saveClicked:(id)sender;

- (void) updateUIFromManagedObject;
- (void) updateManagedObjectFromUI;
- (id)initWithManagedObject:(NSManagedObject*)object;
@end
