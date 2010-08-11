//
//  PreviewViewController.h
//  books
//
//  Created by Greg on 07/08/2010.
//  Copyright 2010 Greg Sexton Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "book.h"


@interface PreviewViewController : NSViewController {

    IBOutlet NSArrayController* arrayController;
    IBOutlet NSImageView* imageCover;
    IBOutlet NSImageView* imageCoverReflection;

    NSAttributedString* titleString;
    NSAttributedString* readString;
    NSString* isbnString;
    NSString* copiesString;
}

@property (nonatomic, retain) NSAttributedString* titleString;
@property (nonatomic, retain) NSAttributedString* readString;
@property (nonatomic, retain) NSString* isbnString;
@property (nonatomic, retain) NSString* copiesString;

- (void)updateCopiesCount:(NSInteger)count;
- (void)updateCoverImage:(NSImage*)img;
- (void)updateISBN10:(NSString*)isbn10 ISBN13:(NSString*)isbn13;
- (void)updateReadStatus:(NSNumber*)isRead;
- (void)updateTitleString:(NSString*)titleStr fullTitle:(NSString*)fullTitleStr author:(NSString*)authorStr;

@end
