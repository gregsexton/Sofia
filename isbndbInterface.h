//
//  isbndbInterface.h
//  books
//
//  Created by Greg Sexton on 06/09/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface isbndbInterface : NSObject {

    NSString *bookISBN10;
    NSString *bookISBN13;
    NSString *bookTitle;
    NSString *bookTitleLong;
    NSString *bookAuthorsText;
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
    int currentProperty;

    enum properties {pNoProperty, pTitle, pTitleLong, pAuthorText, pPublisher, pSummary, pNotes, pUrls, pAwards, pAuthor, pSubject};

}

@property (nonatomic,copy) NSString *bookISBN10;
@property (nonatomic,copy) NSString *bookISBN13;
@property (nonatomic,copy) NSString *bookTitle;
@property (nonatomic,copy) NSString *bookTitleLong;
@property (nonatomic,copy) NSString *bookAuthorsText;
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
@property (nonatomic) int currentProperty;

- (BOOL)searchISBN:(NSString*)isbn;
- (BOOL)processDetailsWithUrl:(NSURL*)url;

@end
