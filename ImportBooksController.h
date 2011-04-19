//
// ImportBooksController.h
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
#import "isbnExtractor.h"
#import "BooksWindowController.h"
#import "ImportBooksControllerDelegate.h"
@class SofiaApplication;

@interface ImportBooksController : NSWindowController <NSTextViewDelegate, BooksWindowControllerDelegate> {

    NSWindow*                         windowToAttachTo;
    NSArray*                          isbns;

    NSPanel*                          importSheet;
    NSTextView*                       contentTextView;
    NSTextField*                      urlTextField;
    NSArrayController*                isbnsController;

    SofiaApplication*                 application;
    NSUInteger                        arrayCounter;
    id<ImportBooksControllerDelegate> delegate;

}
@property (copy) NSArray* isbns;
@property (assign) NSWindow* windowToAttachTo;
@property (assign) id<ImportBooksControllerDelegate>      delegate;
@property (nonatomic, assign) IBOutlet NSPanel*           importSheet;
@property (nonatomic, assign) IBOutlet NSTextView*        contentTextView;
@property (nonatomic, assign) IBOutlet NSTextField*       urlTextField;
@property (nonatomic, assign) IBOutlet NSArrayController* isbnsController;

- (IBAction)addWebsiteAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)importAction:(id)sender;
- (IBAction)clearAction:(id)sender;
- (id)initWithSofiaApplication:(SofiaApplication*)theApplication;
- (void)updateISBNsWithContent:(NSString*)content;
@end
