//
// ImportBooksController.m
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

#import "ImportBooksController.h"
#import "SofiaApplication.h"


@implementation ImportBooksController
@synthesize isbns;
@synthesize windowToAttachTo;
@synthesize delegate;

//TODO: drag and drop a file

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
    NSString* inputUrlString = [urlTextField stringValue];
    if([inputUrlString isEqualToString:@""])
	return;
    NSURL* inputUrl = [NSURL URLWithString:inputUrlString];
    if(inputUrl == nil)
	return;

    // Synchronously grab the data 
    NSError *error;
    NSURLRequest *request = [NSURLRequest requestWithURL:inputUrl];
    NSURLResponse *response;
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    if(result == nil){
	NSRunInformationalAlertPanel(@"Download Error", @"Unable to retrieve web page. Please check internet connectivity." , @"Ok", nil, nil);
	return;
    }

    NSString* inputUrlContents = [[NSString alloc] initWithData:result encoding:NSASCIIStringEncoding];

    [self updateISBNsWithContent:inputUrlContents];
}

- (IBAction)cancelAction:(id)sender{
    [importSheet orderOut:nil];
    [NSApp endSheet:importSheet];
    [importSheet close];
    if([[self delegate] respondsToSelector:@selector(closeClickedOnImportBooksController:)])
	[delegate closeClickedOnImportBooksController:self];
}

- (IBAction)importAction:(id)sender{
    if([isbns count] <= 0)
	return;
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

- (void) updateISBNsWithContent:(NSString*)content{
    isbnExtractor* extract = [[isbnExtractor alloc] initWithContent:content];
    [self setIsbns:[extract discoveredISBNsWithoutDups]];
    [extract release];
}

//delegate methods/////////////////////////////////////////////////////////////////////////////////////

- (void)textDidChange:(NSNotification *)aNotification{
    NSString* inputText = [contentTextView string];
    [self updateISBNsWithContent:inputText];
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
