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
    IBOutlet NSComboBox *txt_title;
    IBOutlet NSComboBox *txt_author;
    IBOutlet NSComboBox *txt_publisher;
    IBOutlet NSTextField *txt_search;
    IBOutlet NSButton *btn_search;
    IBOutlet NSScrollView *scrl_view;
}

- (IBAction)searchClicked:(id)sender;

@end
