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
@synthesize bookISBN10;
@synthesize bookISBN13;
@synthesize bookTitle;
@synthesize bookAuthorsText;
@synthesize bookPublisher;
@synthesize bookEdition;
@synthesize bookPhysicalDescrip;
@synthesize bookSummary;
@synthesize bookAverageRating;
@synthesize bookReviews;

- (id)init{
    self = [super init];

    accessKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"amazon_accessKey"];
    secretAccessKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"amazon_secretAccessKey"];

    bookAuthors = [[NSMutableArray alloc] initWithCapacity:5]; //not many books have more than 5 authors
    dimensions = [[NSMutableArray alloc] initWithCapacity:3]; //length x width x height
    similarProductASINs = [[NSMutableArray alloc] initWithCapacity:5]; //5 is arbitrary
    bookReviews = [[NSMutableArray alloc] initWithCapacity:5]; //5 is an arbitrary guess
    return self;
}

- (void)dealloc{
    if(currentStringValue)
	[currentStringValue release];
    if(currentReview)
	[currentReview release];
    [bookAuthors release];
    [dimensions release];
    [similarProductASINs release];
    [bookReviews release];
    if(asin)
	[asin release];
    [super dealloc];
}
    
- (BOOL)searchISBN:(NSString*)isbn{
    imageURL = @"";
    successfullyFoundBook = false; //assume the worst

    BOOL returnVal = [self searchForDetailsWithISBN:isbn];

    if(asin)
	returnVal = returnVal && [self searchForEditorialReviewWithASIN:asin];

    return returnVal;
}   

- (BOOL)searchASIN:(NSString*)theAsin{
    imageURL = @"";
    successfullyFoundBook = false; //assume the worst

    BOOL returnVal = [self searchForDetailsWithASIN:theAsin];
    returnVal = returnVal && [self searchForEditorialReviewWithASIN:theAsin];

    return returnVal;
}

- (NSArray*)similarBooksToISBN:(NSString*)isbn{

    [self searchISBN:isbn];
    return similarProductASINs;
}

- (NSArray*)allReviewsForISBN:(NSString*)isbn{
    BOOL returnVal = [self searchForDetailsWithISBN:isbn];
    if(!returnVal)
	return nil;

    [bookReviews removeAllObjects]; //start with a clean slate
    for(int i=1; i<=numberOfReviewPages; i++){
	[self searchForCustomerReviewsWithASIN:asin 
				      withPage:[NSString stringWithFormat:@"%d", i]];
    }
    return bookReviews;
}

- (BOOL)searchForDetailsWithISBN:(NSString*)isbn{

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@"ItemSearch"           forKey:@"Operation"];
    [params setValue:@"Books"                forKey:@"SearchIndex"];
    [params setValue:@"Large"		     forKey:@"ResponseGroup"]; //large includes just about everything (read: kitchen sink)
    [params setValue:isbn		     forKey:@"Keywords"];
    
    return [self parseAmazonDataWithParamaters:params];
}

- (BOOL)searchForDetailsWithASIN:(NSString*)theASIN{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@"ItemLookup"           forKey:@"Operation"];
    [params setValue:theASIN		     forKey:@"ItemId"];
    [params setValue:@"Large"		     forKey:@"ResponseGroup"]; 
    
    return [self parseAmazonDataWithParamaters:params];
}

- (BOOL)searchForEditorialReviewWithASIN:(NSString*)theASIN{

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@"ItemLookup"           forKey:@"Operation"];
    [params setValue:theASIN		     forKey:@"ItemId"];
    [params setValue:@"EditorialReview"	     forKey:@"ResponseGroup"];
    
    return [self parseAmazonDataWithParamaters:params];
}

- (BOOL)searchForCustomerReviewsWithASIN:(NSString*)theASIN withPage:(NSString*)pageNumber{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@"ItemLookup"           forKey:@"Operation"];
    [params setValue:@"Reviews"		     forKey:@"ResponseGroup"];
    [params setValue:@"-HelpfulVotes"	     forKey:@"ReviewSort"];
    [params setValue:pageNumber		     forKey:@"ReviewPage"];
    [params setValue:theASIN		     forKey:@"ItemId"];
    
    return [self parseAmazonDataWithParamaters:params];
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

    NSString *regexString = @"<a href=\"(.*)\">See Complete Table of Contents</a>";
    NSArray  *capturesArray = [detailsPage arrayOfCaptureComponentsMatchedByRegex:regexString];

    if([capturesArray count] <= 0)
	return nil;
    NSString* tocUrlString = [[capturesArray objectAtIndex:0] objectAtIndex:1];
    NSURL* tocUrl = [[NSURL alloc] initWithString:tocUrlString];

    NSString* tocPage = [NSString stringWithContentsOfURL:tocUrl 
						 encoding:NSASCIIStringEncoding 
						    error:NULL];
    [tocUrl release];
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

- (BOOL)parseAmazonDataWithParamaters:(NSDictionary*)params{
    //reset sections
    _ItemAttributes = false;
    _EditorialReview = false;
    _CustomerReviews = false;
    _SimilarProducts = false;

    SignedAwsSearchRequest *req = [[[SignedAwsSearchRequest alloc] initWithAccessKeyId:accessKey secretAccessKey:secretAccessKey] autorelease];

    NSString *urlString = [req searchUrlForParameterDictionary:params];
//NSLog(@"request URL: %@", urlString);
    NSURL* url = [[[NSURL alloc] initWithString:urlString] autorelease];

    NSXMLParser *parser = [[[NSXMLParser alloc] initWithContentsOfURL:url] autorelease];
    [parser setDelegate:self];

    return [parser parse]; //returns false if unsuccessful in parsing.
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

    if([elementName isEqualToString:@"TotalReviewPages"]){
	currentProperty = pTotalReviewPages;
        return;
    }

    if([elementName isEqualToString:@"DetailPageURL"]){
	currentProperty = pDetailsPage;
	return;
    }

    if([elementName isEqualToString:@"ASIN"]){
	currentProperty = pASIN;
	return;
    }

    if(_ItemAttributes){
	if([elementName isEqualToString:@"ISBN"]){
	    currentProperty = pISBN10;
	    return;
	}
	if([elementName isEqualToString:@"EAN"]){
	    currentProperty = pISBN13;
	    return;
	}
	if([elementName isEqualToString:@"Title"]){
	    currentProperty = pTitleAmazon;
	    return;
	}
	if([elementName isEqualToString:@"Author"]){
	    currentProperty = pAuthorAmazon;
	    return;
	}
	if([elementName isEqualToString:@"Publisher"]){
	    currentProperty = pPublisherAmazon;
	    return;
	}
	if([elementName isEqualToString:@"Edition"]){
	    currentProperty = pEdition;
	    return;
	}
	if([elementName isEqualToString:@"PublicationDate"]){
	    currentProperty = pPubDate;
	    return;
	}
	if([elementName isEqualToString:@"Binding"]){
	    currentProperty = pBinding;
	    return;
	}
	if([elementName isEqualToString:@"NumberOfPages"]){
	    currentProperty = pNoPages;
	    return;
	}
	if([elementName isEqualToString:@"Height"]){
	    currentProperty = pHeight;
	    return;
	}
	if([elementName isEqualToString:@"Length"]){
	    currentProperty = pLength;
	    return;
	}
	if([elementName isEqualToString:@"Width"]){
	    currentProperty = pWidth;
	    return;
	}
	if([elementName isEqualToString:@"Weight"]){
	    currentProperty = pWeight;
	    return;
	}
    }

    if(_CustomerReviews){
	if([elementName isEqualToString:@"Review"]){
	    currentReview = [[BookReview alloc] init];
	}
	if([elementName isEqualToString:@"Rating"]){
	    currentProperty = pReviewRating;
	    return;
	}
	if([elementName isEqualToString:@"HelpfulVotes"]){
	    currentProperty = pReviewHelpfulVotes;
	    return;
	}
	if([elementName isEqualToString:@"TotalVotes"]){
	    currentProperty = pReviewTotalVotes;
	    return;
	}
	if([elementName isEqualToString:@"Date"]){
	    currentProperty = pReviewDate;
	    return;
	}
	if([elementName isEqualToString:@"Summary"]){
	    currentProperty = pReviewSummary;
	    return;
	}
	if([elementName isEqualToString:@"Content"]){
	    currentProperty = pReviewContent;
	    return;
	}
	if([elementName isEqualToString:@"AverageRating"]){
	    currentProperty = pReviewAverageRating;
	    return;
	}
    }

    if(_EditorialReview){
	if([elementName isEqualToString:@"Content"]){
	    currentProperty = pEditorialContent;
	    return;
	}
    }

    if(_SimilarProducts){
	if([elementName isEqualToString:@"ASIN"]){
	    currentProperty = pASIN;
	    return;
	}
    }

    if([elementName isEqualToString:@"ItemAttributes"]){
	_ItemAttributes = true;
    }

    if([elementName isEqualToString:@"EditorialReview"]){
	_EditorialReview = true;
    }

    if([elementName isEqualToString:@"CustomerReviews"]){
	_CustomerReviews = true;
    }

    if([elementName isEqualToString:@"SimilarProducts"]){
	_SimilarProducts = true;
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

    if([elementName isEqualToString:@"ItemAttributes"]){
	_ItemAttributes = false;
    }

    if([elementName isEqualToString:@"EditorialReview"]){
	_EditorialReview = false;
    }

    if([elementName isEqualToString:@"CustomerReviews"]){
	_CustomerReviews = false;
    }

    if([elementName isEqualToString:@"SimilarProducts"]){
	_SimilarProducts = false;
    }

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

    if(currentProperty == pTotalReviewPages){
	numberOfReviewPages = [currentStringValue intValue];
    }

    if(currentProperty == pDetailsPage){
	//NSLog(@"Details url: %@", currentStringValue);
	NSURL* url = [[NSURL alloc] initWithString:currentStringValue];
	[self setAmazonLink:url];
	[url release];
    }

    if(currentProperty == pASIN){
	if(asin == nil)
	    asin = [currentStringValue retain];
    }

    if(_ItemAttributes){
	if(currentProperty == pISBN10){
	    [self setBookISBN10:currentStringValue];
	}
	if(currentProperty == pISBN13){
	    [self setBookISBN13:currentStringValue];
	}
	if(currentProperty == pTitleAmazon){
	    [self setBookTitle:currentStringValue];
	}
	if(currentProperty == pAuthorAmazon){
	    [bookAuthors addObject:currentStringValue];
	    [self setBookAuthorsText:[NSString stringFromArray:bookAuthors withCombiner:@"and"]];
	}
	if(currentProperty == pPublisherAmazon){
	    [self setBookPublisher:currentStringValue];
	}
	if(currentProperty == pEdition){
	    [self setBookEdition:currentStringValue];
	}
	if(currentProperty == pPubDate){
	    [self setBookEdition:[NSString stringWithFormat:@"%@ %@", bookEdition, currentStringValue]];
	}
	if(currentProperty == pBinding){
	    [self setBookPhysicalDescrip:currentStringValue];
	}
	if(currentProperty == pNoPages){
	    [self setBookPhysicalDescrip:[NSString stringWithFormat:@"%@, %@ pages;", bookPhysicalDescrip, currentStringValue]];
	}

	if(currentProperty == pHeight){
	    [dimensions addObject:[NSString stringWithFormat:@"%.1fcm", [currentStringValue doubleValue]*HUNDREDTH_INCH_TO_CM]];
	    if([dimensions count] == 3)
		[self setBookPhysicalDescrip:[NSString stringWithFormat:@"%@ (%@)", 
							    bookPhysicalDescrip,
							    [NSString interleaveArray:dimensions with:@" x "]]];
	}
	if(currentProperty == pLength){
	    [dimensions addObject:[NSString stringWithFormat:@"%.1fcm", [currentStringValue doubleValue]*HUNDREDTH_INCH_TO_CM]];
	    if([dimensions count] == 3)
		[self setBookPhysicalDescrip:[NSString stringWithFormat:@"%@ (%@)", 
							    bookPhysicalDescrip,
							    [NSString interleaveArray:dimensions with:@" x "]]];
	}
	if(currentProperty == pWidth){
	    [dimensions addObject:[NSString stringWithFormat:@"%.1fcm", [currentStringValue doubleValue]*HUNDREDTH_INCH_TO_CM]];
	    if([dimensions count] == 3)
		[self setBookPhysicalDescrip:[NSString stringWithFormat:@"%@ (%@)", 
							    bookPhysicalDescrip,
							    [NSString interleaveArray:dimensions with:@" x "]]];
	}

	if(currentProperty == pWeight){
	    [self setBookPhysicalDescrip:[NSString stringWithFormat:@"%@ %.1f kilos ", bookPhysicalDescrip,
										       [currentStringValue doubleValue]*HUNDREDTH_POUND_TO_KG]];
	}
    }

    if(_CustomerReviews){
	if([elementName isEqualToString:@"Review"]){
	    [bookReviews addObject:currentReview];
	    [currentReview release];
	    currentReview = nil;
	}
	if(currentProperty == pReviewRating){
	    currentReview.rating = [currentStringValue doubleValue];
	}
	if(currentProperty == pReviewHelpfulVotes){
	    currentReview.helpfulVotes = [currentStringValue integerValue];
	}
	if(currentProperty == pReviewTotalVotes){
	    currentReview.totalVotes = [currentStringValue integerValue];
	}
	if(currentProperty == pReviewDate){
	    currentReview.date = currentStringValue;
	}
	if(currentProperty == pReviewSummary){
	    currentReview.summary = currentStringValue;
	}
	if(currentProperty == pReviewContent){
	    currentReview.content = [currentStringValue paragraphFormatAndStripHTML];
	}
	if(currentProperty == pReviewAverageRating){
	    bookAverageRating = [currentStringValue doubleValue];
	}
    }

    if(_EditorialReview){
	if(currentProperty == pEditorialContent){
	    [self setBookSummary:[currentStringValue paragraphFormatAndStripHTML]];
	}
    }

    if(_SimilarProducts){
	if(currentProperty == pASIN){
	    if(![similarProductASINs containsObject:currentStringValue])
		[similarProductASINs addObject:currentStringValue];
	}
    }

    currentProperty = pNone;
    if(currentStringValue){
	[currentStringValue release];
	currentStringValue = nil;
    }
    return;
}

@end
