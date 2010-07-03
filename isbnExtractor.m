//
// isbnExtractor.m
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

#import "isbnExtractor.h"


@implementation isbnExtractor
@synthesize content;

- (id)initWithContent:(NSString*)theContent{
    if(self = [super init]){
	[self setContent:theContent];
	isbns = nil;
	return self;
    }
}

- (NSArray*)discoveredISBNs{
    //returns an array of all matched isbns both 10 and 13
    //with any hypehns removed
    NSArray* matches = nil;
    NSString* regexString = @"(?m:(?<=(^|[\\s\\p{P}]))(978-?)?(\\d-?){9}\\d(?=([\\s\\p{P}]|$)))";
    matches = [[self content] componentsMatchedByRegex:regexString];

    NSMutableArray* returnArray = [NSMutableArray arrayWithCapacity:[matches count]];
    for(int i=0; i<[matches count]; i++){
	NSString* s = [matches objectAtIndex:i];
	s = [s stringByReplacingOccurrencesOfString:@"-" withString:@""];
	[returnArray insertObject:s atIndex:i];
    }

    isbns = returnArray; //save for future processing
    return returnArray;
}

- (NSArray*)discoveredISBNsWithoutDups{
    //NOTE: this function returns a sorted list.

    NSArray* sorted = [[self discoveredISBNs] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSMutableArray* removedDups = [NSMutableArray arrayWithCapacity:0]; //pessimistic

    //remove dups
    NSString* currentLook = nil;
    for (NSString* s in sorted) {
	if(![s isEqualToString:currentLook])
	    [removedDups addObject:s];
	currentLook = s;
    }

    return removedDups;
}

@end
