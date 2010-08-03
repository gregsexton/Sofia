//
// VerticallyCenteredTextField.m
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

#import "VerticallyCenteredTextField.h"


@implementation VerticallyCenteredTextField

- (NSRect)titleRectForBounds:(NSRect)theRect {
    NSRect titleFrame = [super titleRectForBounds:theRect];
    NSSize titleSize = [[self attributedStringValue] size];

    int noOfWrappedLines = ceil(titleSize.width / titleFrame.size.width);

    titleFrame.origin.y = theRect.origin.y - .5 + (theRect.size.height - titleSize.height * noOfWrappedLines) / 2.0;
    return titleFrame;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView{
    //draw the background TODO: this should probably use the cells background color rather than a hardcoded value!
    [[NSColor colorWithCalibratedRed:1.0f green:0.74f blue:0.74f alpha:1.0f] set];
    NSRectFill(cellFrame);

    NSRect titleRect = [self titleRectForBounds:cellFrame];
    [[self attributedStringValue] drawInRect:titleRect];
}

@end
