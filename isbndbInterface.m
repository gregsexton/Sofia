//
//  isbndbInterface.m
//  books
//
//  Created by Greg Sexton on 06/09/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "isbndbInterface.h"


@implementation isbndbInterface
@synthesize currentProperty;
@synthesize bookISBN10;
@synthesize bookISBN13;
@synthesize bookTitle;
@synthesize bookTitleLong;
@synthesize bookPublisher;
@synthesize bookEdition;
@synthesize bookLanguage;
@synthesize bookPhysicalDescrip;
@synthesize bookLCCNumber;
@synthesize bookDewey;
@synthesize bookDeweyNormalized;
@synthesize bookSummary;
@synthesize bookNotes;
@synthesize bookUrls;
@synthesize bookAwards;
@synthesize bookSubjects;
@synthesize bookAuthors;

- (id)init {
    self = [super init];
    return self;
}

- (BOOL)searchISBN:(NSString*)isbn {
    //returns true if the search is successful
    NSURL *detailsUrl = [[NSURL alloc] initWithString:[@"http://isbndb.com/api/books.xml?access_key=&results=details,texts,prices,subjects,marc,authors&index1=isbn&value1=" stringByAppendingString:isbn]];

    return [self processDetailsWithUrl: detailsUrl];
}

- (BOOL)processDetailsWithUrl:(NSURL*)url{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:self];

    return [parser parse]; //returns false if unsuccessful in parsing.
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ( [elementName isEqualToString:@"BookData"] ) {
	[self setBookISBN10:[attributeDict objectForKey:@"isbn"]]; 
	[self setBookISBN13:[attributeDict objectForKey:@"isbn13"]]; 
        return;
    }
    if ( [elementName isEqualToString:@"Title"] ) {
	[self setCurrentProperty:pTitle]; 
        return;
    }
    if ( [elementName isEqualToString:@"TitleLong"] ) {
	[self setCurrentProperty:pTitleLong]; 
        return;
    }
    if ( [elementName isEqualToString:@"PublisherText"] ) {
	[self setCurrentProperty:pPublisher]; 
        return;
    }
    if ( [elementName isEqualToString:@"Details"] ) {
	[self setBookEdition:[attributeDict objectForKey:@"edition_info"]];
	[self setBookLanguage:[attributeDict objectForKey:@"language"]];
	[self setBookPhysicalDescrip:[attributeDict objectForKey:@"physical_description_text"]];
	[self setBookLCCNumber:[attributeDict objectForKey:@"lcc_number"]];
	[self setBookDewey:[attributeDict objectForKey:@"dewey_decimal"]];
	[self setBookDeweyNormalized:[attributeDict objectForKey:@"dewey_decimal_normalized"]];
	[self setCurrentProperty:pNoProperty];
        return;
    }
    if ( [elementName isEqualToString:@"Summary"] ) {
	[self setCurrentProperty:pSummary]; 
        return;
    }
    if ( [elementName isEqualToString:@"Notes"] ) {
	[self setCurrentProperty:pNotes]; 
        return;
    }
    if ( [elementName isEqualToString:@"UrlsText"] ) {
	[self setCurrentProperty:pUrls]; 
        return;
    }
    if ( [elementName isEqualToString:@"AwardsText"] ) {
	[self setCurrentProperty:pAwards]; 
        return;
    }
    if ( [elementName isEqualToString:@"Subjects"] ) {
	if (!bookSubjects)
	    bookSubjects = [[NSMutableArray alloc] initWithCapacity:10];
        return;
    }
    if ( [elementName isEqualToString:@"Subject"] ) {
	[self setCurrentProperty:pSubject]; 
        return;
    }
    if ( [elementName isEqualToString:@"Authors"] ) {
	if (!bookAuthors)
	    bookAuthors = [[NSMutableArray alloc] initWithCapacity:5];
        return;
    }
    if ( [elementName isEqualToString:@"Person"] ) {
	[self setCurrentProperty:pAuthor]; 
        return;
    }

    [self setCurrentProperty:pNoProperty];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!currentStringValue) {
        currentStringValue = [[NSMutableString alloc] initWithCapacity:500];
    }
    [currentStringValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([self currentProperty] == pTitle){
	[self setBookTitle:currentStringValue];
    }
    if ([self currentProperty] == pTitleLong){
	[self setBookTitleLong:currentStringValue];
    }
    if ([self currentProperty] == pPublisher){
	[self setBookPublisher:currentStringValue];
    }
    if ([self currentProperty] == pSummary){
	[self setBookSummary:currentStringValue];
    }
    if ([self currentProperty] == pNotes){
	[self setBookNotes:currentStringValue];
    }
    if ([self currentProperty] == pUrls){
	[self setBookUrls:currentStringValue];
    }
    if ([self currentProperty] == pAwards){
	[self setBookAwards:currentStringValue];
    }
    if ([self currentProperty] == pAuthor){
	[bookAuthors addObject:currentStringValue];
    }
    if ([self currentProperty] == pSubject){
	[bookSubjects addObject:currentStringValue];
    }
    [currentStringValue release];
    currentStringValue = nil;
    return;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
}

@end
