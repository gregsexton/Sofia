//
// ReflectionImageView.m
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

#import "ReflectionImageView.h"


@implementation ReflectionImageView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {

    CGFloat height = self.bounds.size.height;
    CGFloat width = self.bounds.size.width;

    NSRect imageRect = NSMakeRect(0, height/3, width, height*2/3);
    NSRect reflectionRect = NSMakeRect(0, 0, width, height*2/3);

    NSRect scaledRect = [self getScaledRectFrom:imageRect using:[[self image] size]];
    [[self image] drawInRect:scaledRect
		    fromRect:NSZeroRect 
		   operation:NSCompositeCopy 
		    fraction:1.0];

    [self drawReflectionInRect:reflectionRect translateY:-(height/3)];

}

- (void)drawReflectionInRect:(NSRect)rect translateY:(CGFloat)yTranslation{
    //translateY necessary as changing the rect.origin screws up the contexts
    //manually translate instead

    //Create a grayscale context for the mask
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceGray();
    CGContextRef maskContext = CGBitmapContextCreate(NULL,
						     rect.size.width,
						     rect.size.height,
						     8,
						     rect.size.width,
						     colorspace,
						     0);
    CGColorSpaceRelease(colorspace);
    CGContextTranslateCTM(maskContext, 0, yTranslation);

    //Switch to the mask for drawing
    NSGraphicsContext *maskGraphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:maskContext 
											flipped:NO];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:maskGraphicsContext];

    //Draw mask
    [[NSColor blackColor] setFill];
    CGContextFillRect(maskContext, NSRectToCGRect(rect));
    [self drawGradientInContext:maskContext withHeight:rect.size.height];

    //Switch back to the window's context
    [NSGraphicsContext restoreGraphicsState];

    //Create an image mask from what we've drawn into mask context
    CGImageRef alphaMask = CGBitmapContextCreateImage(maskContext);
    
    //Draw a transparent background in the view
    CGContextRef viewContext = [[NSGraphicsContext currentContext] graphicsPort];
    [[NSColor colorWithCalibratedRed:0 green:0 blue:0. alpha:0.0f] setFill];
    CGContextFillRect(viewContext, NSRectToCGRect(rect));

    //Draw the image, clipped by the mask
    CGContextSaveGState(viewContext);
    CGContextClipToMask(viewContext, NSRectToCGRect(rect), alphaMask);
    //Draw the image, flipped vertically
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, rect.size.height);
    CGContextTranslateCTM(viewContext, 0, yTranslation);
    CGContextConcatCTM(viewContext, flipVertical);

    //draw proportional image
    NSRect scaledRect = [self getScaledRectFrom:rect using:[[self image] size]];
    [[self image] drawInRect:scaledRect
		    fromRect:NSZeroRect 
		   operation:NSCompositeCopy 
		    fraction:1.0];

    //darken image
    [[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.2f] setFill];
    CGContextFillRect(viewContext, NSRectToCGRect(scaledRect));

    CGContextRestoreGState(viewContext);

    CGImageRelease(alphaMask);
    CGContextRelease(maskContext);
}

- (void)drawGradientInContext:(CGContextRef)context withHeight:(CGFloat)height{

    CGGradientRef gradient;
    CGColorSpaceRef colorspace;

    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 0.4, 1.0,   // Start color
			      0.0, 1.0 }; // End color
     
    colorspace = CGColorSpaceCreateDeviceGray();
    gradient = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    CGColorSpaceRelease(colorspace);
    
    CGPoint startPoint, endPoint;
    startPoint.x = 0.0;
    startPoint.y = height;
    endPoint.x = 0.0;
    endPoint.y = height*2/3;
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient);
}

- (NSRect)getScaledRectFrom:(NSRect)srcRect using:(NSSize)size{
    NSRect retRect = srcRect;
    float scaleFactor = retRect.size.height / size.height;
    retRect.size.width = size.width * scaleFactor;

    retRect.origin.x = (srcRect.size.width - retRect.size.width)/2;

    return retRect;
    
}
@end
