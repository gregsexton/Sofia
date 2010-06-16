//
//  isbnExtractor_Test.m
//  books
//
//  Created by Greg on 13/06/2010.
//  Copyright 2010 Greg Sexton Software. All rights reserved.
//

#import "isbnExtractor_Test.h"


@implementation isbnExtractor_Test

- (void) setUp{

    extract = [[isbnExtractor alloc] initWithContent:@"hello"];
    extract2 = [[isbnExtractor alloc] initWithContent:@"blah blah blah 0201558025 this is some text too"];
    extract3 = [[isbnExtractor alloc] initWithContent:@"0201558025, blah blah this is 978-1933988276 and also 9780521427067"];

}

- (void) tearDown{

    [extract release];

}

-(void) testObjectCreation{

    GHAssertNotNil(extract, @"Object created.");
    GHAssertEqualObjects([extract content], @"hello", @"content is the same.");

}

-(void) testDiscoveredISBNs{

    NSArray* arr = [extract discoveredISBNs];
    GHAssertNotNil(arr, @"Object created.");

    NSArray* arr2 = [extract2 discoveredISBNs];
    GHAssertNotNil(arr2, @"Object created.");

    NSArray* arr3 = [extract3 discoveredISBNs];
    GHAssertNotNil(arr3, @"Object created.");

    GHAssertEquals([arr count], (NSUInteger)0,  @"arr should have 0 isbns.");
    GHAssertEquals([arr2 count], (NSUInteger)1,  @"arr should have 1 isbn.");
    GHAssertEquals([arr3 count], (NSUInteger)3,  @"arr should have 3 isbn.");

    GHAssertEqualObjects([arr3 objectAtIndex:1], @"9781933988276", @"hypen not removed from isbn.");
    GHAssertEqualObjects([arr3 objectAtIndex:0], @"0201558025", @"isbns not the same");
    GHAssertEqualObjects([arr3 objectAtIndex:2], @"9780521427067", @"isbns not the same");
}

@end
