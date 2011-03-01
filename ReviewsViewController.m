//
// ReviewsViewController.m
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

#import "ReviewsViewController.h"


@implementation ReviewsViewController

- (void)awakeFromNib{
}

- (void)dealloc{

    [super dealloc];
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
	    [amazon allReviewsForISBN:isbn];

            NSURL* url = [NSURL URLWithString:[amazon bookReviewIFrameURL]];
            NSLog(@"%@", [amazon bookReviewIFrameURL]);
            [[_webview mainFrame] loadRequest:[NSURLRequest requestWithURL:url]];

	    [amazon release];

	    [progIndicator stopAnimation:self];
	});
    }
}

@end
