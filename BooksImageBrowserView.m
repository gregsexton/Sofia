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

    //setup colors TODO: have these as user preferences?
    //[self setValue:[NSColor darkGrayColor] forKey:IKImageBrowserBackgroundColorKey];

    [self reloadData];
    //register as an observer to keep the data up to date.
    [arrayController addObserver:self
		      forKeyPath:@"arrangedObjects"
			 options:NSKeyValueObservingOptionInitial //send message immediately
			 context:NULL];
}

- (NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView *) aBrowser{	
    NSUInteger* count = [[arrayController arrangedObjects] count];
    return count;
}

- (id)imageBrowser:(IKImageBrowserView *)aBrowser itemAtIndex:(NSUInteger)index{
    book* theBook = [[arrayController arrangedObjects] objectAtIndex:index];
    NSImage* img = [theBook coverImage];
    return [[BooksImageBrowserItem alloc] initWithImage:img imageID:[theBook title] subtitle:[theBook authorText]];
}

- (void)imageBrowser:(IKImageBrowserView *)aBrowser cellWasDoubleClickedAtIndex:(NSUInteger)index{
    book *obj = [[arrayController arrangedObjects] objectAtIndex:index];

    BooksWindowController *detailWin = [[BooksWindowController alloc] initWithManagedObject:obj
										 withSearch:NO];
    if (![NSBundle loadNibNamed:@"Detail" owner:detailWin]) {
	NSLog(@"Error loading Nib!");
    }
}

//TODO: this works nicely but will it be efficient enough for a large
//book collection?
- (void)observeValueForKeyPath:(NSString *)keyPath 
		      ofObject:(id)object 
			change:(NSDictionary *)change 
		       context:(void *)context{
    if([keyPath isEqualToString:@"arrangedObjects"]){
	[self reloadData];
    }
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////

//The item to be used by BooksImageBrowserView
@implementation BooksImageBrowserItem

- (id)initWithImage:(NSImage*)anImage imageID:(NSString*)anImageID subtitle:(NSString*)aSubtitle{
    if (self = [super init]) {
	    image = [anImage copy];
	    imageID = [anImageID copy];
	    imageSub = [aSubtitle copy];
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

- (NSString*) imageSubtitle{
    return imageSub;
}

@end
