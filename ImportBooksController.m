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

- (id)init{
    if(self = [super init]){
	arrayCounter = 0;
    }
    return self;
}
- (id)initWithSofiaApplication:(SofiaApplication*)theApplication{
    if(self = [self init]){
	application = theApplication;
    }
    return self;
}
	
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
    [self setIsbns:[extract discoveredISBNsWithoutDups]];
    [extract release];
}

- (IBAction)cancelAction:(id)sender{
    [importSheet orderOut:nil];
    [NSApp endSheet:importSheet];
    [importSheet close];
}

- (IBAction)importAction:(id)sender{
    BooksWindowController* detailWin = [application createBookAndOpenDetailWindow];
    [detailWin setDelegate:self];
    [detailWin searchForISBN:[isbns objectAtIndex:arrayCounter]];
}

- (IBAction)clearAction:(id)sender{
    [contentTextView setString:@""];
    [urlTextField setStringValue:@""];
    [self setIsbns:nil];
}

- (void) advanceToNextISBN {
    if(arrayCounter+1 < [isbns count]){
	arrayCounter++;
	[self importAction:self];
    }
}

//delegate methods/////////////////////////////////////////////////////////////////////////////////////

- (void)textDidChange:(NSNotification *)aNotification{
    NSString* inputText = [contentTextView string];
    isbnExtractor* extract = [[isbnExtractor alloc] initWithContent:inputText];
    [self setIsbns:[extract discoveredISBNsWithoutDups]];
    [extract release];
}

//delegate method performed by booksWindowController.
- (void) saveClicked:(BooksWindowController*)booksWindowController {
    [application saveClicked:booksWindowController];
    [self advanceToNextISBN];
}

//delegate method performed by booksWindowController.
- (void) cancelClicked:(BooksWindowController*)booksWindowController {
    [self advanceToNextISBN];
}

@end
