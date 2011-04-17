//
// SimilarBooksViewController.m
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

#import "SimilarBooksViewController.h"
#import "BooksWindowController.h"


@implementation SimilarBooksViewController
@synthesize application;

- (void)awakeFromNib{
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setDoubleAction:@selector(doubleClickAction:)];
    [tableView setTarget:self];

    //appearance
    [tableView setRowHeight:150];
    //[tableView setIntercellSpacing:NSMakeSize(3.0, 20.0)];

    titles = [[NSMutableArray alloc] initWithCapacity:5];
    images = [[NSMutableArray alloc] initWithCapacity:5];
    isbns  = [[NSMutableArray alloc] initWithCapacity:5];
    urls   = [[NSMutableArray alloc] initWithCapacity:5];
}

- (void)dealloc{
    if(amazonASINs)
	[amazonASINs release];
    [titles release];
    [images release];
    [isbns release];
    [urls release];

    [super dealloc];
}

- (void)setISBN:(NSString*)isbn{

    if([similarToISBN isEqualToString:isbn]){
	return;
    }else{

	//this uses Grand Central Dispatch to download the details
	//in a seperate thread so as not to lock the main thread.
	dispatch_queue_t q_default;
	q_default = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

	dispatch_async(q_default, ^{
	    [progIndicator setUsesThreadedAnimation:YES];
	    [progIndicator startAnimation:self];

	    similarToISBN = isbn;

	    amazonInterface* amazon = [[amazonInterface alloc] init];
	    NSArray* similarASINs = [amazon similarBooksToISBN:isbn];
	    [self setASINs:similarASINs];
	    [amazon release];

	    [progIndicator stopAnimation:self];
	});
    }
}


- (void)setASINs:(NSArray*)asins{

    if(amazonASINs)
	[amazonASINs release];

    amazonASINs = [asins retain];

    for(NSString* asin in amazonASINs){
	amazonInterface* amazon = [[amazonInterface alloc] init];
	[amazon searchASIN:asin];

	NSString* textData = [NSString stringWithFormat:@"%@\n\n%@",
				[amazon bookTitle]?[amazon bookTitle]:@"",
				[amazon bookSummary]?[amazon bookSummary]:@""];

	NSImage* image = [amazon frontCover]?[amazon frontCover]:[NSImage imageNamed:@"missing.png"];

	[titles addObject:textData];
	[images addObject:image];
	[isbns  addObject:[amazon bookISBN13]?[amazon bookISBN13]:@""];
	[urls	addObject:[amazon amazonLink]?[amazon amazonLink]:[NSURL URLWithString:@"http://www.amazon.co.uk"]];

	[amazon release];
    }

    [tableView reloadData];
}

- (IBAction)doubleClickAction:(id)sender{

    NSUInteger rowIndex = [tableView selectedRow];

    book* bookObj = [bookWinController bookInLibraryWithISBN:[isbns objectAtIndex:rowIndex]];
    if(bookObj){
	int alertReturn;
	alertReturn = NSRunInformationalAlertPanel(@"This book is already in your library.",
						   @"Would you like to display it in Sofia or continue on to the web page?",
						   @"Continue",
						   @"Display",
						   nil);
	if (alertReturn == NSAlertAlternateReturn){
	    BooksWindowController *detailWin = [[BooksWindowController alloc] initWithManagedObject:bookObj
                                                                                            withApp:application
											 withSearch:NO];
            [detailWin loadWindow];
            [[detailWin window] setDelegate:application];
	    return;
	}
    }

    [[NSWorkspace sharedWorkspace] openURL:[urls objectAtIndex:rowIndex]];
}


///////////////////////    DELEGATE METHODS   //////////////////////////////////////////////////////////////////////////

- (id)tableView:(NSTableView*)aTableView objectValueForTableColumn:(NSTableColumn*)aTableColumn
	    row:(NSInteger)rowIndex{

    if(!amazonASINs)
	return nil;

    if([[aTableColumn identifier] isEqualToString:@"dataCol"]){
	return [titles objectAtIndex:rowIndex];
    }

    if([[aTableColumn identifier] isEqualToString:@"imageCol"]){
	return [images objectAtIndex:rowIndex];
    }

    return nil;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView{

    if(!amazonASINs)
	return 0;
    else
	return [titles count]; //titles chosen arbitrarily; do not use amazonASINs, during downloading the tableview
			       //tries to show more rows than it has information for.
}

- (NSString *)tableView:(NSTableView *)aTableView
	 toolTipForCell:(NSCell*)aCell
		   rect:(NSRectPointer)rect
	    tableColumn:(NSTableColumn*)aTableColumn
		    row:(NSInteger)row
	  mouseLocation:(NSPoint)mouseLocation{

    return @"";
}

@end
