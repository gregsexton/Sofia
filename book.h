//
// book.h
//
// Copyright 2011 Greg Sexton
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

#import <CoreData/CoreData.h>

@class Library;
@class author;
@class list;
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
@property (nonatomic, retain) NSString * toc;
@property (nonatomic, retain) NSString * edition;
@property (nonatomic, retain) NSDecimalNumber * noOfCopies;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSString * subjectText;
@property (nonatomic, retain) NSString * titleLong;
@property (nonatomic, retain) id coverImage;
@property (nonatomic, retain) NSString * physicalDescription;
@property (nonatomic, retain) NSString * publisherText;
@property (nonatomic, retain) NSString * dewey;
@property (nonatomic, retain) NSString * urls;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSManagedObject * publisher;
@property (nonatomic, retain) NSSet* lists;
@property (nonatomic, retain) NSSet* subjects;
@property (nonatomic, retain) NSSet* authors;
@property (nonatomic, retain) Library * library;

@end


@interface book (CoreDataGeneratedAccessors)
- (void)addListsObject:(list *)value;
- (void)removeListsObject:(list *)value;
- (void)addLists:(NSSet *)value;
- (void)removeLists:(NSSet *)value;

- (void)addSubjectsObject:(subject *)value;
- (void)removeSubjectsObject:(subject *)value;
- (void)addSubjects:(NSSet *)value;
- (void)removeSubjects:(NSSet *)value;

- (void)addAuthorsObject:(author *)value;
- (void)removeAuthorsObject:(author *)value;
- (void)addAuthors:(NSSet *)value;
- (void)removeAuthors:(NSSet *)value;

@end

