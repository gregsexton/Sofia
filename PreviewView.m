//
//  PreviewView.m
//  books
//
//  Created by Greg on 06/08/2010.
//  Copyright 2010 Greg Sexton Software. All rights reserved.
//

#import "PreviewView.h"


@implementation PreviewView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    
    //draw custom background colour
    //TODO: change when app loses focus
    [[NSColor colorWithCalibratedRed:0.867f green:0.891f blue:0.914f alpha:1.0f] setFill];
    NSRectFill(dirtyRect);
}

@end
