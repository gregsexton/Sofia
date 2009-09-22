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

@synthesize obj;

- (id)init {
    self = [super init];
    return self;
}

- (id)initWithManagedObject:(NSManagedObject*)object {
    self = [super init];
    obj = object;
    return self;
}

- (void) awakeFromNib {
    [window makeKeyAndOrderFront:self];
    if (obj != nil){
	[self updateUIFromManagedObject];
    }
}

- (void) updateUIFromManagedObject {
    if (obj != nil){
	if([obj valueForKey:@"isbn10"] != nil){
	    [txt_isbn10 setStringValue:[obj valueForKey:@"isbn10"]];
	}
	if([obj valueForKey:@"isbn13"] != nil){
	    [txt_isbn13 setStringValue:[obj valueForKey:@"isbn13"]];
	}
	if([obj valueForKey:@"edition"] != nil){
	    [txt_edition setStringValue:[obj valueForKey:@"edition"]];
	}
	if([obj valueForKey:@"dewey"] != nil){
	    [txt_dewey setStringValue:[obj valueForKey:@"dewey"]];
	}
	if([obj valueForKey:@"dewey_normalised"] != nil){
	    [txt_deweyNormal setStringValue:[obj valueForKey:@"dewey_normalised"]];
	}
	if([obj valueForKey:@"lccNumber"] != nil){
	    [txt_lccNumber setStringValue:[obj valueForKey:@"lccNumber"]];
	}
	if([obj valueForKey:@"language"] != nil){
	    [txt_language setStringValue:[obj valueForKey:@"language"]];
	}

	if([obj valueForKey:@"summary"] != nil){
	    [txt_summary setStringValue:[obj valueForKey:@"summary"]];
	}
	if([obj valueForKey:@"notes"] != nil){
	    [txt_notes setStringValue:[obj valueForKey:@"notes"]];
	}
	if([obj valueForKey:@"awards"] != nil){
	    [txt_awards setStringValue:[obj valueForKey:@"awards"]];
	}
	if([obj valueForKey:@"urls"] != nil){
	    [txt_urls setStringValue:[obj valueForKey:@"urls"]];
	}

	if([obj valueForKey:@"title"] != nil){
	    [txt_title addItemWithObjectValue:[obj valueForKey:@"title"]];
	    [txt_title selectItemAtIndex:0];
	}
	if([obj valueForKey:@"titleLong"] != nil){
	    [txt_titleLong addItemWithObjectValue:[obj valueForKey:@"titleLong"]];
	    [txt_titleLong selectItemAtIndex:0];
	}
	if([obj valueForKey:@"publisherText"] != nil){
	    [txt_publisher addItemWithObjectValue:[obj valueForKey:@"publisherText"]];
	    [txt_publisher selectItemAtIndex:0];
	}
	if([obj valueForKey:@"authorText"] != nil){
	    [txt_author addItemWithObjectValue:[obj valueForKey:@"authorText"]];
	    [txt_author selectItemAtIndex:0];
	}
	if([obj valueForKey:@"physicalDescription"] != nil){
	    [txt_physicalDescrip addItemWithObjectValue:[obj valueForKey:@"physicalDescription"]];
	    [txt_physicalDescrip selectItemAtIndex:0];
	}
    }
}

- (void) updateUIFromISBNDb {
    isbndbInterface *isbndb = [[isbndbInterface alloc] init];
    [isbndb searchISBN:[txt_search stringValue]];

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

    [txt_title addItemWithObjectValue:[isbndb bookTitle]];
    [txt_titleLong addItemWithObjectValue:[isbndb bookTitleLong]];
    [txt_publisher addItemWithObjectValue:[isbndb bookPublisher]];
    [txt_author addItemWithObjectValue:[isbndb bookAuthorsText]];
    [txt_physicalDescrip addItemWithObjectValue:[isbndb bookPhysicalDescrip]];
}

- (void) updateManagedObjectFromUI {
    if (obj != nil){
	//TODO: wrap these in checks?
	[obj setValue:[txt_isbn10 stringValue] forKey:@"isbn10"];
	[obj setValue:[txt_isbn13 stringValue] forKey:@"isbn13"];
	[obj setValue:[txt_author stringValue] forKey:@"authorText"];
	[obj setValue:[txt_awards stringValue] forKey:@"awards"];
	[obj setValue:[txt_dewey stringValue] forKey:@"dewey"];
	[obj setValue:[txt_deweyNormal stringValue] forKey:@"dewey_normalised"];
	[obj setValue:[txt_edition stringValue] forKey:@"edition"];
	[obj setValue:[txt_language stringValue] forKey:@"language"];
	[obj setValue:[txt_lccNumber stringValue] forKey:@"lccNumber"];
	[obj setValue:[txt_notes stringValue] forKey:@"notes"];
	[obj setValue:[txt_physicalDescrip stringValue] forKey:@"physicalDescription"];
	[obj setValue:[txt_publisher stringValue] forKey:@"publisherText"];
	[obj setValue:[txt_summary stringValue] forKey:@"summary"];
	[obj setValue:[txt_title stringValue] forKey:@"title"];
	[obj setValue:[txt_titleLong stringValue] forKey:@"titleLong"];
	[obj setValue:[txt_urls stringValue] forKey:@"urls"];
    }
}

- (IBAction) searchClicked:(id)sender {
    //TODO: warning if this is going to clear out information
    [progIndicator setUsesThreadedAnimation:true];
    [progIndicator startAnimation:self];
    [NSApp beginSheet:progressSheet modalForWindow:window
	   modalDelegate:self didEndSelector:NULL contextInfo:nil];
    
    [self clearAllFields];
    [self updateUIFromISBNDb];

    [txt_title selectItemAtIndex:0];
    [txt_titleLong selectItemAtIndex:0];
    [txt_author selectItemAtIndex:0];
    [txt_publisher selectItemAtIndex:0];
    [txt_physicalDescrip selectItemAtIndex:0];

    [progIndicator stopAnimation:self];
    [progressSheet orderOut:nil];
    [NSApp endSheet:progressSheet];
}

- (IBAction)saveClicked:(id)sender {
    [self updateManagedObjectFromUI];
    [window close];
}

- (IBAction) clearClicked:(id)sender {
    [txt_search setStringValue:@""];
    [self clearAllFields];
}

- (void) clearAllFields {
    [txt_isbn10 setStringValue:@""];
    [txt_isbn13 setStringValue:@""];
    [txt_edition setStringValue:@""];
    [txt_dewey setStringValue:@""];
    [txt_deweyNormal setStringValue:@""];
    [txt_lccNumber setStringValue:@""];
    [txt_language setStringValue:@""];

    [txt_summary setStringValue:@""];
    [txt_notes setStringValue:@""];
    [txt_awards setStringValue:@""];
    [txt_urls setStringValue:@""];

    [txt_title removeAllItems];
    [txt_title setStringValue:@""];
    [txt_titleLong removeAllItems];
    [txt_titleLong setStringValue:@""];
    [txt_publisher removeAllItems];
    [txt_publisher setStringValue:@""];
    [txt_author removeAllItems];
    [txt_author setStringValue:@""];
    [txt_physicalDescrip removeAllItems];
    [txt_physicalDescrip setStringValue:@""];
}

- (IBAction) cancelClicked:(id)sender {
    [window close];
}

@end
