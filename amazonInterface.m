//
//  amazonInterface.m
//  books
//
//  Created by Greg on 26/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "amazonInterface.h"
#import "SignedAwsSearchRequest.h"

//TODO: present a choice of matching images; for now just use the first one.
//TODO: fail nicely if book not found

@implementation amazonInterface
@synthesize imageURL;
@synthesize frontCover;

- (id)init{
    self = [super init];

    accessKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"amazon_accessKey"];
    secretAccessKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"amazon_secretAccessKey"];

    imageURL = @"";
    return self;
}
    
- (BOOL)searchISBN:(NSString*)isbn{

    return [self searchForImagesWithISBN:isbn];
	
}   

- (BOOL)searchForImagesWithISBN:(NSString*)isbn{

    SignedAwsSearchRequest *req = [[[SignedAwsSearchRequest alloc] initWithAccessKeyId:accessKey secretAccessKey:secretAccessKey] autorelease];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@"ItemSearch"           forKey:@"Operation"];
    [params setValue:@"Books"                forKey:@"SearchIndex"];
    [params setValue:@"Images"               forKey:@"ResponseGroup"];
    [params setValue:isbn		     forKey:@"Keywords"];
    
    NSString *urlString = [req searchUrlForParameterDictionary:params];
    //NSLog(@"request URL: %@", urlString);
    
    return [self processImagesWithUrl:[[[NSURL alloc] initWithString:urlString] autorelease]];
}

- (BOOL)processImagesWithUrl:(NSURL*)url{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:self];

    return [parser parse]; //returns false if unsuccessful in parsing.
}

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

    if (currentProperty == pImageURL){
	if([imageURL isEqualToString:@""]){ //only capture first result, FIXME
	    [self setImageURL:currentStringValue];
	    [self setFrontCover:[[NSImage alloc] initWithContentsOfURL:[[[NSURL alloc] initWithString:currentStringValue] autorelease]]];
	}
    }

    [currentStringValue release];
    currentStringValue = nil;
    return;
}

@end
