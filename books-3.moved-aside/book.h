//
//  book.h
//  books
//
//  Created by Greg on 16/11/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class author;
@class subject;

@interface book :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * isbn13;
@property (nonatomic, retain) NSString * dewey_normalised;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * isbn10;
@property (nonatomic, retain) NSString * authorText;
@property (nonatomic, retain) NSString * lccNumber;
@property (nonatomic, retain) NSString * awards;
@property (nonatomic, retain) NSString * edition;
@property (nonatomic, retain) NSString * noOfCopies;
@property (nonatomic, retain) NSString * subjectText;
@property (nonatomic, retain) NSString * titleLong;
@property (nonatomic, retain) NSString * physicalDescription;
@property (nonatomic, retain) NSString * publisherText;
@property (nonatomic, retain) NSString * dewey;
@property (nonatomic, retain) NSString * urls;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSManagedObject * publisher;
@property (nonatomic, retain) NSSet* subjects;
@property (nonatomic, retain) NSSet* authors;

@end


@interface book (CoreDataGeneratedAccessors)
- (void)addSubjectsObject:(subject *)value;
- (void)removeSubjectsObject:(subject *)value;
- (void)addSubjects:(NSSet *)value;
- (void)removeSubjects:(NSSet *)value;

- (void)addAuthorsObject:(author *)value;
- (void)removeAuthorsObject:(author *)value;
- (void)addAuthors:(NSSet *)value;
- (void)removeAuthors:(NSSet *)value;

@end

