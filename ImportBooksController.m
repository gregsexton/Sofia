//
//  ImportBooksController.m
//  books
//
//  Created by Greg on 14/06/2010.
//  Copyright 2010 Greg Sexton Software. All rights reserved.
//

#import "ImportBooksController.h"


@implementation ImportBooksController
@synthesize isbns;
@synthesize windowToAttachTo;

//TODO: better icon for import toolbar button!
//TODO: import button
//TODO: drag and drop a file
//TODO: BooksWindowController delegate and write the protocol!

- (void)awakeFromNib {
    [contentTextView setDelegate:self];

    if(windowToAttachTo != nil){
	[NSApp beginSheet:importSheet modalForWindow:windowToAttachTo 
				       modalDelegate:self 
				      didEndSelector:NULL 
					 contextInfo:nil];
    }
}

- (IBAction)addWebsiteAction:(id)sender{
    NSURL* inputUrl = [NSURL URLWithString:[urlTextField stringValue]];
    if(inputUrl == nil)
	return; //TODO: error message?

    //NSString* inputUrlContents = [NSString stringWithContentsOfURL:inputUrl encoding:NSUTF8StringEncoding error:&error];

    // Synchronously grab the data 
    NSError *error;
    NSURLRequest *request = [NSURLRequest requestWithURL:inputUrl];
    NSURLResponse *response;
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    if(result == nil)
	return; //TODO: error message?

    NSString* inputUrlContents = [[NSString alloc] initWithData:result encoding:NSASCIIStringEncoding];

    //TODO: refactor: extract method?
    isbnExtractor* extract = [[isbnExtractor alloc] initWithContent:inputUrlContents];
    [self setIsbns:[extract discoveredISBNs]];
    [extract release];
}

- (IBAction)cancelAction:(id)sender{
    [importSheet orderOut:nil];
    [NSApp endSheet:importSheet];
    [importSheet close];
}

- (IBAction)importAction:(id)sender{
}

- (IBAction)clearAction:(id)sender{
    [contentTextView setString:@""];
    [urlTextField setStringValue:@""];
    [self setIsbns:nil];
}

- (void)textDidChange:(NSNotification *)aNotification{
    NSString* inputText = [contentTextView string];
    isbnExtractor* extract = [[isbnExtractor alloc] initWithContent:inputText];
    [self setIsbns:[extract discoveredISBNs]];
    [extract release];
}

@end
