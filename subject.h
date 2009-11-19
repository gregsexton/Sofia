//
//  subject.h
//  books
//
//  Created by Greg on 16/11/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class book;

@interface subject :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* books;

@end


@interface subject (CoreDataGeneratedAccessors)
- (void)addBooksObject:(book *)value;
- (void)removeBooksObject:(book *)value;
- (void)addBooks:(NSSet *)value;
- (void)removeBooks:(NSSet *)value;

@end

