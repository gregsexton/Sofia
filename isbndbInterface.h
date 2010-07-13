//
// isbndbInterface.h
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

typedef enum { pNoProperty, 
	       pTitle, 
	       pTitleLong, 
	       pAuthorText, 
	       pPublisher, 
	       pSummary, 
	       pNotes, 
	       pUrls, 
	       pAwards, 
	       pAuthor, 
	       pSubject 
}isbnProperties ;


@interface isbndbInterface : NSObject <NSXMLParserDelegate> {

    NSString *bookISBN10;
    NSString *bookISBN13;
    NSString *bookTitle;
    NSString *bookTitleLong;
    NSString *bookAuthorsText;
    NSString *bookSubjectText;
    NSString *bookPublisher;
    NSString *bookEdition;
    NSString *bookLanguage;
    NSString *bookPhysicalDescrip;
    NSString *bookLCCNumber;
    NSString *bookDewey;
    NSString *bookDeweyNormalized;
    NSString *bookSummary;
    NSString *bookNotes;
    NSString *bookUrls;
    NSString *bookAwards;
    NSMutableArray *bookSubjects;
    NSMutableArray *bookAuthors;

    NSMutableString *currentStringValue;
    isbnProperties currentProperty;
    BOOL successfullyFoundBook; 

}

@property (nonatomic,copy) NSString *bookISBN10;
@property (nonatomic,copy) NSString *bookISBN13;
@property (nonatomic,copy) NSString *bookTitle;
@property (nonatomic,copy) NSString *bookTitleLong;
@property (nonatomic,copy) NSString *bookAuthorsText;
@property (nonatomic,copy) NSString *bookSubjectText;
@property (nonatomic,copy) NSString *bookPublisher;
@property (nonatomic,copy) NSString *bookEdition;
@property (nonatomic,copy) NSString *bookLanguage;
@property (nonatomic,copy) NSString *bookPhysicalDescrip;
@property (nonatomic,copy) NSString *bookLCCNumber;
@property (nonatomic,copy) NSString *bookDewey;
@property (nonatomic,copy) NSString *bookDeweyNormalized;
@property (nonatomic,copy) NSString *bookSummary;
@property (nonatomic,copy) NSString *bookNotes;
@property (nonatomic,copy) NSString *bookUrls;
@property (nonatomic,copy) NSString *bookAwards;
@property (nonatomic,copy) NSMutableArray *bookSubjects;
@property (nonatomic,copy) NSMutableArray *bookAuthors;
@property (nonatomic) isbnProperties currentProperty;
@property (nonatomic) BOOL successfullyFoundBook;

- (BOOL)searchISBN:(NSString*)isbn;
- (BOOL)processDetailsWithUrl:(NSURL*)url;
- (NSString*) cleanUpString:(NSString*)theString andCapitalize:(BOOL)capitalize;

@end
