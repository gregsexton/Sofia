//
// GSCoverflow.h
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

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "GSCoverflowDelegate.h"
#import "GSCoverflowDataSource.h"
#import "GSCoverflowItem.h"
#import <math.h>

//positioning constants
#define MAXIMUM_IMAGE_HEIGHT (self.frame.size.height-85-20)
#define SMALLER_IMAGE_HEIGHT_OFFSET (MAXIMUM_IMAGE_HEIGHT/10.0)
#define IMAGE_Y_POSITION_SCALE_FACTOR (0.0)
#define IMAGE_Y_POSITION_OFFSET (self.frame.size.height - MAXIMUM_IMAGE_HEIGHT - 20)
#define STACKED_IMAGE_SPACING (MAXIMUM_IMAGE_HEIGHT / 6.0)
#define FOCUSED_IMAGE_SPACING ((MAXIMUM_IMAGE_HEIGHT/8.0)*9)
//text layer height at current font size is 29.0
#define TITLE_Y_POSITION (55.0)

#define SCROLLBAR_WIDTH (self.bounds.size.width-200)
#define SCROLLBAR_HEIGHT (15.0)
#define SCROLLBAR_Y_POSITION (20.0)
#define SCROLL_BUBBLE_MIN_WIDTH (20.0)

@interface GSNoHitGradientLayer : CAGradientLayer {} @end

@interface GSCoverflow : NSView {

    id <GSCoverflowDelegate>   delegate;
    id <GSCoverflowDataSource> dataSource;

    NSMutableArray*       _cachedLayers;
    NSMutableArray*       _cachedReflectionLayers;
    NSMutableArray*       _cachedTitles;
    NSMutableArray*       _cachedSubtitles;

    CATextLayer*          _titleLayer;
    CALayer*              _scrollLayer;
    GSNoHitGradientLayer* _leftFadeLayer;
    GSNoHitGradientLayer* _rightFadeLayer;
    BOOL                  _bubbleDragged;
    BOOL                  _focusedDragged;

    NSUInteger            _focusedItemIndex;

    NSSize                _currentViewSize;

}

@property (nonatomic,assign) id <GSCoverflowDelegate> delegate;
@property (nonatomic,assign) id <GSCoverflowDataSource> dataSource;

- (BOOL)isEven:(CGFloat)n;
- (BOOL)isOnscreenFrom:(CGPoint)posFrom to:(CGPoint)posTo offset:(CGFloat)offset;
- (CALayer*)layerForGSCoverflowItem:(GSCoverflowItem*)item;
- (CALayer*)reflectionLayerForGSCoverflowItem:(GSCoverflowItem*)item;
- (CGRect)scaleRect:(CGRect)rect toWithin:(CGFloat)length;
- (GSNoHitGradientLayer*)leftFadeLayer;
- (GSNoHitGradientLayer*)rightFadeLayer;
- (void)addContentsToVisibleLayers;
- (void)adjustCachedLayersWithAnimation:(BOOL)animate;
- (void)adjustLayerBounds;
- (void)adjustLayerPositions;
- (void)adjustLeftFadeLayer;
- (void)adjustRightFadeLayer;
- (void)deleteCache;
- (void)moveLayer:(CALayer*)layer to:(CGPoint)position anchoredAt:(CGPoint)anchor zPosition:(CGFloat)zPos transform:(CATransform3D)transform;
- (void)reloadData;
- (void)updateScrollLayer;
- (void)updateTitleLayer;

- (CATransform3D)identityReflectionTransform;
- (CATransform3D)identityTransform;
- (CATransform3D)leftHandImageTransformWithHeight:(CGFloat)height width:(CGFloat)width;
- (CATransform3D)leftHandReflectionTransformWithHeight:(CGFloat)height width:(CGFloat)width;
- (CATransform3D)rightHandImageTransformWithHeight:(CGFloat)height width:(CGFloat)width;
- (CATransform3D)rightHandReflectionTransformWithHeight:(CGFloat)height width:(CGFloat)width;

- (NSUInteger)selectionIndex;
- (void)setSelectionIndex:(NSUInteger)index;
- (void)focusedItemDragged:(CALayer*)clickedLayer withEvent:(NSEvent*)theEvent;
- (IBAction)moveOneItemLeft:(id)sender;
- (IBAction)moveOneItemRight:(id)sender;
@end
