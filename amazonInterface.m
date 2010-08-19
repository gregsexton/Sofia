//
// amazonInterface.m
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

#import "amazonInterface.h"
#import "SignedAwsSearchRequest.h"

//TODO: present a choice of matching images; for now just use the first one.

@implementation amazonInterface
@synthesize imageURL;
@synthesize frontCover;
@synthesize successfullyFoundBook;
@synthesize amazonLink;

- (id)init{
    self = [super init];

    accessKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"amazon_accessKey"];
    secretAccessKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"amazon_secretAccessKey"];

    imageURL = @"";
    successfullyFoundBook = false; //assume the worst
    return self;
}

- (void)dealloc{
    if(currentStringValue)
	[currentStringValue release];
    [super dealloc];
}
    
- (BOOL)searchISBN:(NSString*)isbn{

    BOOL returnVal = [self searchForDetailsWithISBN:isbn];

    return returnVal;
}   

- (BOOL)searchForDetailsWithISBN:(NSString*)isbn{
    SignedAwsSearchRequest *req = [[[SignedAwsSearchRequest alloc] initWithAccessKeyId:accessKey secretAccessKey:secretAccessKey] autorelease];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@"ItemSearch"           forKey:@"Operation"];
    [params setValue:@"Books"                forKey:@"SearchIndex"];
    [params setValue:@"Large"		     forKey:@"ResponseGroup"]; //large includes just about everything (read: kitchen sink)
    [params setValue:isbn		     forKey:@"Keywords"];
    
    NSString *urlString = [req searchUrlForParameterDictionary:params];
    //NSLog(@"request URL: %@", urlString);
    NSURL* url = [[[NSURL alloc] initWithString:urlString] autorelease];

    NSXMLParser *parser = [[[NSXMLParser alloc] initWithContentsOfURL:url] autorelease];
    [parser setDelegate:self];

    return [parser parse]; //returns false if unsuccessful in parsing.
}

- (NSAttributedString*)getTableOfContentsFromURL:(NSURL*)url{
    //NOTE: this method uses a very 'hackish' algorithm as the toc
    //isn't exposed in the amazon api. It is liable to break at
    //any moment. Designed to take self.amazonLink as the parameter.

    NSString* detailsPage = [NSString stringWithContentsOfURL:url 
						     encoding:NSASCIIStringEncoding
							error:NULL];
    if(!detailsPage)
	return nil;

    NSString *regexString   = @"<a href=\"(.*)\">See Complete Table of Contents</a>";
    NSArray  *capturesArray = [detailsPage arrayOfCaptureComponentsMatchedByRegex:regexString];

    if([capturesArray count] <= 0)
	return nil;
    NSString* tocUrlString = [[capturesArray objectAtIndex:0] objectAtIndex:1];
    NSURL* tocUrl = [[NSURL alloc] initWithString:tocUrlString];

    NSString* tocPage = [NSString stringWithContentsOfURL:tocUrl 
						 encoding:NSASCIIStringEncoding 
						    error:NULL];
    if(!tocPage)
	return nil;

    regexString = @"(?s:<b class=\"h1\">Table of Contents</b>.*?<div class=\"content\">(.*?)</div>)";
    NSArray* tocCaptures = [tocPage arrayOfCaptureComponentsMatchedByRegex:regexString];

    if([tocCaptures count] <= 0)
	return nil;
    NSString* toc = [[tocCaptures objectAtIndex:0] objectAtIndex:1];
    NSData* tocData = [toc dataUsingEncoding:NSUTF8StringEncoding];
    NSAttributedString* tocReturn = [[NSAttributedString alloc] initWithHTML:tocData documentAttributes:NULL];

    return [tocReturn autorelease];
}

//// NSXMLParserDelegate Methods /////////////////////////////////////////////////////////////

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
					namespaceURI:(NSString *)namespaceURI 
				       qualifiedName:(NSString *)qName 
					  attributes:(NSDictionary *)attributeDict {
	     
    if([elementName isEqualToString:@"LargeImage"]){
	currentProperty = pLargeImage;
        return;
    }
    if([elementName isEqualToString:@"URL"] && currentProperty == pLargeImage){
	currentProperty = pImageURL;
        return;
    }

    if([elementName isEqualToString:@"TotalResults"]){
	currentProperty = pTotalResults;
        return;
    }

    if([elementName isEqualToString:@"DetailPageURL"]){
	currentProperty = pDetailsPage;
	return;
    }

    currentProperty = pNone;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {

    if (!currentStringValue) {
        currentStringValue = [[NSMutableString alloc] initWithCapacity:500];
    }
    [currentStringValue appendString:string];

}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
				      namespaceURI:(NSString *)namespaceURI 
				     qualifiedName:(NSString *)qName {

    if(currentProperty == pImageURL){
	if([imageURL isEqualToString:@""]){ //only capture first result, FIXME
	    [self setImageURL:currentStringValue];
	    [self setFrontCover:[[NSImage alloc] initWithContentsOfURL:[[[NSURL alloc] initWithString:currentStringValue] autorelease]]];
	}
    }

    if(currentProperty == pTotalResults){
	if([currentStringValue intValue] > 0)
	    [self setSuccessfullyFoundBook:true];
	else
	    [self setSuccessfullyFoundBook:false];
    }

    if(currentProperty == pDetailsPage){
	//NSLog(@"Details url: %@", currentStringValue);
	NSURL* url = [[NSURL alloc] initWithString:currentStringValue];
	[self setAmazonLink:url];
	[url release];
    }

    [currentStringValue release];
    currentStringValue = nil;
    return;
}

@end
