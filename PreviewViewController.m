//
// PreviewViewController.m
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

#import "PreviewViewController.h"


@implementation PreviewViewController
@synthesize titleString;
@synthesize isbnString;
@synthesize readString;
@synthesize copiesString;
@synthesize summaryString;

//outlets
@synthesize arrayController;
@synthesize imageCover;
@synthesize previewSplitView;
@synthesize previewView;
@synthesize overviewView;
@synthesize previewToggleButton;
@synthesize previewMenuItem;

- (void)awakeFromNib{
    //register as observer for selection changes and object changes
    [arrayController addObserver:self
		      forKeyPath:@"selectedObjects"
			 options:NSKeyValueObservingOptionInitial //send message immediately
			 context:NULL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
					     selector:@selector(managedObjectsDidChange:)
						 name:NSManagedObjectContextObjectsDidChangeNotification
					       object:nil];

    _previewViewWidth = [[NSUserDefaults standardUserDefaults] doubleForKey:@"previewViewWidth"];
    if(_previewViewWidth == 0) 
        [self setPreviewViewWidth:300.0];

    [[previewToggleButton cell] setHighlightsBy:NSPushInCellMask];
    [[previewToggleButton cell] setShowsStateBy:NSContentsCellMask];

    if(previewView.frame.size.width > 0){
	[[previewToggleButton cell] setState:NSOnState];
	[previewMenuItem setState:NSOnState];
    }else{
	[[previewToggleButton cell] setState:NSOffState];
	[previewMenuItem setState:NSOffState];
    }
}

- (void)dealloc{
    [super dealloc];
}

- (void)updateTitleString:(NSString*)titleStr fullTitle:(NSString*)fullTitleStr author:(NSString*)authorStr{

    if(titleStr == nil || fullTitleStr == nil || authorStr == nil)
	return;							    //NSAttributedString does not like nil strings!

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

    if(isbn10 == nil || isbn13 == nil)
	return;

    [self setIsbnString:[NSString stringWithFormat:@"%@\t%@", isbn10, isbn13]];

}

- (void)updateCoverImage:(NSImage*)img{
    [imageCover setImage:img];
}

- (void)updateSummaryString:(NSString*)summaryStr{

    if(summaryStr == nil)
	return;

    NSColor* color = [NSColor colorWithCalibratedRed:0.5f green:0.5f blue:0.5f alpha:1.0f];

    NSFont* font = [NSFont fontWithName:@"Helvetica" size:12.0];

    NSMutableParagraphStyle* paraStyle = [[NSMutableParagraphStyle alloc] init];
    [paraStyle setAlignment:NSJustifiedTextAlignment];

    NSDictionary* summaryAttrib = [NSDictionary dictionaryWithObjectsAndKeys:
							paraStyle, NSParagraphStyleAttributeName,
							font,  NSFontAttributeName,
							color, NSForegroundColorAttributeName, nil];

    NSAttributedString* summary = [[NSAttributedString alloc] initWithString:summaryStr 
								  attributes:summaryAttrib];
    [self setSummaryString:summary];
    [summary release];
    [paraStyle release];
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

- (void)updateComponents{

    if([[arrayController selectedObjects] count] == 1){
	book* selectedBook = [[arrayController selectedObjects] objectAtIndex:0];
	[self updateTitleString:[selectedBook title]
		      fullTitle:[selectedBook titleLong]
			 author:[selectedBook authorText]];
	[self updateISBN10:[selectedBook isbn10] ISBN13:[selectedBook isbn13]];
	[self updateReadStatus:[selectedBook read]];
	[self updateCopiesCount:[[selectedBook noOfCopies] integerValue]];
	[self updateSummaryString:[selectedBook summary]];

	NSImage* img = [selectedBook coverImageImage];
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
	[self updateSummaryString:@""];

    }else if([[arrayController selectedObjects] count] > 1){
	[self updateTitleString:@"Multiple Selection"
		      fullTitle:@""
			 author:@""];
	[self updateISBN10:@"" ISBN13:@""];
	[self updateCoverImage:nil];
	[self updateReadStatus:nil];
	[self updateCopiesCount:-1];
	[self updateSummaryString:@""];
    }
}

- (IBAction)toggleOpenClosePreviewView:(id)sender{

    if(previewView.frame.size.width == 0.0){		//open

	[[previewToggleButton cell] setState:NSOnState];
	[previewMenuItem setState:NSOnState];

	NSRect previewRect = previewView.frame;
	previewRect.size.width = [self previewViewWidth];

	[NSAnimationContext beginGrouping];
	    [[previewView animator] setFrame:previewRect];
	    [[overviewView animator] setFrameSize:NSMakeSize(overviewView.frame.size.width - [self previewViewWidth],
							     overviewView.frame.size.height)];
	[NSAnimationContext endGrouping];

    }else{						//collapse

	[[previewToggleButton cell] setState:NSOffState];
	[previewMenuItem setState:NSOffState];

	NSRect previewRect = previewView.frame;
        [self setPreviewViewWidth:previewRect.size.width];
	previewRect.size.width = 0.0;
	[NSAnimationContext beginGrouping];
	    [[previewView animator] setFrame:previewRect];
	    [[overviewView animator] setFrameSize:NSMakeSize(overviewView.frame.size.width + [self previewViewWidth],
							     overviewView.frame.size.height)];
	[NSAnimationContext endGrouping];
    }

    [previewSplitView adjustSubviews];
}

- (CGFloat)previewViewWidth{
    return _previewViewWidth;
}

- (void)setPreviewViewWidth:(CGFloat)width{
    _previewViewWidth = width;
    [[NSUserDefaults standardUserDefaults] setDouble:width forKey:@"previewViewWidth"];
}

// Delegate methods ////////////////////////////////////////////////////////////

- (void)observeValueForKeyPath:(NSString *)keyPath 
		      ofObject:(id)object 
			change:(NSDictionary *)change 
		       context:(void *)context{

    if([keyPath isEqualToString:@"selectedObjects"]){

	[self updateComponents];
    }
}

- (void)managedObjectsDidChange:(NSNotification*)notification{

    [self updateComponents];
}

@end
