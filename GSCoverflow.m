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

//TODO: handle resizing
//TODO: implement image versions
//TODO: call delegate
//TODO: what if delegate/datasource is nil or doesn't implement method?

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
	_focusedItemIndex = 0;
	_maximumImageHeight = ((frame.size.height/5)*4) - 50;
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

    [self reloadData];
}

- (void)dealloc{
    if(_cachedLayers)
	[_cachedLayers release];
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
    //NOTE: layer hosting view. Do not do any custom drawing here.
    //Instead, draw to the view's layer hierarchy.
    [self adjustCachedLayersWithAnimation:NO];
}

- (void)reloadData{
    if([dataSource numberOfItemsInCoverflow:self] > 0){
	[self deleteCachedLayers]; //TODO: use versions!
	_cachedLayers = [[NSMutableArray alloc] initWithCapacity:[dataSource numberOfItemsInCoverflow:self]];

	for(int i=0; i<[dataSource numberOfItemsInCoverflow:self]; i++){

	    GSCoverflowItem* item = [dataSource coverflow:self itemAtIndex:i];
	    CALayer* itemLayer = [self layerForGSCoverflowItem:item];
	    [_cachedLayers addObject:itemLayer];
	    [self.layer addSublayer:itemLayer];

	}

	[self adjustCachedLayersWithAnimation:NO];
    }
}

- (void)deleteCachedLayers{
    if(_cachedLayers){
	for(CALayer* layer in _cachedLayers){
	    [layer removeFromSuperlayer];
	}
	[_cachedLayers release];
    }
}


- (CALayer*)layerForGSCoverflowItem:(GSCoverflowItem*)item{
    CALayer* retLayer = [CALayer layer];
    retLayer.contents = (id)item.imageRepresentation;
    retLayer.bounds = CGRectMake(0.0f, 0.0f,
				CGImageGetWidth(item.imageRepresentation), 
				CGImageGetHeight(item.imageRepresentation));
    return retLayer;
}    

- (void)adjustCachedLayersWithAnimation:(BOOL)animate{
    [self adjustLayerBoundsWithAnimation:animate];
    [self adjustLayerPositionsWithAnimation:animate];
}

- (void)adjustLayerPositionsWithAnimation:(BOOL)animate{
    //NOTE: do not call this method instead call adjustCachedLayersWithAnimation:

    CGFloat newXPosition, newZPosition;
    CGFloat yPosition = self.bounds.size.height / 5;
    CGFloat yDelta = _maximumImageHeight / 20;

    //adjust focused layer
    CALayer* focused = [_cachedLayers objectAtIndex:_focusedItemIndex];
    focused.anchorPoint = CGPointMake(0.5,0.0);
    focused.position = CGPointMake(NSMidX([self bounds]), yPosition);
    focused.zPosition = 0;

    CGFloat xDelta = 70;

    //adjust layers to the left of focused layer
    newXPosition = NSMidX([self bounds]) - (focused.bounds.size.width*1.25);
    newZPosition = -1;
    for(int i=_focusedItemIndex-1; i>=0; i--){
	CALayer* layer = [_cachedLayers objectAtIndex:i];
	layer.anchorPoint = CGPointMake(0.0,0.0);
	layer.position = CGPointMake(newXPosition, yPosition + yDelta);
	layer.zPosition = newZPosition;
	newXPosition -= xDelta;
	newZPosition--;
    }

    //adjust layers to the right of focused layer
    newXPosition = NSMidX([self bounds]) + (focused.bounds.size.width*1.25);
    newZPosition = -1;
    for(int i=_focusedItemIndex+1; i<[_cachedLayers count]; i++){
	CALayer* layer = [_cachedLayers objectAtIndex:i];
	layer.anchorPoint = CGPointMake(1.0,0.0);
	layer.position = CGPointMake(newXPosition, yPosition + yDelta);
	layer.zPosition = newZPosition;
	newXPosition += xDelta;
	newZPosition--;
    }
}

- (void)adjustLayerBoundsWithAnimation:(BOOL)animate{
    //NOTE: do not call this method instead call adjustCachedLayersWithAnimation:

    CGFloat smallerHeight = _maximumImageHeight - (_maximumImageHeight/10);

    //adjust all layers
    for(int i=0; i<[_cachedLayers count]; i++){

	CALayer* layer = [_cachedLayers objectAtIndex:i];
	layer.bounds = [self scaleRect:layer.bounds toWithinHeight:smallerHeight];
    }

    //adjust focused layer
    CALayer* focused = [_cachedLayers objectAtIndex:_focusedItemIndex];
    focused.bounds = [self scaleRect:focused.bounds toWithinHeight:_maximumImageHeight];

}

- (CGRect)scaleRect:(CGRect)rect toWithinHeight:(CGFloat)height{

    CGRect retRect = CGRectMake(0.0f, 0.0f, (height/rect.size.height) * rect.size.width, height);
    return retRect;
}

///////////////////    EVENT HANDLING METHODS   //////////////////////////////////////////////////

- (void)keyDown:(NSEvent *)theEvent{
    NSLog(@"Key down!");
}

- (IBAction)moveOneItemLeft:(id)sender{
    if(_focusedItemIndex > 0){
	_focusedItemIndex--;
	[self adjustCachedLayersWithAnimation:YES];
    }
}

- (IBAction)moveOneItemRight:(id)sender{
    if(_focusedItemIndex < [_cachedLayers count]-1){
	_focusedItemIndex++;
	[self adjustCachedLayersWithAnimation:YES];
    }
}

@end
