//
//  isbnExtractor.m
//  books
//
//  Created by Greg on 13/06/2010.
//  Copyright 2010 Greg Sexton Software. All rights reserved.
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
    //TODO: remove duplicates and improve regex
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
