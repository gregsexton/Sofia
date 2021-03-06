//
// SimilarBooksViewController.h
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
#import "amazonInterface.h"
#import "book.h"
@class BooksWindowController;
@class SofiaApplication;


@interface SimilarBooksViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource> {

    NSTableView*           tableView;
    BooksWindowController* bookWinController;
    NSProgressIndicator*   progIndicator;

    SofiaApplication* application;

    NSString* similarToISBN;
    NSArray*  amazonASINs;

    NSMutableArray* titles;
    NSMutableArray* images;
    NSMutableArray* isbns;
    NSMutableArray* urls;

}

@property (nonatomic, assign) SofiaApplication* application;
@property (nonatomic, assign) IBOutlet NSTableView*           tableView;
@property (nonatomic, assign) IBOutlet BooksWindowController* bookWinController;
@property (nonatomic, assign) IBOutlet NSProgressIndicator*   progIndicator;

- (void)setASINs:(NSArray*)asins;
- (void)setISBN:(NSString*)isbn;
- (IBAction)doubleClickAction:(id)sender;
@end
