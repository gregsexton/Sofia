//
// NSString+Sofia.m
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

#import "NSString+Sofia.h"

//TODO: unit test these!

@implementation NSString (Sofia)

+ (NSString*)stringFromArray:(NSArray*)array withCombiner:(NSString*)combiner{
    //this function returns a string of the form "foo, bar <combiner> foobar"
    //from the array ["foo", "bar", "foobar"]

    if([array count] <= 0)
	return @"";
    if([array count] == 1)
	return [array objectAtIndex:0];

    NSString* buildUp = [array objectAtIndex:0];

    for(int i=1; i < [array count]-1; i++){
	buildUp = [NSString stringWithFormat:@"%@, %@", buildUp, [array objectAtIndex:i]];
    }

    buildUp = [NSString stringWithFormat:@"%@ %@ %@", buildUp, combiner, [array lastObject]];

    return buildUp;
}

+ (NSString*)interleaveArray:(NSArray*)array with:(NSString*)interleave{
    //returns a string of the form "foo x bar x foobar"
    //from the array ["foo", "bar", "foobar"]

    if([array count] <= 0)
	return @"";
    if([array count] == 1)
	return [array objectAtIndex:0];

    NSString* buildUp = [array objectAtIndex:0];

    for(int i=1; i<[array count]; i++){
	buildUp = [NSString stringWithFormat:@"%@%@%@", buildUp, interleave, [array objectAtIndex:i]];
    }

    return buildUp;
}

@end
