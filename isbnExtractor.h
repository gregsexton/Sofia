//
//  isbnExtractor.h
//  books
//
//  Created by Greg on 13/06/2010.
//  Copyright 2010 Greg Sexton Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RegexKitLite.h"

@interface isbnExtractor : NSObject {

    NSString* content;
    NSArray* isbns;

}

@property (assign) NSString* content;

- (id)initWithContent:(NSString*)content;
- (NSArray*)discoveredISBNs;
- (NSArray*)discoveredISBNsWithoutDups;

@end
