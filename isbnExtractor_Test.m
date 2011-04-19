//
// isbnExtractor_Test.m
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

#import "isbnExtractor_Test.h"


@implementation isbnExtractor_Test

- (void) setUp{

    extract = [[isbnExtractor alloc] initWithContent:@"hello"];
    extract2 = [[isbnExtractor alloc] initWithContent:@"blah blah blah 0201558025 this is some text too"];
    extract3 = [[isbnExtractor alloc] initWithContent:@"0201558025, blah blah this is 978-1933988276 and also 978052142706x. This is not an isbn: 01234567891011."];
    extract4 = [[isbnExtractor alloc] initWithContent:@"9780521427061 0201558025 0201558025 9780521427067 0201558025."];

}

- (void) tearDown{

    [extract release];
    [extract2 release];
    [extract3 release];
    [extract4 release];

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

    NSArray* arr4 = [extract4 discoveredISBNs];
    GHAssertNotNil(arr4, @"Object created.");

    GHAssertEquals([arr count], (NSUInteger)0,  [arr description]);
    GHAssertEquals([arr2 count], (NSUInteger)1, [arr2 description]);
    GHAssertEquals([arr3 count], (NSUInteger)3, [arr3 description]);
    GHAssertEquals([arr4 count], (NSUInteger)5, [arr4 description]);

    GHAssertEqualObjects([arr3 objectAtIndex:1], @"9781933988276", [arr3 description]);
    GHAssertEqualObjects([arr3 objectAtIndex:0], @"0201558025", [arr3 description]);
    GHAssertEqualObjects([arr3 objectAtIndex:2], @"978052142706x", [arr3 description]);
}

-(void) testNoDuplicates{
    NSArray* arr = [extract4 discoveredISBNsWithoutDups];
    GHAssertNotNil(arr, @"Object created.");
    GHAssertEquals([arr count], (NSUInteger)3,  [arr description]);

    //test that they get sorted
    GHAssertEqualObjects([arr objectAtIndex:0], @"0201558025", [arr description]);
}

@end
