//
//  BooksImageBrowserController.m
//  books
//
//  Created by Greg on 09/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BooksImageBrowserController.h"


@implementation BooksImageBrowserController
@synthesize imageZoomLevel;

- (void)awakeFromNib {
    [browserView setDelegate:self];
    [browserView setDataSource:self];

    [browserView reloadData];
    //register as an observer to keep the data up to date.
    [arrayController addObserver:self
		      forKeyPath:@"arrangedObjects"
			 options:NSKeyValueObservingOptionInitial //send message immediately
			 context:NULL];

    float zoom = [[NSUserDefaults standardUserDefaults] floatForKey:@"imageViewZoomLevel"];
    [self setImageZoomLevel:zoom];
}

- (void) setImageZoomLevel:(float)newValue {
    //custom setter
    imageZoomLevel = newValue;
    [[NSUserDefaults standardUserDefaults] setFloat:newValue forKey:@"imageViewZoomLevel"];
}

// Delegate Methods //////////////////////////////////////////////////////

- (NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView *) aBrowser{	
    NSUInteger count = [[arrayController arrangedObjects] count];
    return count;
}

- (id)imageBrowser:(IKImageBrowserView *)aBrowser itemAtIndex:(NSUInteger)index{
    book* theBook = [[arrayController arrangedObjects] objectAtIndex:index];
    NSImage* img = [theBook coverImage];
    if(img == nil) //use default image
	img = [NSImage imageNamed:@"missing.png"];
    return [[BooksImageBrowserItem alloc] initWithImage:img 
						imageID:[theBook title] 
					       subtitle:[theBook authorText]];
}

- (void)imageBrowser:(IKImageBrowserView *)aBrowser cellWasDoubleClickedAtIndex:(NSUInteger)index{
    book *obj = [[arrayController arrangedObjects] objectAtIndex:index];

    BooksWindowController *detailWin = [[BooksWindowController alloc] initWithManagedObject:obj
										 withSearch:NO];
    if (![NSBundle loadNibNamed:@"Detail" owner:detailWin]) {
	NSLog(@"Error loading Nib!");
    }
}

//TODO: this works nicely but will it be efficient enough for a large book collection?
- (void)observeValueForKeyPath:(NSString *)keyPath 
		      ofObject:(id)object 
			change:(NSDictionary *)change 
		       context:(void *)context{
    if([keyPath isEqualToString:@"arrangedObjects"]){
	[browserView reloadData];
    }
}

- (void) imageBrowserSelectionDidChange:(IKImageBrowserView *) aBrowser{
    //let the arraycontroller know
    [arrayController setSelectionIndexes:[browserView selectionIndexes]];
}

- (NSUInteger)imageBrowser:(IKImageBrowserView *)aBrowser writeItemsAtIndexes:(NSIndexSet *)itemIndexes toPasteboard:(NSPasteboard *)pasteboard{
    [self writeBooksWithIndexes:itemIndexes toPasteboard:pasteboard];
    return [itemIndexes count];
}

@end
