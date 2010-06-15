//
//  ImportBooksController.h
//  books
//
//  Created by Greg on 14/06/2010.
//  Copyright 2010 Greg Sexton Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "isbnExtractor.h"

@interface ImportBooksController : NSWindowController <NSTextViewDelegate> {

    NSArray* isbns;
    IBOutlet NSTextView* contentTextView;
    IBOutlet NSTextField* urlTextField;

}
@property (copy) NSArray* isbns;

- (IBAction)addWebsiteAction:(id)sender;
@end
