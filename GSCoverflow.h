//
// GSCoverflow.h
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

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "GSCoverflowDelegate.h"
#import "GSCoverflowDataSource.h"
#import "GSCoverflowItem.h"
#import <math.h>

@interface GSCoverflow : NSView {

    id <GSCoverflowDelegate> delegate;
    id <GSCoverflowDataSource> dataSource;

    NSMutableArray* _cachedLayers;
    NSMutableArray* _cachedReflectionLayers;

    NSUInteger _focusedItemIndex;
    CGFloat _maximumImageHeight;

}

@property (nonatomic,assign) id <GSCoverflowDelegate> delegate;
@property (nonatomic,assign) id <GSCoverflowDataSource> dataSource;

- (CALayer*)layerForGSCoverflowItem:(GSCoverflowItem*)item;
- (CALayer*)reflectionLayerForGSCoverflowItem:(GSCoverflowItem*)item;
- (CGRect)scaleRect:(CGRect)rect toWithinHeight:(CGFloat)height;
- (void)adjustCachedLayersWithAnimation:(BOOL)animate;
- (void)adjustLayerBoundsWithAnimation:(BOOL)animate;
- (void)adjustLayerPositionsWithAnimation:(BOOL)animate;
- (void)deleteCachedLayers;
- (void)reloadData;

- (CATransform3D)identityReflectionTransform;
- (CATransform3D)identityTransform;
- (CATransform3D)leftHandImageTransformWithHeight:(CGFloat)height width:(CGFloat)width;
- (CATransform3D)leftHandReflectionTransformWithHeight:(CGFloat)height width:(CGFloat)width;
- (CATransform3D)rightHandImageTransformWithHeight:(CGFloat)height width:(CGFloat)width;
- (CATransform3D)rightHandReflectionTransformWithHeight:(CGFloat)height width:(CGFloat)width;

- (IBAction)moveOneItemLeft:(id)sender;
- (IBAction)moveOneItemRight:(id)sender;
@end
