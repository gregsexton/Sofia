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

typedef enum {pNone,
	      pLargeImage, 
	      pImageURL, 
	      pTotalResults,
	      pDetailsPage} amazonProperties;

@interface amazonInterface : NSObject <NSXMLParserDelegate>{

    NSString* accessKey;
    NSString* secretAccessKey;

    NSURL*	amazonLink;
    NSString*	imageURL;
    NSImage*	frontCover;

    amazonProperties currentProperty;
    NSMutableString* currentStringValue;
    BOOL successfullyFoundBook; 
}

@property (nonatomic,copy) NSString*	imageURL;
@property (nonatomic,copy) NSImage*	frontCover;
@property (nonatomic,copy) NSURL*	amazonLink;
@property (nonatomic)	   BOOL		successfullyFoundBook;

- (BOOL)searchISBN:(NSString*)isbn;
- (BOOL)searchForDetailsWithISBN:(NSString*)isbn;
- (NSAttributedString*)getTableOfContentsFromURL:(NSURL*)url;
@end
