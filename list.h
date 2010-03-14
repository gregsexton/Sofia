//
//  list.h
//  books
//
//  Created by Greg on 14/03/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class book;

@interface list :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* books;

@end


@interface list (CoreDataGeneratedAccessors)
- (void)addBooksObject:(book *)value;
- (void)removeBooksObject:(book *)value;
- (void)addBooks:(NSSet *)value;
- (void)removeBooks:(NSSet *)value;

@end

