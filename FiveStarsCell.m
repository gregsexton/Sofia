//
// FiveStarsCell.m
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

#import "FiveStarsCell.h"


@implementation FiveStarsCell

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView{
    CGFloat height = cellFrame.size.height;
    CGFloat width = cellFrame.size.width;
    CGFloat x = cellFrame.origin.x;
    CGFloat y = cellFrame.origin.y;

    //draw background
/*    [[NSColor whiteColor] set];*/
/*    NSRectFill(cellFrame);*/

    //draw mask (65x12)
    NSImage* img = [NSImage imageNamed:@"stars"];
    CGFloat imgWidth = img.size.width;
    CGFloat imgHeight = img.size.height;
    NSRect imgRect = NSMakeRect((width-imgWidth)/2.0f, (height-imgHeight)/2.0f, imgWidth, imgHeight);

    //Create a grayscale context for the mask
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceGray();
    CGContextRef maskContext = CGBitmapContextCreate(NULL,
						     cellFrame.size.width,
						     cellFrame.size.height,
						     8,
						     cellFrame.size.width,
						     colorspace,
						     0);
    CGColorSpaceRelease(colorspace);

    //Switch to the mask for drawing
    NSGraphicsContext* maskGraphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:maskContext 
											flipped:[controlView isFlipped]];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:maskGraphicsContext];

    //Draw mask
    [[NSColor blackColor] set];
    NSRectFill(NSMakeRect(0,0,width,height));
    [img drawInRect:imgRect fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0 respectFlipped:[controlView isFlipped] hints:nil];

    //Switch back to the window's context
    [NSGraphicsContext restoreGraphicsState];

    //Create an image mask from what we've drawn into mask context
    CGImageRef alphaMask = CGBitmapContextCreateImage(maskContext);
    CGContextRef viewContext = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSaveGState(viewContext);
    CGContextClipToMask(viewContext, NSRectToCGRect(cellFrame), alphaMask);

    //draw tint clipped by mask
    NSRect tintRect = imgRect;
    tintRect.origin.x += x;
    tintRect.origin.y += y;

    tintRect.size.width = tintRect.size.width/5 * [[self objectValue] doubleValue]; //[self objectValue] should be NSNumber
    [[NSColor colorWithCalibratedRed:1.0f green:0.47f blue:0.0f alpha:1.0f] setFill];
    CGContextFillRect(viewContext, NSRectToCGRect(tintRect));

    //draw the rest in black
    tintRect.origin.x += tintRect.size.width;
    tintRect.size.width = imgWidth - tintRect.size.width;
    [[NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:0.5f] setFill];
    CGContextFillRect(viewContext, NSRectToCGRect(tintRect));

    CGContextRestoreGState(viewContext);

    CGImageRelease(alphaMask);
    CGContextRelease(maskContext);
}

@end
