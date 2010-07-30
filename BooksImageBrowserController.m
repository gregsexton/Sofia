//
// BooksImageBrowserController.m
//
// Copyright 2010 Greg Sexton
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

- (void)setImageZoomLevel:(float)newValue { //custom setter
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
    BooksImageBrowserItem* item = [[BooksImageBrowserItem alloc] initWithImage:img 
								       imageID:[theBook title] 
								      subtitle:[theBook authorText]];
    return [item autorelease];
}

- (void)imageBrowser:(IKImageBrowserView *)aBrowser cellWasDoubleClickedAtIndex:(NSUInteger)index{
    book *obj = [[arrayController arrangedObjects] objectAtIndex:index];

    [self openDetailWindowForBook:obj];
}

- (void) imageBrowser:(IKImageBrowserView *)aBrowser cellWasRightClickedAtIndex:(NSUInteger)index 
	    withEvent:(NSEvent *)event{

    book *obj = [[arrayController arrangedObjects] objectAtIndex:index];
    NSMenu* menu = [self menuForBook:obj];

    [NSMenu popUpContextMenu:menu withEvent:event forView:aBrowser];

}

- (void)observeValueForKeyPath:(NSString *)keyPath 
		      ofObject:(id)object 
			change:(NSDictionary *)change 
		       context:(void *)context{
    //this works nicely but will it be efficient enough for a large book collection?
    if([keyPath isEqualToString:@"arrangedObjects"]){
	[browserView reloadData];
    }
}

- (void)imageBrowserSelectionDidChange:(IKImageBrowserView *) aBrowser{
    //let the arraycontroller know
    [arrayController setSelectionIndexes:[browserView selectionIndexes]];
}

- (NSUInteger)imageBrowser:(IKImageBrowserView *)aBrowser 
       writeItemsAtIndexes:(NSIndexSet *)itemIndexes 
	      toPasteboard:(NSPasteboard *)pasteboard{

    [self writeBooksWithIndexes:itemIndexes toPasteboard:pasteboard];
    return [itemIndexes count];
}

@end
