//
// PreviewView.m
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

#import "PreviewView.h"


@implementation PreviewView
@synthesize backgroundColor;

- (id)initWithFrame:(NSRect)frame {

    if(self = [super initWithFrame:frame]){
	[self setBackgroundColor:[NSColor colorWithCalibratedRed:0.867f green:0.891f blue:0.914f alpha:1.0f]];
    }

    return self;
}

- (void)awakeFromNib{

    [[NSNotificationCenter defaultCenter] addObserver:self 
					     selector:@selector(windowKeyChange)
						 name:NSWindowDidResignKeyNotification
					       object:[self window]];

    [[NSNotificationCenter defaultCenter] addObserver:self 
					     selector:@selector(windowKeyChange)
						 name:NSWindowDidBecomeKeyNotification
					       object:[self window]];

}

- (void)dealloc{
    [backgroundColor release];
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
    
    [super drawRect:dirtyRect];

    //draw custom background colour
    [backgroundColor setFill];
    NSRectFill(dirtyRect);

    if(![self inLiveResize]){
	[self positionSubviews];
    }
}

- (void)viewDidEndLiveResize{
    [super viewDidEndLiveResize];
    [self positionSubviews];
}

- (void)positionSubviews{

    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;

    CGFloat imageY = height - 20 - 238;
    [imageCover setFrame:NSMakeRect((width-225)/2, imageY, 225, 238)];

    CGFloat titleH = (0.19 * height) > 150 ? 150 : (0.19 * height);
    CGFloat titleY = imageY - titleH + 20;
    [titleTextField setFrame:NSMakeRect(20, titleY, width - 20-20, titleH)]; 

    CGFloat isbnY = titleY - 8 - 13;
    [isbnTextField setFrame:NSMakeRect(20, isbnY, width - 20-20, 13)];

    CGFloat summaryH = isbnY - 8 - 36;
    [summaryScrollView setFrame:NSMakeRect(20, 36, width - 20-20, summaryH)]; 
}

- (void)windowKeyChange{

    if([[self window] isKeyWindow])
	[self setBackgroundColor:[NSColor colorWithCalibratedRed:0.867f green:0.891f blue:0.914f alpha:1.0f]];
    else
	[self setBackgroundColor:[NSColor controlHighlightColor]];
}

@end
