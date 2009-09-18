//
//  BooksWindowController.m
//  books
//
//  Created by Greg Sexton on 26/07/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BooksWindowController.h"
#import "isbndbInterface.h"

@implementation BooksWindowController

- (id)init {
    self = [super init];
    return self;
}

- (void) awakeFromNib {
    [window makeKeyAndOrderFront:self];
}

- (IBAction) searchClicked:(id)sender {
    isbndbInterface *isbndb = [[isbndbInterface alloc] init];
    [isbndb searchISBN:[txt_search stringValue]];

    //TODO: refactor into updateUI method
    [txt_isbn10 setStringValue:[isbndb bookISBN10]];
    [txt_isbn13 setStringValue:[isbndb bookISBN13]];
    [txt_edition setStringValue:[isbndb bookEdition]];
    [txt_dewey setStringValue:[isbndb bookDewey]];
    [txt_deweyNormal setStringValue:[isbndb bookDeweyNormalized]];
    [txt_lccNumber setStringValue:[isbndb bookLCCNumber]];
    [txt_language setStringValue:[isbndb bookLanguage]];

    [txt_summary setStringValue:[isbndb bookSummary]];
    [txt_notes setStringValue:[isbndb bookNotes]];
    [txt_awards setStringValue:[isbndb bookAwards]];
    [txt_urls setStringValue:[isbndb bookUrls]];

    [txt_title addItemWithObjectValue:[[[isbndb bookTitle] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] capitalizedString]];
    [txt_titleLong addItemWithObjectValue:[[[isbndb bookTitleLong] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] capitalizedString]];
    [txt_publisher addItemWithObjectValue:[[[isbndb bookPublisher] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] capitalizedString]];
    [txt_author addItemWithObjectValue:[[[isbndb bookISBN13] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] capitalizedString]];
    [txt_physicalDescrip addItemWithObjectValue:[[[isbndb bookPhysicalDescrip] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] capitalizedString]];

    [txt_title selectItemAtIndex:0];
    [txt_titleLong selectItemAtIndex:0];
    [txt_author selectItemAtIndex:0];
    [txt_publisher selectItemAtIndex:0];
    [txt_physicalDescrip selectItemAtIndex:0];
}


- (IBAction) clearClicked:(id)sender {
    [txt_search setStringValue:@""];
}

- (IBAction) cancelClicked:(id)sender {
    [window close];
}

@end
