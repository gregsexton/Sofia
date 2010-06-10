//
//  BooksMainViewController.m
//  books
//
//  Created by Greg on 10/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BooksMainViewController.h"


@implementation BooksMainViewController

- (void)removeSelectedItems{
    id item = [sideBar selectedItem];
    if([item isKindOfClass:[list class]]){
	NSArray* selectedBooks = [arrayController selectedObjects];
	[item removeBooks:[NSSet setWithArray:selectedBooks]];
	[arrayController fetch:self]; //reload filter
    }

    if([item isKindOfClass:[Library class]]){
	[application removeBookAction:self];
    }
}

@end
