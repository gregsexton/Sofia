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

//TODO: implement image versions
//TODO: call delegate
//TODO: what if delegate/datasource is nil or doesn't implement method?
//TODO: simplify/refactor code(!!) -- reflection as sublayer of bigger layer?
//TODO: vignette
//TODO: maximum width for images (== max height?)
//TODO: book title and subtitle
//TODO: scroll bar
//TODO: drag and drop

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
	_focusedItemIndex = 0;
    }
    return self;
}

- (void)awakeFromNib{

    CGFloat values[4] = {0.0, 0.0, 0.0, 1.0};
    CGColorSpaceRef rgbSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGColorRef black = CGColorCreate(rgbSpace, values);
    
    CALayer *layer = [CALayer layer];
    layer.backgroundColor = black;
    [self setLayer:layer];
    [self setWantsLayer:YES];
    self.layer.layoutManager = self; //take control of layout myself
    CGColorSpaceRelease(rgbSpace);
    CGColorRelease(black);

    [self reloadData];
}

- (void)dealloc{
    if(_cachedLayers)
	[_cachedLayers release];
    if(_cachedReflectionLayers)
	[_cachedReflectionLayers release];
    [super dealloc];
}

- (void)reloadData{
    if([dataSource numberOfItemsInCoverflow:self] > 0){
	[self deleteCachedLayers]; //TODO: use versions!
	_cachedLayers = [[NSMutableArray alloc] initWithCapacity:[dataSource numberOfItemsInCoverflow:self]];
	_cachedReflectionLayers = [[NSMutableArray alloc] initWithCapacity:[dataSource numberOfItemsInCoverflow:self]];

	for(int i=0; i<[dataSource numberOfItemsInCoverflow:self]; i++){

	    GSCoverflowItem* item = [dataSource coverflow:self itemAtIndex:i];
	    CALayer* itemLayer = [self layerForGSCoverflowItem:item];
	    [_cachedLayers addObject:itemLayer];
	    [self.layer addSublayer:itemLayer];

	    CALayer* itemReflectedLayer = [self reflectionLayerForGSCoverflowItem:item];
	    [_cachedReflectionLayers addObject:itemReflectedLayer];
	    [self.layer addSublayer:itemReflectedLayer];
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
    if(_cachedReflectionLayers){
	for(CALayer* layer in _cachedReflectionLayers){
	    [layer removeFromSuperlayer];
	}
	[_cachedReflectionLayers release];
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

- (CALayer*)reflectionLayerForGSCoverflowItem:(GSCoverflowItem*)item{
    CALayer* retLayer = [self layerForGSCoverflowItem:item];
    CALayer* subLayer = [CALayer layer];

    CGFloat values[4] = {0.0, 0.0, 0.0, 0.7};
    CGColorSpaceRef rgbSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGColorRef dark = CGColorCreate(rgbSpace, values);
    subLayer.backgroundColor = dark;

    subLayer.bounds = retLayer.bounds;
    subLayer.anchorPoint = CGPointMake(0.0, 0.0);
    subLayer.position = CGPointMake(0,0);
    subLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable; //autoresize sublayer when super is resized
    [retLayer addSublayer:subLayer];

    CGColorSpaceRelease(rgbSpace);
    CGColorRelease(dark);
    return retLayer;
}

- (void)adjustCachedLayersWithAnimation:(BOOL)animate{
    //"Implicit transactions are created automatically when the
    //layer tree is modified by a thread without an active
    //transaction, and are committed automatically when the
    //thread's run-loop next iterates."
    //
    //seting the global timing here takes effect for all animations
    if(animate){
	[CATransaction setAnimationDuration:1.0f];
	[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.15 :0.8 :0.2 :0.95]];
    }	//else use standard animiation settings

    [self adjustLayerBoundsWithAnimation];
    [self adjustLayerPositionsWithAnimation];
}

- (void)adjustLayerPositionsWithAnimation{
    //NOTE: do not call this method instead call adjustCachedLayersWithAnimation:

    CGFloat newXPosition, newZPosition;
    CGFloat yPosition = self.bounds.size.height * IMAGE_Y_POSITION_SCALE_FACTOR + IMAGE_Y_POSITION_OFFSET;
    CGFloat yDelta = SMALLER_IMAGE_HEIGHT_OFFSET / 2.0;

    //adjust focused layer and reflection
    CALayer* focused = [_cachedLayers objectAtIndex:_focusedItemIndex];
    CALayer* focusedReflected = [_cachedReflectionLayers objectAtIndex:_focusedItemIndex];
    [self moveLayer:focused to:CGPointMake(NSMidX([self bounds]), yPosition)
	 anchoredAt:CGPointMake(0.5,0.0)
	  zPosition:0
	  transform:[self identityTransform]];
    [self moveLayer:focusedReflected to:CGPointMake(NSMidX([self bounds]), yPosition)
	 anchoredAt:CGPointMake(0.5,0.0)
	  zPosition:0
	  transform:[self identityReflectionTransform]];

    CGFloat xDelta = STACKED_IMAGE_SPACING;

    //adjust layers to the left of focused layer and reflections
    newXPosition = NSMidX([self bounds]) - FOCUSED_IMAGE_SPACING;
    newZPosition = -1;
    for(int i=_focusedItemIndex-1; i>=0; i--){
	CALayer* layer = [_cachedLayers objectAtIndex:i];
	CALayer* layerReflected = [_cachedReflectionLayers objectAtIndex:i];

	[self moveLayer:layer to:CGPointMake(newXPosition, yPosition + yDelta)
	     anchoredAt:CGPointMake(0.0,0.0)
	      zPosition:newZPosition
	      transform:[self leftHandImageTransformWithHeight:layer.bounds.size.height 
							 width:layer.bounds.size.width]];

	[self moveLayer:layerReflected to:CGPointMake(newXPosition, yPosition + yDelta)
	     anchoredAt:CGPointMake(0.0,0.0)
	      zPosition:newZPosition
	      transform:[self leftHandReflectionTransformWithHeight:layerReflected.bounds.size.height 
							      width:layerReflected.bounds.size.width]];
	newXPosition -= xDelta;
	newZPosition--;
    }

    //adjust layers to the right of focused layer and reflections
    newXPosition = NSMidX([self bounds]) + FOCUSED_IMAGE_SPACING;
    newZPosition = -1;
    for(int i=_focusedItemIndex+1; i<[_cachedLayers count]; i++){
	CALayer* layer = [_cachedLayers objectAtIndex:i];
	CALayer* layerReflected = [_cachedReflectionLayers objectAtIndex:i];

	[self moveLayer:layer to:CGPointMake(newXPosition, yPosition + yDelta)
	     anchoredAt:CGPointMake(1.0,0.0)
	      zPosition:newZPosition
	      transform:[self rightHandImageTransformWithHeight:layer.bounds.size.height 
							  width:layer.bounds.size.width]];

	[self moveLayer:layerReflected to:CGPointMake(newXPosition, yPosition + yDelta)
	     anchoredAt:CGPointMake(1.0,0.0)
	      zPosition:newZPosition
	      transform:[self rightHandReflectionTransformWithHeight:layerReflected.bounds.size.height 
							       width:layerReflected.bounds.size.width]];
	newXPosition += xDelta;
	newZPosition--;
    }
}

- (void)moveLayer:(CALayer*)layer to:(CGPoint)position
       anchoredAt:(CGPoint)anchor zPosition:(CGFloat)zPos
	transform:(CATransform3D)transform{
    //small helper function to aid readability

    layer.anchorPoint = anchor;
    layer.position = position;
    layer.zPosition = zPos;
    layer.transform = transform;

}

- (void)adjustLayerBoundsWithAnimation{
    //NOTE: do not call this method instead call adjustCachedLayersWithAnimation:

    CGFloat smallerHeight = MAXIMUM_IMAGE_HEIGHT - SMALLER_IMAGE_HEIGHT_OFFSET;

    //adjust all layers
    for(int i=0; i<[_cachedLayers count]; i++){

	CALayer* layer = [_cachedLayers objectAtIndex:i];
	CALayer* layerReflected = [_cachedReflectionLayers objectAtIndex:i];
	layer.bounds = [self scaleRect:layer.bounds toWithinHeight:smallerHeight];
	layerReflected.bounds = [self scaleRect:layerReflected.bounds toWithinHeight:smallerHeight];
	for(CALayer* subLayer in layerReflected.sublayers){ //should only be one sublayer
	    subLayer.bounds = layerReflected.bounds;
	}

    }

    //adjust focused layer
    CALayer* focused = [_cachedLayers objectAtIndex:_focusedItemIndex];
    CALayer* focusedReflected = [_cachedReflectionLayers objectAtIndex:_focusedItemIndex];
    focused.bounds = [self scaleRect:focused.bounds toWithinHeight:MAXIMUM_IMAGE_HEIGHT];
    focusedReflected.bounds = [self scaleRect:focusedReflected.bounds toWithinHeight:MAXIMUM_IMAGE_HEIGHT];
    for(CALayer* subLayer in focusedReflected.sublayers){
	subLayer.bounds = focusedReflected.bounds;
    }
}

- (CGRect)scaleRect:(CGRect)rect toWithinHeight:(CGFloat)height{

    CGRect retRect = CGRectMake(0.0f, 0.0f, (height/rect.size.height) * rect.size.width, height);
    return retRect;
}

///////////////////    TRANSFORM METHODS     /////////////////////////////////////////////////////

- (CATransform3D)leftHandImageTransformWithHeight:(CGFloat)height width:(CGFloat)width{
    CATransform3D transform;
    CGFloat alpha = 0.25;
    CGFloat gamma = (height - (width*tan(alpha)));
    transform.m11 = 1; transform.m12 = tan(alpha)/2; transform.m13 = 0; transform.m14 = ((height/gamma)-1)/width;
    transform.m21 = 0; transform.m22 = 1; transform.m23 = 0; transform.m24 = 0;
    transform.m31 = 0; transform.m32 = 0; transform.m33 = 1; transform.m34 = 0;
    transform.m41 = 0; transform.m42 = 0; transform.m43 = 0; transform.m44 = 1;

    return transform;

}

- (CATransform3D)leftHandReflectionTransformWithHeight:(CGFloat)height width:(CGFloat)width{
    CATransform3D transform = [self leftHandImageTransformWithHeight:height width:width];
    transform.m22 = -1;

    return transform;
}

- (CATransform3D)rightHandImageTransformWithHeight:(CGFloat)height width:(CGFloat)width{
    CATransform3D transform = [self leftHandImageTransformWithHeight:height width:width];
    transform.m12 *= -1;
    transform.m14 *= -1;

    return transform;
}

- (CATransform3D)rightHandReflectionTransformWithHeight:(CGFloat)height width:(CGFloat)width{
    CATransform3D transform = [self rightHandImageTransformWithHeight:height width:width];
    transform.m22 = -1;

    return transform;
}

- (CATransform3D)identityTransform{
    CATransform3D transform;
    transform.m11 = 1; transform.m12 = 0; transform.m13 = 0; transform.m14 = 0;
    transform.m21 = 0; transform.m22 = 1; transform.m23 = 0; transform.m24 = 0;
    transform.m31 = 0; transform.m32 = 0; transform.m33 = 1; transform.m34 = 0;
    transform.m41 = 0; transform.m42 = 0; transform.m43 = 0; transform.m44 = 1;

    return transform;
}

- (CATransform3D)identityReflectionTransform{
    CATransform3D transform = [self identityTransform];
    transform.m22 = -1;

    return transform;
}

///////////////////    EVENT HANDLING METHODS   //////////////////////////////////////////////////

- (NSUInteger)selectionIndex{
    return _focusedItemIndex;
}

- (void)setSelectionIndex:(NSUInteger)index{
    //does nothing if the index is out of bounds
    if([_cachedLayers count] > 0){
	if(index >= 0 && index < [_cachedLayers count]){
	    _focusedItemIndex = index;
	    [self adjustCachedLayersWithAnimation:YES];

	    if([[self delegate] respondsToSelector:@selector(coverflowSelectionDidChange:)])
		[[self delegate] coverflowSelectionDidChange:self];
	}
    }
}

//TODO: handle these events:
//keys left and right
//click scroll bar left or right

- (NSUInteger)itemIndexForLocationInWindow:(NSPoint)eventLocation{
    //returns NSNotFound if location is not in the view or is not a valid item layer
    NSPoint localPoint = [self convertPoint:eventLocation fromView:nil];

    CALayer* clickedLayer = [self.layer hitTest:NSPointToCGPoint(localPoint)];
    if(!clickedLayer)
	return NSNotFound;

    NSUInteger index = [_cachedLayers indexOfObjectIdenticalTo:clickedLayer];
    if(index == NSNotFound)
	return NSNotFound;

    return index;
}

- (void)mouseDown:(NSEvent *)theEvent{
    //handles single and double clicks
    //NSLog(@"Mouse down. \n%@", theEvent);

    NSUInteger index = [self itemIndexForLocationInWindow:[theEvent locationInWindow]];
    if(index == NSNotFound)
	return;

    [self setSelectionIndex:index];

    if([theEvent clickCount] == 2){
	if([[self delegate] respondsToSelector:@selector(coverflow:cellWasDoubleClickedAtIndex:)]){
	    [[self delegate] coverflow:self cellWasDoubleClickedAtIndex:index];
	}
    }

}

- (void)rightMouseDown:(NSEvent *)theEvent{
    //NSLog(@"Right mouse down. \n%@", theEvent);

    NSUInteger index = [self itemIndexForLocationInWindow:[theEvent locationInWindow]];
    if(index == NSNotFound){
	//background right clicked -- inform delegate
	if([[self delegate] respondsToSelector:@selector(coverflow:backgroundWasRightClickedWithEvent:)])
	    [[self delegate] coverflow:self backgroundWasRightClickedWithEvent:theEvent]; 
    }else{
	//item was right clicked -- inform delegate
	if([[self delegate] respondsToSelector:@selector(coverflow:cellWasRightClickedAtIndex:withEvent:)])
	    [[self delegate] coverflow:self cellWasRightClickedAtIndex:index withEvent:theEvent]; 
    }
}

- (void)scrollWheel:(NSEvent *)theEvent{
    //NSLog(@"Scroll wheel. \n%@", theEvent);

    CGFloat scrollByF = [theEvent deltaX] + [theEvent deltaY];
    NSInteger scrollBy = roundf(scrollByF); //implict cast

    [self setSelectionIndex:[self selectionIndex]-scrollBy];
}

- (void)keyDown:(NSEvent *)theEvent{
    NSLog(@"Key down!\n%@", theEvent);
}

- (IBAction)moveOneItemLeft:(id)sender{
    [self setSelectionIndex:[self selectionIndex]-1];
}

- (IBAction)moveOneItemRight:(id)sender{
    [self setSelectionIndex:[self selectionIndex]+1];
}

///////////////////    CALayoutManager Protocol Methods    ///////////////////////////////////////

- (void)invalidateLayoutOfLayer:(CALayer *)layer{
    //TODO: only change stuff if the root layer has been resized!
    [self adjustCachedLayersWithAnimation:NO];
}

@end
