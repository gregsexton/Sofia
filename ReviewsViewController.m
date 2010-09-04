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

//TODO: error handling what if book not found or isbn incorrect, no internet connection?

- (void)awakeFromNib{
    [tableView setDelegate:self];
    [tableView setDataSource:self];
}

- (void)setISBN:(NSString*)isbn{

    if([reviewsForISBN isEqualToString:isbn]){
	return;
    }else{
	//this uses Grand Central Dispatch to download the details
	//in a seperate thread so as not to lock the main thread. 
	dispatch_queue_t q_default;
	q_default = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

	dispatch_async(q_default, ^{
	    [progIndicator setUsesThreadedAnimation:YES];
	    [progIndicator startAnimation:self];

	    reviewsForISBN = isbn;

	    amazonInterface* amazon = [[amazonInterface alloc] init];
	    [amazon searchISBN:isbn];
	    [self setAmazonReviews:[amazon bookReviews]];

	    [progIndicator stopAnimation:self];
	    [averageRatingLabel setStringValue:[NSString stringWithFormat:@"Average rating: %f", [amazon bookAverageRating]]];
	    [tableView reloadData];
	    [amazon release];
	});
    }
}

- (NSString*)bookReviewContentForRow:(NSInteger)rowIndex{
    BookReview* review = [amazonReviews objectAtIndex:rowIndex];
    return [NSString stringWithFormat:@"%d of %d found this review helpful.\n%@\n\n%@",
				      review.helpfulVotes,
				      review.totalVotes,
				      review.summary,
				      review.content];
}


///////////////////////    DELEGATE METHODS   //////////////////////////////////////////////////////////////////////////


- (id)tableView:(NSTableView*)aTableView objectValueForTableColumn:(NSTableColumn*)aTableColumn 
	    row:(NSInteger)rowIndex{
    
    if(!amazonReviews)
	return nil;

    if([[aTableColumn identifier] isEqualToString:@"reviewDateCol"]){
	return [[amazonReviews objectAtIndex:rowIndex] date];
    }

    if([[aTableColumn identifier] isEqualToString:@"reviewRatingCol"]){
	return [NSNumber numberWithDouble:[[amazonReviews objectAtIndex:rowIndex] rating]];
    }

    if([[aTableColumn identifier] isEqualToString:@"reviewDetailsCol"]){
	return [self bookReviewContentForRow:rowIndex];
    }

    return nil;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView{

    if(!amazonReviews)
	return 0;
    else
	return [amazonReviews count]; 
}

- (CGFloat)tableView:(NSTableView *)aTableView heightOfRow:(NSInteger)rowIndex{
    // get column width
    NSTableColumn *tabCol = [[tableView tableColumns] objectAtIndex:1];
    float width = [tabCol width];

    NSRect r = NSMakeRect(0,0,width,1000.0);
    NSCell *cell = [tabCol dataCellForRow:rowIndex];

    NSString* content = [self bookReviewContentForRow:rowIndex];
    [cell setObjectValue:content];
    float height = [cell cellSizeForBounds:r].height;
    if (height <= 0) 
	height = 16.0; // Ensure miniumum height is 16.0
    return height;
}
@end
