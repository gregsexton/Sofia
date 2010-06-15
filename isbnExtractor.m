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
    NSString* regexString = @"(978-?)?(\\d-?){9}\\d";
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


@end
