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

- (id)initWithContent:(NSString*)content{
    if(self = [super init]){
	[self setContent:content];
	return self;
    }
}

- (NSArray*)discoveredISBNs{
    //returns an array of all matched isbns both 10 and 13
    NSArray* returnArray = nil;
    NSString* regexString = @"greg";
    returnArray = [[self content] componentsMatchedByRegex:regexString];
    return returnArray;
}


@end
