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
}

- (IBAction) searchClicked:(id)sender {
    isbndbInterface *isbndb = [[isbndbInterface alloc] init];
    [isbndb searchISBN:[txt_search stringValue]];
    [txt_title addItemWithObjectValue:[[[isbndb bookTitle] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] capitalizedString]];
    [txt_publisher addItemWithObjectValue:[[[isbndb bookPublisher] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] capitalizedString]];
    [txt_author addItemWithObjectValue:[[[isbndb bookISBN13] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] capitalizedString]];
    [txt_author addItemWithObjectValue:@"hello!"];
    [txt_title selectItemAtIndex:0];
    [txt_author selectItemAtIndex:0];
    [txt_publisher selectItemAtIndex:0];
}

@end
