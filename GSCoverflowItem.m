//
// GSCoverflowItem.m
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

#import "GSCoverflowItem.h"


@implementation GSCoverflowItem
@synthesize imageUID;
@synthesize imageRepresentation;
@synthesize imageTitle;
@synthesize imageSubtitle;
@synthesize imageVersion;


- (id)initWithUID:(NSString*)uid representation:(CGImageRef)rep title:(NSString*)title subtitle:(NSString*)subtitle{
    self = [super init];
    if(self){
	[self setImageUID:uid];
	[self setImageRepresentation:rep];
	[self setImageTitle:title];
	[self setImageSubtitle:subtitle];
	[self setImageVersion:0];
    }
    return self;
}

@end
