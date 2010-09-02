//
// ReviewsViewController.m
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

#import "ReviewsViewController.h"


@implementation ReviewsViewController
@synthesize amazonReviews;

- (void)awakeFromNib{
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setRowHeight:150]; //TODO: adjust height based on review
}

- (void)setISBN:(NSString*)isbn{

    if([reviewsForISBN isEqualToString:isbn]){
	return;
    }else{
	reviewsForISBN = isbn;

	amazonInterface* amazon = [[amazonInterface alloc] init];
	[amazon searchISBN:isbn];
	[self setAmazonReviews:[amazon bookReviews]];
	[amazon release];

	[tableView reloadData];
    }
}

- (id)tableView:(NSTableView*)aTableView objectValueForTableColumn:(NSTableColumn*)aTableColumn 
	    row:(NSInteger)rowIndex{
    
    if(!amazonReviews)
	return nil;

    if([[aTableColumn identifier] isEqualToString:@"reviewDateCol"]){
	return [[amazonReviews objectAtIndex:rowIndex] date];
    }

    if([[aTableColumn identifier] isEqualToString:@"reviewRatingCol"]){
	return [NSString stringWithFormat:@"%f", [[amazonReviews objectAtIndex:rowIndex] rating]];
    }

    if([[aTableColumn identifier] isEqualToString:@"reviewDetailsCol"]){
	BookReview* review = [amazonReviews objectAtIndex:rowIndex];
	return [NSString stringWithFormat:@"%d of %d found this review helpful.\n%@\n\n%@",
					  review.helpfulVotes,
					  review.totalVotes,
					  review.summary,
					  review.content];
    }

    return nil;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView{

    if(!amazonReviews)
	return 0;
    else
	return [amazonReviews count]; 
}

@end
