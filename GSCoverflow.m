//
// GSCoverflow.m
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

#import "GSCoverflow.h"


@implementation GSCoverflow
@synthesize delegate;
@synthesize dataSource;

//TODO: implement image versions -- when this is done, changing the image in the detail window
//                                  will require the controller to force an update of the version

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
	_focusedItemIndex = 0;
	//these get created when they are first updated
	_titleLayer = nil;
	_scrollLayer = nil;
	_bubbleDragged = NO;
	_focusedDragged = NO;
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

    [self.layer addSublayer:[self leftFadeLayer]];
    [self.layer addSublayer:[self rightFadeLayer]];

    [self reloadData];
}

- (void)dealloc{
    [self deleteCache];
    if(_scrollLayer)
	[_scrollLayer release];
    if(_titleLayer)
	[_titleLayer release];

    if(_leftFadeLayer)
        [_leftFadeLayer release];
    if(_rightFadeLayer)
        [_rightFadeLayer release];

    [super dealloc];
}

- (void)reloadData{
    [self deleteCache]; //TODO: use versions!

    if(dataSource != nil && [dataSource numberOfItemsInCoverflow:self] > 0){
	_cachedLayers           = [[NSMutableArray alloc] initWithCapacity:[dataSource numberOfItemsInCoverflow:self]];
	_cachedReflectionLayers = [[NSMutableArray alloc] initWithCapacity:[dataSource numberOfItemsInCoverflow:self]];
	_cachedTitles           = [[NSMutableArray alloc] initWithCapacity:[dataSource numberOfItemsInCoverflow:self]];
	_cachedSubtitles        = [[NSMutableArray alloc] initWithCapacity:[dataSource numberOfItemsInCoverflow:self]];

	if(_focusedItemIndex >= [dataSource numberOfItemsInCoverflow:self]) //don't let this exceed the array bounds
	    _focusedItemIndex = [dataSource numberOfItemsInCoverflow:self] - 1;

	for(int i=0; i<[dataSource numberOfItemsInCoverflow:self]; i++){

	    GSCoverflowItem* item = [dataSource coverflow:self itemAtIndex:i];
	    CALayer* itemLayer = [self layerForGSCoverflowItem:item];
	    [_cachedLayers addObject:itemLayer];

	    CALayer* itemReflectedLayer = [self reflectionLayerForGSCoverflowItem:item];
	    [_cachedReflectionLayers addObject:itemReflectedLayer];

	    if(item.imageTitle)
		[_cachedTitles addObject:item.imageTitle];
	    else
		[_cachedTitles addObject:@""];

	    if(item.imageSubtitle)
		[_cachedSubtitles addObject:item.imageSubtitle];
	    else
		[_cachedSubtitles addObject:@""];

            //these need to be last as calling addSublayer invokes invalidateLayoutOfLayer
            //which in turn requires that caches are fully built
	    [self.layer addSublayer:itemLayer];
	    [self.layer addSublayer:itemReflectedLayer];
	}
    }

    [self adjustCachedLayersWithAnimation:NO];
}

- (void)deleteCache{
    if(_cachedLayers){
	for(CALayer* layer in _cachedLayers){
	    [layer removeFromSuperlayer];
	}
	[_cachedLayers release];
	_cachedLayers = nil;
    }
    if(_cachedReflectionLayers){
	for(CALayer* layer in _cachedReflectionLayers){
	    [layer removeFromSuperlayer];
	}
	[_cachedReflectionLayers release];
	_cachedReflectionLayers = nil;
    }
    if(_cachedTitles){
	[_cachedTitles release];
	_cachedTitles = nil;
    }
    if(_cachedSubtitles){
	[_cachedSubtitles release];
	_cachedSubtitles = nil;
    }
}

- (CALayer*)layerForGSCoverflowItem:(GSCoverflowItem*)item{
    CALayer* retLayer = [CALayer layer];
    retLayer.bounds = CGRectMake(0.0f, 0.0f,
				CGImageGetWidth(item.imageRepresentation),
				CGImageGetHeight(item.imageRepresentation));

    CGColorSpaceRef rgbSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);

    CGFloat tValues[4] = {0.2, 0.2, 0.2, 1.0};
    CGColorRef grey = CGColorCreate(rgbSpace, tValues);
    retLayer.backgroundColor = grey;

    CGColorSpaceRelease(rgbSpace);
    CGColorRelease(grey);

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

- (GSNoHitGradientLayer*)fadeLayer{
    GSNoHitGradientLayer* fadeLayer = [[GSNoHitGradientLayer alloc] init];
    fadeLayer.anchorPoint = CGPointMake(0.0,0.0);

    CGColorSpaceRef rgbSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);

    CGFloat tValues[4] = {0.0, 0.0, 0.0, 0.0};
    CGColorRef transparent = CGColorCreate(rgbSpace, tValues);

    CGFloat oValues[4] = {0.0, 0.0, 0.0, 0.9};
    CGColorRef opaque = CGColorCreate(rgbSpace, oValues);

    NSArray* colors = [NSArray arrayWithObjects:(id)transparent,(id)opaque,nil];
    CGColorSpaceRelease(rgbSpace);
    CGColorRelease(transparent);
    CGColorRelease(opaque);

    fadeLayer.colors = colors;

    return [fadeLayer autorelease];
}

- (GSNoHitGradientLayer*)leftFadeLayer{
    if(!_leftFadeLayer){
        _leftFadeLayer = [[self fadeLayer] retain];
        [self adjustLeftFadeLayer];
    }
    return _leftFadeLayer;
}

- (GSNoHitGradientLayer*)rightFadeLayer{
    if(!_rightFadeLayer){
        _rightFadeLayer            = [[self fadeLayer] retain];
        [self adjustRightFadeLayer];
    }
    return _rightFadeLayer;
}

- (void)adjustLeftFadeLayer{
    _rightFadeLayer.bounds = CGRectMake(0, 0,
                                        self.bounds.size.width/2.0,
                                        self.bounds.size.height);
    _rightFadeLayer.position   = CGPointMake(0, 0);
    _rightFadeLayer.startPoint = CGPointMake(1.0,0.5);
    _rightFadeLayer.endPoint   = CGPointMake(0.0,0.5);
}

- (void)adjustRightFadeLayer{
    CGFloat scrollBarWidth = 15.0;
    _leftFadeLayer.bounds = CGRectMake(0, 0,
                                       self.bounds.size.width/2.0 + scrollBarWidth,
                                       self.bounds.size.height);
    _leftFadeLayer.position   = CGPointMake(self.bounds.size.width/2.0, 0);
    _leftFadeLayer.startPoint = CGPointMake(0.0,0.5);
    _leftFadeLayer.endPoint   = CGPointMake(1.0,0.5);
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
    }	//else use standard animation settings

    [self adjustLayerBounds];
    [self adjustLayerPositions];
    [self updateTitleLayer];
    [self updateScrollLayer];

    [self adjustLeftFadeLayer];
    [self adjustRightFadeLayer];

    [self addContentsToVisibleLayers]; //also removes contents from invisible layers.
}

- (void)updateTitleLayer{
    //NOTE: do not call this method instead call adjustCachedLayersWithAnimation:
    if(!_titleLayer){ //create title layer if necessary

	CGFloat values[4] = {1.0, 1.0, 1.0, 1.0};
	CGColorSpaceRef rgbSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	CGColorRef white = CGColorCreate(rgbSpace, values);

	_titleLayer = [[CATextLayer layer] retain];
	_titleLayer.anchorPoint = CGPointMake(0.5,0.5);
	_titleLayer.zPosition = 100;
	_titleLayer.foregroundColor = white;
	_titleLayer.font = [NSFont fontWithName:@"LucidaGrande-Bold" size:12.0];
	_titleLayer.fontSize = 12.0f;
	_titleLayer.alignmentMode = kCAAlignmentCenter;

	//disable animating the properties of the layer.
	NSMutableDictionary *actions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
					   [NSNull null], @"onOrderIn",
					   [NSNull null], @"onOrderOut",
					   [NSNull null], @"contents",
					   [NSNull null], @"position",
					   [NSNull null], @"bounds", nil];
	_titleLayer.actions = actions;
	[actions release];

	CGColorSpaceRelease(rgbSpace);
	CGColorRelease(white);
    }
    if(!_titleLayer.superlayer){
	[self.layer addSublayer:_titleLayer];
    }


    _titleLayer.string = [NSString stringWithFormat:@"%@\n%@",
			   [_cachedTitles objectAtIndex:_focusedItemIndex]?  [_cachedTitles objectAtIndex:_focusedItemIndex]:@"",
			   [_cachedSubtitles objectAtIndex:_focusedItemIndex]? [_cachedSubtitles objectAtIndex:_focusedItemIndex]:@""];
    CGSize preferredSize = [_titleLayer preferredFrameSize];
    //ensure that text sits on a pixel boundary otherwise it will blur
    preferredSize.width = [self isEven:preferredSize.width] ? preferredSize.width : preferredSize.width + 1;
    preferredSize.height = [self isEven:preferredSize.height] ? preferredSize.height : preferredSize.height + 1;

    _titleLayer.frame = CGRectMake(0.0f, 0.0f, round(preferredSize.width), round(preferredSize.height));
    _titleLayer.position = CGPointMake(round(NSMidX([self bounds])), round(TITLE_Y_POSITION));
}

- (void)updateScrollLayer{
    //NOTE: do not call this method instead call adjustCachedLayersWithAnimation:

    if(!_scrollLayer){
	CGFloat lightValues[4] = {1.0, 1.0, 1.0, 0.2};
	CGFloat whiteValues[4] = {1.0, 1.0, 1.0, 1.0};
	CGFloat blackValues[4] = {0.0, 0.0, 0.0, 1.0};
	CGColorSpaceRef rgbSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	CGColorRef light = CGColorCreate(rgbSpace, lightValues);
	CGColorRef black = CGColorCreate(rgbSpace, blackValues);
	CGColorRef white = CGColorCreate(rgbSpace, whiteValues);

	_scrollLayer = [[CALayer layer] retain];
	_scrollLayer.anchorPoint = CGPointMake(0.5, 0.5);
	_scrollLayer.zPosition = 100;
	_scrollLayer.cornerRadius = SCROLLBAR_HEIGHT/2.0;
	_scrollLayer.backgroundColor = light;
	_scrollLayer.borderColor = white;
	_scrollLayer.borderWidth = 0.5;

	CALayer* scrollBubble = [CALayer layer];
	scrollBubble.anchorPoint = CGPointMake(0.0, 0.0);
	scrollBubble.cornerRadius = SCROLLBAR_HEIGHT/2.0;
	scrollBubble.backgroundColor = black;
	scrollBubble.borderColor = white;
	scrollBubble.borderWidth = 0.5;
	scrollBubble.name = @"bubble";

	[_scrollLayer addSublayer:scrollBubble];
	CGColorSpaceRelease(rgbSpace);
	CGColorRelease(light);
	CGColorRelease(white);
	CGColorRelease(black);

    }
    if(!_scrollLayer.superlayer){
	[self.layer addSublayer:_scrollLayer];
    }

    //temporarily disable custom animation timing
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.00f];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];

    _scrollLayer.frame = CGRectMake(0.0f, 0.0f, SCROLLBAR_WIDTH, SCROLLBAR_HEIGHT);
    _scrollLayer.position = CGPointMake(NSMidX([self bounds]), SCROLLBAR_Y_POSITION);

    //adjust sublayers
    for(CALayer* sublayer in _scrollLayer.sublayers){
	if([sublayer.name isEqualToString:@"bubble"]){

	    //NOTE: a change here may need to be reflected in mouseDragged
	    CGFloat width = SCROLLBAR_WIDTH/(float)[_cachedLayers count];
	    CGFloat finalWidth = width < SCROLL_BUBBLE_MIN_WIDTH ? SCROLL_BUBBLE_MIN_WIDTH : width;
	    CGFloat xPos = SCROLLBAR_WIDTH/(float)[_cachedLayers count];
	    xPos *= _focusedItemIndex;

	    //if using SCROLL_BUBBLE_MIN_WIDTH adjust x position to not run off end
	    if(finalWidth > width){
		xPos -= ((finalWidth-width)/(float)[_cachedLayers count] * _focusedItemIndex);
	    }

	    sublayer.frame = CGRectMake(0.0f, 0.0f, finalWidth, SCROLLBAR_HEIGHT);
	    sublayer.position = CGPointMake(xPos, 0.0);
	}
    }

    [CATransaction commit];
}

- (void)adjustLayerPositions{
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
    //small helper function to aid readability also includes optimization

    CGFloat offset = lround(anchor.x) == 1 ? layer.bounds.size.width : -(layer.bounds.size.width);

    if([self isOnscreenFrom:layer.position to:position offset:offset]){
	layer.anchorPoint = anchor;
	layer.position    = position;
	layer.zPosition   = zPos;
	layer.transform   = transform;
    }else{
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue
			 forKey:kCATransactionDisableActions];

	    layer.anchorPoint = anchor;
	    layer.position    = position;
	    layer.zPosition   = zPos;
	    layer.transform   = transform;
	[CATransaction commit];
    }
}

- (void)adjustLayerBounds{
    //NOTE: do not call this method instead call adjustCachedLayersWithAnimation:

    CGFloat smallerHeight = MAXIMUM_IMAGE_HEIGHT - SMALLER_IMAGE_HEIGHT_OFFSET;

    //adjust all layers
    for(int i=0; i<[_cachedLayers count]; i++){

	CALayer* layer          = [_cachedLayers objectAtIndex:i];
	CALayer* layerReflected = [_cachedReflectionLayers objectAtIndex:i];
	layer.bounds            = [self scaleRect:layer.bounds toWithin:smallerHeight];
	layerReflected.bounds   = [self scaleRect:layerReflected.bounds toWithin:smallerHeight];

	for(CALayer* subLayer in layer.sublayers){
	    subLayer.bounds = layer.bounds;
	}
	for(CALayer* subLayer in layerReflected.sublayers){
	    subLayer.bounds = layerReflected.bounds;
	}

    }

    //adjust focused layer
    CALayer* focused = [_cachedLayers objectAtIndex:_focusedItemIndex];
    CALayer* focusedReflected = [_cachedReflectionLayers objectAtIndex:_focusedItemIndex];
    focused.bounds = [self scaleRect:focused.bounds toWithin:MAXIMUM_IMAGE_HEIGHT];
    focusedReflected.bounds = [self scaleRect:focusedReflected.bounds toWithin:MAXIMUM_IMAGE_HEIGHT];

    for(CALayer* subLayer in focused.sublayers){
	subLayer.bounds = focused.bounds;
    }
    for(CALayer* subLayer in focusedReflected.sublayers){
	subLayer.bounds = focusedReflected.bounds;
    }
}

- (void)addContentsToVisibleLayers{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

    for(int i=0; i<[_cachedLayers count]; i++){

	CALayer* layer          = [_cachedLayers objectAtIndex:i];
	CALayer* layerReflected = [_cachedReflectionLayers objectAtIndex:i];

        //double buffering: this significantly reduces flicker
        CGPoint left  = CGPointMake(layer.position.x + self.bounds.size.width/2.0,
                                    layer.position.y);
        CGPoint right = CGPointMake(layer.position.x - self.bounds.size.width/2.0,
                                    layer.position.y);
        if([self isOnscreenFrom:left to:right offset:0]){
            if(layer.contents == nil){
                GSCoverflowItem* item   = [dataSource coverflow:self itemAtIndex:i];
                layer.contents          = (id)item.imageRepresentation;
                layerReflected.contents = (id)item.imageRepresentation;
            }
        }else{
            layer.contents = nil;
            layerReflected.contents = nil;
        }
    }

    [pool drain];
}

- (BOOL)isEven:(CGFloat)n{
    int quotient = (int)(n/2.0);
    int remainder = n - (quotient*2.0);

    return remainder == 0;
}

- (BOOL)isOnscreenFrom:(CGPoint)posFrom to:(CGPoint)posTo offset:(CGFloat)offset{
    //if the position is going to appear 'on screen' during the transition from
    //posFrom to posTo: returns YES. An offset can be applied to shift the screen
    //to the right, a negative offset shifts the screen to the left.

    CGFloat x = self.bounds.origin.x;
    CGFloat w = self.bounds.size.width;
    CGFloat screenLeft  = x + offset;
    CGFloat screenRight = x + offset + w;

    return !((posFrom.x < screenLeft     && posTo.x < screenLeft) ||
             (posFrom.x > screenRight && posTo.x > screenRight));

}

- (CGRect)scaleRect:(CGRect)rect toWithin:(CGFloat)length{
    //returns a rect, with largest dimension scaled to fit within length

    CGRect retRect;

    if(rect.size.height > rect.size.width)
	retRect = CGRectMake(0.0f, 0.0f, (length/rect.size.height) * rect.size.width, length);
    else
	retRect = CGRectMake(0.0f, 0.0f, length, (length/rect.size.width) * rect.size.height);

    return retRect;
}

///////////////////    TRANSFORM METHODS     /////////////////////////////////////////////////////

- (CATransform3D)leftHandImageTransformWithHeight:(CGFloat)height width:(CGFloat)width{
    CATransform3D transform;
    CGFloat alpha = 0.25;
    CGFloat gamma = (height - (width*tan(alpha)));
    transform.m11 = 1; transform.m12 = tan(alpha)/2; transform.m13 = 0; transform.m14 = ((height/gamma)-1)/width;
    transform.m21 = 0; transform.m22 = 1;            transform.m23 = 0; transform.m24 = 0;
    transform.m31 = 0; transform.m32 = 0;            transform.m33 = 1; transform.m34 = 0;
    transform.m41 = 0; transform.m42 = 0;            transform.m43 = 0; transform.m44 = 1;

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

- (CALayer*)focusedLayer{
    return [_cachedLayers objectAtIndex:[self selectionIndex]];
}

- (CALayer*)layerForLocationInWindow:(NSPoint)eventLocation{
    NSPoint localPoint = [self convertPoint:eventLocation fromView:nil];

    CALayer* clickedLayer = [self.layer hitTest:NSPointToCGPoint(localPoint)];
    if(!clickedLayer)
	return nil;
    else
	return clickedLayer;
}

- (NSUInteger)itemIndexForLocationInWindow:(NSPoint)eventLocation{
    //returns NSNotFound if location is not in the view or is not a valid item layer

    CALayer* clickedLayer = [self layerForLocationInWindow:eventLocation];
    if(!clickedLayer)
	return NSNotFound;

    return [_cachedLayers indexOfObjectIdenticalTo:clickedLayer];
}

- (void)focusedItemDragged:(CALayer*)clickedLayer withEvent:(NSEvent*)theEvent{
    NSSize dragOffset = NSMakeSize(0.0, 0.0);
    NSPasteboard* pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
    NSImage* dragImage = [[[NSImage alloc] initWithCGImage:(CGImageRef)[clickedLayer contents]
						      size:NSSizeFromCGSize(clickedLayer.bounds.size)] autorelease];
    [dragImage lockFocus]; //draw self into self at 50% opacity
    [dragImage drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeCopy fraction:0.5];
    [dragImage unlockFocus];

    CGPoint focusPosition = [clickedLayer position];
    focusPosition.x -= clickedLayer.bounds.size.width/2.0; //adjust for anchor point
    NSPoint localPoint = NSPointFromCGPoint(focusPosition);

    if([[self dataSource] respondsToSelector:@selector(coverflow:writeItemsAtIndexes:toPasteboard:)]){
	//currently does not make use of return value
	[[self dataSource] coverflow:self
		 writeItemsAtIndexes:[NSIndexSet indexSetWithIndex:[self selectionIndex]]
			toPasteboard:pboard];
    }

    [self dragImage:dragImage at:localPoint
			  offset:dragOffset //ignored parameter
			   event:theEvent
		      pasteboard:pboard
			  source:self
		       slideBack:YES];
}

- (void)mouseDown:(NSEvent *)theEvent{
    //handles single and double clicks
    //NSLog(@"Mouse down. \n%@", theEvent);

    CALayer* clickedLayer = [self layerForLocationInWindow:[theEvent locationInWindow]];
    if(clickedLayer && [clickedLayer.name isEqualToString:@"bubble"]){
	_bubbleDragged = YES;
	_focusedDragged = NO;
	return;
    }else{
	_bubbleDragged = NO;
    }

    NSUInteger index = [self itemIndexForLocationInWindow:[theEvent locationInWindow]];
    if(index == NSNotFound)
	return;

    if([theEvent clickCount] == 1 && [self selectionIndex] == index) //drag on focused item
	_focusedDragged = YES;
    else
	_focusedDragged = NO;

    if([theEvent clickCount] == 2 && [self selectionIndex] == index){ //double click on focused item
	if([[self delegate] respondsToSelector:@selector(coverflow:cellWasDoubleClickedAtIndex:)]){
	    [[self delegate] coverflow:self cellWasDoubleClickedAtIndex:index];
	}
    }

    [self setSelectionIndex:index];
}

- (void)mouseDragged:(NSEvent *)theEvent{
    //detect drag on the scrollbar bubble
    //NSLog(@"Mouse dragged: %d:%f", [theEvent eventNumber], [theEvent locationInWindow].x);

    if(_bubbleDragged){
	//work out x co-ord relative to the scrollbar
	NSPoint eventLocation = [theEvent locationInWindow];
	NSPoint localPoint = [self convertPoint:eventLocation fromView:nil];
	CGFloat relativeXCoord = localPoint.x - (self.bounds.size.width-SCROLLBAR_WIDTH)/2.0;

	//reverse the index from this
	//NOTE: a change here may need to be reflected in updateScrollLayer
	CGFloat xPos = SCROLLBAR_WIDTH/(float)[_cachedLayers count];
	NSUInteger newFocusedIndex = relativeXCoord/xPos;

	[self setSelectionIndex:newFocusedIndex];
    }

    if(_focusedDragged){
	[self focusedItemDragged:[self focusedLayer] withEvent:theEvent];
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
    //NSLog(@"Key down!\n%@", theEvent);

    if([theEvent modifierFlags] & NSNumericPadKeyMask) { // arrow keys have this mask
        NSString *theArrow = [theEvent charactersIgnoringModifiers];
        if([theArrow length] == 0)
            return;            // reject dead keys
        if([theArrow length] == 1) {
	    switch([theArrow characterAtIndex:0]){
		case NSUpArrowFunctionKey:
		case NSLeftArrowFunctionKey:
		    [self moveOneItemLeft:self];
		    return;
		case NSDownArrowFunctionKey:
		case NSRightArrowFunctionKey:
		   [self moveOneItemRight:self];
		   return;
		default:
		   [super keyDown:theEvent];
		   return;
	    }
	}
    }
    [super keyDown:theEvent];
}

- (BOOL)acceptsFirstResponder{
    return YES; //the view will not handle key events without this
}

- (IBAction)moveOneItemLeft:(id)sender{
    [self setSelectionIndex:[self selectionIndex]-1];
}

- (IBAction)moveOneItemRight:(id)sender{
    [self setSelectionIndex:[self selectionIndex]+1];
}

///////////////////    CALayoutManager Protocol Methods    ///////////////////////////////////////

- (void)invalidateLayoutOfLayer:(CALayer *)layer{
    NSSize newSize = self.bounds.size;
    if(newSize.width != _currentViewSize.width || newSize.height != _currentViewSize.height){
	_currentViewSize = self.bounds.size;
	[self adjustCachedLayersWithAnimation:NO];
    }
}

@end

@implementation GSNoHitGradientLayer
//Simple override. Does not respond to hit testing.

- (BOOL)containsPoint:(CGPoint)thePoint{
    return NO;
}

@end
