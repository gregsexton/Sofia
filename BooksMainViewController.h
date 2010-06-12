//
//  BooksMainViewController.h
//  books
//
//  Created by Greg on 10/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SidebarOutlineView.h"
#import "SofiaApplication.h"

#define SofiaDragType @"SofiaDragType"

@interface BooksMainViewController : NSViewController {

    IBOutlet NSArrayController *arrayController;
    IBOutlet SidebarOutlineView* sideBar;
    IBOutlet SofiaApplication* application;
}

- (void)removeSelectedItems;
- (void)writeBooksWithIndexes:(NSIndexSet*)rowIndexes toPasteboard:(NSPasteboard*)pboard;

@end
