//
//  BooksTableViewController.h
//  books
//
//  Created by Greg on 09/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "book.h"
#import "BooksWindowController.h"
#import "BooksMainViewController.h"

@interface BooksTableViewController : BooksMainViewController <NSTableViewDelegate, NSTableViewDataSource>{

    IBOutlet BooksTableView* tableView;
}

- (IBAction)doubleClickAction:(id)sender;

@end
