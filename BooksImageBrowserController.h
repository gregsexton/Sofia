//
//  BooksImageBrowserController.h
//  books
//
//  Created by Greg on 09/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Quartz/Quartz.h>
#import <Cocoa/Cocoa.h>
#import "book.h"
#import "BooksWindowController.h"
#import "BooksImageBrowserView.h"


@interface BooksImageBrowserController : NSViewController {

    IBOutlet NSArrayController *arrayController;
    IBOutlet BooksImageBrowserView* browserView;

}

@end
