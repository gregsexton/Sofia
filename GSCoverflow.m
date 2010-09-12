//
// GSCoverflow.m
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

#import "GSCoverflow.h"


@implementation GSCoverflow
@synthesize delegate;
@synthesize dataSource;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib{

    CGFloat values[4] = {0.0, 0.0, 0.0, 1.0};
    CGColorRef black = CGColorCreate(CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB), values);
    
    CALayer *layer = [CALayer layer];
    layer.backgroundColor = black;
    [self setLayer:layer];
    [self setWantsLayer:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
}

- (void)reloadData{
    if([dataSource numberOfItemsInCoverflow:self] > 0){
	GSCoverflowItem* item = [dataSource coverflow:self itemAtIndex:0];
	NSLog(@"%@", item.imageTitle);
	CALayer* first = [self layerForGSCoverflowItem:item];
	[self.layer addSublayer:first];

	item = [dataSource coverflow:self itemAtIndex:1];
	NSLog(@"%@", item.imageTitle);
	CALayer* second = [self layerForGSCoverflowItem:item];
	second.position = CGPointMake(self.bounds.origin.x+140.0f, self.bounds.origin.y+105.0f);
	[self.layer addSublayer:second];
    }
}

- (CALayer*)layerForGSCoverflowItem:(GSCoverflowItem*)item{
    CALayer* retLayer = [CALayer layer];
    retLayer.contents = (id)item.imageRepresentation;
    retLayer.bounds = CGRectMake(0.0f, 0.0f, 280.0f, 210.0f);
    retLayer.position = CGPointMake(NSMidX([self bounds]), NSMidY([self bounds]));
    return retLayer;
}    

@end
