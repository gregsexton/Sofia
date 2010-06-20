//
//  BooksWindowControllerDelegate.h
//  books
//
//  Created by Greg on 20/06/2010.
//  Copyright 2010 Greg Sexton Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class BooksWindowController;


@protocol BooksWindowControllerDelegate

@optional

- (void) saveClicked:(BooksWindowController*)booksWindowController;
- (void) cancelClicked:(BooksWindowController*)booksWindowController;

@end
