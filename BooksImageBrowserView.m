//
//  BooksImageBrowserView.m
//  books
//
//  Created by Greg on 02/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BooksImageBrowserView.h"


@implementation BooksImageBrowserView

- (void)awakeFromNib {
    [self setDelegate:self];
    [self setDataSource:self];
    [self reloadData];
}

- (NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView *) aBrowser{	
    NSUInteger* count = [[arrayController arrangedObjects] count];
    return count;
}

- (id)imageBrowser:(IKImageBrowserView *)aBrowser itemAtIndex:(NSUInteger)index{
    book* theBook = [[arrayController arrangedObjects] objectAtIndex:index];
    NSImage* img = [theBook coverImage];
    return [[BooksImageBrowserItem alloc] initWithImage:img imageID:[theBook title]];
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////

//The item to be used by BooksImageBrowserView
@implementation BooksImageBrowserItem

- (id)initWithImage:(NSImage*)anImage imageID:(NSString*)anImageID{
    if (self = [super init]) {
	    image = [anImage copy];
	    imageID = [anImageID copy];
    }
    return self;
}

- (void)dealloc{
    [image release];
    [imageID release];
    [super dealloc];
}

- (NSString *) imageUID{
    return imageID;
}

- (NSString *) imageRepresentationType{
    return IKImageBrowserNSImageRepresentationType;
}

- (id) imageRepresentation{
    return image;
}

- (NSString*) imageTitle{
    return imageID;
}

@end
