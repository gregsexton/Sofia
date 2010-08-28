//
// SimilarBooksViewController.m
//
// Copyright 2010 Greg Sexton
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


@implementation SimilarBooksViewController

//TODO: error handling what if book not found or isbn incorrect, no internet connection?

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
    isbns = [[NSMutableArray alloc] initWithCapacity:5];
    urls = [[NSMutableArray alloc] initWithCapacity:5];
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

	similarToISBN = isbn;

	amazonInterface* amazon = [[amazonInterface alloc] init];
	NSArray* similarASINs = [amazon similarBooksToISBN:isbn];
	[self setASINs:similarASINs];
	[amazon release];
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

    //TODO: check if book is in library and display it instead.
    //may need to extract methods to do this?

    [[NSWorkspace sharedWorkspace] openURL:[urls objectAtIndex:[tableView selectedRow]]];
} 

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
	return [amazonASINs count];
}

@end
