//
//  PreviewViewController.m
//  books
//
//  Created by Greg on 07/08/2010.
//  Copyright 2010 Greg Sexton Software. All rights reserved.
//

#import "PreviewViewController.h"


@implementation PreviewViewController
@synthesize titleString;
@synthesize isbnString;
@synthesize readString;
@synthesize copiesString;

//TODO: download of summary missing paragraphs this may be applicable generally
//TODO: elipsis at end of summary apply this to bookwindow also
//TODO: change to selected book reflected

- (void)awakeFromNib{
    //register as observer
    [arrayController addObserver:self
		      forKeyPath:@"selectedObjects"
			 options:NSKeyValueObservingOptionInitial //send message immediately
			 context:NULL];
}

- (void)dealloc{
    [super dealloc];
    [titleString release];
    [isbnString release];
    [readString release];
    [copiesString release];
}

- (void)updateTitleString:(NSString*)titleStr fullTitle:(NSString*)fullTitleStr author:(NSString*)authorStr{

    NSColor* color = [NSColor colorWithCalibratedRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
    NSFont* font = [NSFont fontWithName:@"Helvetica-Bold" size:18.0];
    NSDictionary* titleAttrib = [NSDictionary dictionaryWithObjectsAndKeys:
							font,  NSFontAttributeName,
							color, NSForegroundColorAttributeName, nil];

    color = [NSColor colorWithCalibratedRed:0.5f green:0.5f blue:0.5f alpha:1.0f];
    font = [NSFont fontWithName:@"Helvetica-Bold" size:11.0];
    NSDictionary* fulltitleAttrib = [NSDictionary dictionaryWithObjectsAndKeys:
							font,  NSFontAttributeName,
							color, NSForegroundColorAttributeName, nil];

    color = [NSColor colorWithCalibratedRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
    font = [NSFont fontWithName:@"Helvetica-Bold" size:13.0];
    NSDictionary* authorAttrib = [NSDictionary dictionaryWithObjectsAndKeys:
							font,  NSFontAttributeName,
							color, NSForegroundColorAttributeName, nil];
    
    NSAttributedString* title = [[NSAttributedString alloc] initWithString:titleStr
								attributes:titleAttrib];

    NSAttributedString* fullTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@", fullTitleStr]
								    attributes:fulltitleAttrib];

    NSAttributedString* author = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@", authorStr] 
								 attributes:authorAttrib];

    NSMutableAttributedString* finalString = [[NSMutableAttributedString alloc] initWithAttributedString:title];
    [finalString appendAttributedString:fullTitle];
    [finalString appendAttributedString:author];

    NSMutableParagraphStyle* paraStyle = [[NSMutableParagraphStyle alloc] init];
    [paraStyle setAlignment:NSCenterTextAlignment];
    [paraStyle setLineSpacing:1.5f];
    [finalString addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, [[finalString string] length])];

    [self setTitleString:finalString];

    [title release];
    [fullTitle release];
    [author release];
    [paraStyle release];
    [finalString release];
}

- (void)updateISBN10:(NSString*)isbn10 ISBN13:(NSString*)isbn13{

    [self setIsbnString:[NSString stringWithFormat:@"%@\t%@", isbn10, isbn13]];

}

- (void)updateCoverImage:(NSImage*)img{
    [imageCover setImage:img];
    [imageCoverReflection setImage:img];
}

- (void)updateReadStatus:(NSNumber*)isRead{
    //isRead acts as a nullable bool

    NSAttributedString* read = nil;
    NSColor* color = nil;

    if(isRead == nil){
	read = [[NSAttributedString alloc] initWithString:@""];
	[self setReadString:read];
	[read release];
	return;
    }

    NSMutableParagraphStyle* paraStyle = [[NSMutableParagraphStyle alloc] init];
    [paraStyle setAlignment:NSRightTextAlignment];

    if([isRead boolValue])
	color = [NSColor colorWithCalibratedRed:0.0f green:0.5f blue:0.0f alpha:1.0f];
    else
	color = [NSColor colorWithCalibratedRed:0.7f green:0.0f blue:0.0f alpha:1.0f];

    NSDictionary* attrib = [NSDictionary dictionaryWithObjectsAndKeys:
					    paraStyle, NSParagraphStyleAttributeName,
					    color, NSForegroundColorAttributeName, nil];
    if([isRead boolValue])
	read = [[NSAttributedString alloc] initWithString:@"Read" attributes:attrib];
    else
	read = [[NSAttributedString alloc] initWithString:@"Unread" attributes:attrib];

    [self setReadString:read];
    [read release];
    [paraStyle release];
}

- (void)updateCopiesCount:(NSInteger)count{

    NSString* retString = nil;

    if(count == 0)
	retString = @"No copies owned";
    else if(count == 1)
	retString = @"1 copy owned";
    else if(count > 1)
	retString = [NSString stringWithFormat:@"%d copies owned", count];
    else
	retString = @"";

    [self setCopiesString:retString];
}


// Delegate methods ////////////////////////////////////////////////////////////

- (void)observeValueForKeyPath:(NSString *)keyPath 
		      ofObject:(id)object 
			change:(NSDictionary *)change 
		       context:(void *)context{

    if([keyPath isEqualToString:@"selectedObjects"]){

	if([[arrayController selectedObjects] count] == 1){
	    book* selectedBook = [[arrayController selectedObjects] objectAtIndex:0];
	    [self updateTitleString:[selectedBook title]
			  fullTitle:[selectedBook titleLong]
			     author:[selectedBook authorText]];
	    [self updateISBN10:[selectedBook isbn10] ISBN13:[selectedBook isbn13]];
	    [self updateReadStatus:[selectedBook read]];
	    [self updateCopiesCount:[[selectedBook noOfCopies] integerValue]];

	    NSImage* img = [selectedBook coverImage];
	    if(img == nil)
		img = [NSImage imageNamed:@"missing.png"];
	    [self updateCoverImage:img];

	}else if([[arrayController selectedObjects] count] == 0){
	    [self updateTitleString:@"No Selection"
			  fullTitle:@""
			     author:@""];
	    [self updateISBN10:@"" ISBN13:@""];
	    [self updateCoverImage:nil];
	    [self updateReadStatus:nil];
	    [self updateCopiesCount:-1];

	}else if([[arrayController selectedObjects] count] > 1){
	    [self updateTitleString:@"Multiple Selection"
			  fullTitle:@""
			     author:@""];
	    [self updateISBN10:@"" ISBN13:@""];
	    [self updateCoverImage:nil];
	    [self updateReadStatus:nil];
	    [self updateCopiesCount:-1];
	}

	return;
    }
}

@end
