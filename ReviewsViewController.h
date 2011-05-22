//
// ReviewsViewController.h
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

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "amazonInterface.h"
#import "BookReview.h"
#import "FiveStars.h"


@interface ReviewsViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource> {

    WebView*             _webview;
    NSProgressIndicator* progIndicator;
    NSString*            reviewsForISBN;

}
@property (nonatomic, assign) IBOutlet WebView*             _webview;
@property (nonatomic, assign) IBOutlet NSProgressIndicator* progIndicator;

- (void)setISBN:(NSString*)isbn;

@end
