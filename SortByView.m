//
// SortByView.m
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

#import "SortByView.h"


@implementation SortByView

//this subclassed view is (currently) only used to customize the background drawing
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor colorWithCalibratedRed:0.90f green:0.90f blue:0.90f alpha:1.0f] setFill];
    NSRectFill(dirtyRect);

    NSRect bottomBorder = NSMakeRect(0,0,self.bounds.size.width,1);
    [[NSColor lightGrayColor] setFill];
    NSRectFill(bottomBorder);
}

@end
