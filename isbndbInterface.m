//
// isbndbInterface.m
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

#import "isbndbInterface.h"

@implementation isbndbInterface
@synthesize currentProperty;
@synthesize bookISBN10;
@synthesize bookISBN13;
@synthesize bookTitle;
@synthesize bookTitleLong;
@synthesize bookAuthorsText;
@synthesize bookSubjectText;
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
@synthesize successfullyFoundBook;

- (id)init {
    self = [super init];
    //this is set here as it is calculated from list of subjects which may be empty
    [self setBookSubjectText:@""];
    return self;
}

- (BOOL)searchISBN:(NSString*)isbn {
    //returns true if the search is successful
    NSString *accessKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"isbndb_accessKey"];
    if(accessKey == nil || [accessKey isEqualToString:@""]){
	return false; //accessKey not valid or not set
    }else{
	NSString *urlPrefix = [@"http://isbndb.com/api/books.xml?access_key=" stringByAppendingString:accessKey];
	NSURL *detailsUrl = [[NSURL alloc] initWithString:[urlPrefix stringByAppendingString:[@"&results=details,texts,prices,subjects,marc,authors&index1=isbn&value1=" stringByAppendingString:isbn]]];

	return [self processDetailsWithUrl:detailsUrl];
    }
}

- (BOOL)processDetailsWithUrl:(NSURL*)url{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:self];

    return [parser parse]; //returns false if unsuccessful in parsing.
}

- (void)parser:(NSXMLParser *)parser 
	didStartElement:(NSString *)elementName 
	   namespaceURI:(NSString *)namespaceURI 
	  qualifiedName:(NSString *)qName 
	     attributes:(NSDictionary *)attributeDict {

    if ( [elementName isEqualToString:@"BookList"] ) {
	if( [[attributeDict objectForKey:@"total_results"] isEqualToString:@"1"] ){
	    [self setSuccessfullyFoundBook:true];
	}else{
	    [self setSuccessfullyFoundBook:false];
	}
    }
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
    if ( [elementName isEqualToString:@"AuthorsText"] ) {
	[self setCurrentProperty:pAuthorText]; 
        return;
    }
    if ( [elementName isEqualToString:@"PublisherText"] ) {
	[self setCurrentProperty:pPublisher]; 
        return;
    }
    if ( [elementName isEqualToString:@"Details"] ) {
	[self setBookEdition:[attributeDict objectForKey:@"edition_info"]];
	[self setBookLanguage:[self cleanUpString:[attributeDict objectForKey:@"language"]
				    andCapitalize:YES]];
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
	[self setBookTitle:[self cleanUpString:currentStringValue andCapitalize:YES]];
    }
    if ([self currentProperty] == pTitleLong){
	[self setBookTitleLong:[self cleanUpString:currentStringValue andCapitalize:YES]];
    }
    if ([self currentProperty] == pAuthorText){
	[self setBookAuthorsText:[self cleanUpString:currentStringValue andCapitalize:YES]];
    }
    if ([self currentProperty] == pPublisher){
	[self setBookPublisher:[self cleanUpString:currentStringValue andCapitalize:YES]];
    }
    if ([self currentProperty] == pSummary){
	[self setBookSummary:[self cleanUpString:currentStringValue andCapitalize:NO]];
    }
    if ([self currentProperty] == pNotes){
	[self setBookNotes:[self cleanUpString:currentStringValue andCapitalize:NO]];
    }
    if ([self currentProperty] == pUrls){
	[self setBookUrls:[self cleanUpString:currentStringValue andCapitalize:NO]];
    }
    if ([self currentProperty] == pAwards){
	[self setBookAwards:[self cleanUpString:currentStringValue andCapitalize:NO]];
    }
    if ([self currentProperty] == pAuthor){
	NSString *cleanString = [self cleanUpString:currentStringValue andCapitalize:YES];
	if(![cleanString isEqualToString:@""]){
	    [bookAuthors addObject:cleanString];
	}
    }
    if ([self currentProperty] == pSubject){
	if(currentStringValue!=nil){
	    NSString *cleanString = [self cleanUpString:currentStringValue andCapitalize:YES];
	    if(![cleanString isEqualToString:@""]){
		[bookSubjects addObject:cleanString];
		if([bookSubjects count] == 1){
		    [self setBookSubjectText:[bookSubjects objectAtIndex:0]];
		}
	    }
	}
    }
    [currentStringValue release];
    currentStringValue = nil;
    return;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
}

- (NSString*) cleanUpString:(NSString*)theString andCapitalize:(BOOL)capitalize{
    //if warranted could make this a category of NSString

    NSString* returnString = [theString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if(capitalize)
	return [returnString capitalizedString];
    else
	return returnString;
}

@end
