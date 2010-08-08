//
//  ReflectionImageView.h
//  books
//
//  Created by Greg on 07/08/2010.
//  Copyright 2010 Greg Sexton Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ReflectionImageView : NSImageView {

}

- (void)drawGradientInContext:(CGContextRef)context;
- (NSRect)getScaledRectFrom:(NSRect)srcRect using:(NSSize)size;

@end
