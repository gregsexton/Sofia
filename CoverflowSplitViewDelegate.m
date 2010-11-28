//
// CoverflowSplitViewDelegate.m
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

#import "CoverflowSplitViewDelegate.h"


@implementation CoverflowSplitViewDelegate

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin 
							 ofSubviewAt:(NSInteger)dividerIndex{
    return 200; //only one divider
}

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview{

    //documentation suggests that the order will always be the
    //same: "The order is based on the order of the receiver's
    //subviews as specified in the nib file".
    if(subview == [[splitView subviews] objectAtIndex:0]) //coverflow
	return NO;

    if(subview == [[splitView subviews] objectAtIndex:1]) //tableview
	return YES;

    return YES;
}

@end
