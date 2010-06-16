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

    NSWindow* windowToAttachTo;
    NSArray* isbns;

    IBOutlet NSPanel*	    importSheet;
    IBOutlet NSTextView*    contentTextView;
    IBOutlet NSTextField*   urlTextField;

}
@property (copy) NSArray* isbns;
@property (assign) NSWindow* windowToAttachTo;

- (IBAction)addWebsiteAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)importAction:(id)sender;
- (IBAction)clearAction:(id)sender;
@end