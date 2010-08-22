//
// amazonInterface.h
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

#import <Cocoa/Cocoa.h>
#import "RegexKitLite.h"
#import "NSString+Sofia.h"

typedef enum {pNone,
	      pLargeImage, 
	      pImageURL, 
	      pTotalResults,
	      pDetailsPage,
	      pISBN10,
	      pISBN13,
	      pTitleAmazon,
	      pAuthorAmazon,
	      pPublisherAmazon,
	      pEdition,
	      pPubDate,
	      pBinding,
	      pNoPages,
	      pHeight,
	      pLength,
	      pWidth,
	      pWeight } amazonProperties;

#define HUNDREDTH_INCH_TO_CM 0.0254
#define HUNDREDTH_POUND_TO_KG 0.00453592

@interface amazonInterface : NSObject <NSXMLParserDelegate>{

    NSString*	accessKey;
    NSString*	secretAccessKey;

    NSURL*	amazonLink;
    NSString*	imageURL;
    NSImage*	frontCover;

    NSString*	    bookISBN10;
    NSString*	    bookISBN13;
    NSString*	    bookTitle;
    NSString*	    bookAuthorsText;
    NSString*	    bookPublisher;
    NSString*	    bookEdition;
    NSString*	    bookPhysicalDescrip;
    NSString*	    bookSummary;

    NSMutableArray* bookAuthors;
    NSMutableArray* dimensions;

    amazonProperties currentProperty;
    BOOL _ItemAttributes;

    NSMutableString* currentStringValue;
    BOOL successfullyFoundBook; 
}

@property (nonatomic,copy) NSString*	imageURL;
@property (nonatomic,copy) NSImage*	frontCover;
@property (nonatomic,copy) NSURL*	amazonLink;
@property (nonatomic,copy) NSString*	bookISBN10;
@property (nonatomic,copy) NSString*	bookISBN13;
@property (nonatomic,copy) NSString*	bookTitle;
@property (nonatomic,copy) NSString*	bookAuthorsText;
@property (nonatomic,copy) NSString*	bookPublisher;
@property (nonatomic,copy) NSString*	bookEdition;
@property (nonatomic,copy) NSString*	bookPhysicalDescrip;
@property (nonatomic,copy) NSString*	bookSummary;
@property (nonatomic)	   BOOL		successfullyFoundBook;

- (BOOL)searchISBN:(NSString*)isbn;
- (BOOL)searchForDetailsWithISBN:(NSString*)isbn;
- (NSAttributedString*)getTableOfContentsFromURL:(NSURL*)url;
@end
