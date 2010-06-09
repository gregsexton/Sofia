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
#import "SidebarOutlineView.h"
#import "SofiaApplication.h"

#define SofiaDragType @"SofiaDragType"

@interface BooksTableViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>{

    IBOutlet BooksTableView* tableView;
    IBOutlet NSArrayController* arrayController;
    IBOutlet SidebarOutlineView* sideBar;
    IBOutlet SofiaApplication* application;
}

- (IBAction)doubleClickAction:(id)sender;
- (void)removeSelectedItems;

@end
