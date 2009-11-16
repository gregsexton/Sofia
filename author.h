//
//  author.h
//  books
//
//  Created by Greg on 15/11/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface author :  NSManagedObject  
{
}

@property (nonatomic, retain) NSSet* books;

@end


@interface author (CoreDataGeneratedAccessors)
- (void)addBooksObject:(NSManagedObject *)value;
- (void)removeBooksObject:(NSManagedObject *)value;
- (void)addBooks:(NSSet *)value;
- (void)removeBooks:(NSSet *)value;

@end

