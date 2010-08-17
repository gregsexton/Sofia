//
// PreviewViewController.h
//
// Copyright 2010 Greg Sexton
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
#import "book.h"


@interface PreviewViewController : NSViewController {

    IBOutlet NSArrayController* arrayController;
    IBOutlet NSImageView* imageCover;

    IBOutlet NSSplitView* previewSplitView;
    IBOutlet NSView* previewView;
    IBOutlet NSView* overviewView;

    IBOutlet NSButton* previewToggleButton;
    IBOutlet NSMenuItem* previewMenuItem;

    NSAttributedString* titleString;
    NSAttributedString* readString;
    NSAttributedString* summaryString;
    NSString* isbnString;
    NSString* copiesString;

    CGFloat _previewViewWidth;
}

@property (nonatomic, assign) NSAttributedString* titleString;
@property (nonatomic, assign) NSAttributedString* readString;
@property (nonatomic, assign) NSAttributedString* summaryString;
@property (nonatomic, assign) NSString* isbnString;
@property (nonatomic, assign) NSString* copiesString;

- (void)updateCopiesCount:(NSInteger)count;
- (void)updateCoverImage:(NSImage*)img;
- (void)updateISBN10:(NSString*)isbn10 ISBN13:(NSString*)isbn13;
- (void)updateReadStatus:(NSNumber*)isRead;
- (void)updateSummaryString:(NSString*)summaryStr;
- (void)updateTitleString:(NSString*)titleStr fullTitle:(NSString*)fullTitleStr author:(NSString*)authorStr;
- (void)managedObjectsDidChange:(NSNotification*)notification;
- (IBAction)toggleOpenClosePreviewView:(id)sender;

@end
