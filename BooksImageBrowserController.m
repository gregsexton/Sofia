//
// BooksImageBrowserController.m
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

#import "BooksImageBrowserController.h"


@implementation BooksImageBrowserController
@synthesize imageZoomLevel;
@synthesize sortByOptions;

- (void)awakeFromNib {
    [browserView setDelegate:self];
    [browserView setDataSource:self];

    [browserView reloadData];
    //register as an observer to keep the data up to date.
    [arrayController addObserver:self
		      forKeyPath:@"arrangedObjects"
			 options:NSKeyValueObservingOptionInitial //send message immediately
			 context:NULL];

    [arrayController addObserver:self
		      forKeyPath:@"sortDescriptors"
			 options:NSKeyValueObservingOptionInitial //send message immediately
			 context:NULL];

    float zoom = [[NSUserDefaults standardUserDefaults] floatForKey:@"imageViewZoomLevel"];
    [self setImageZoomLevel:zoom];

    [self createSortByOptions];
    [self updateSortPopupSelection];

    _currentVersion = 1; //gets incremented each time a book's image is _potentially_ updated.
}

- (void)dealloc{
    if(_sortDescriptors)
        [_sortDescriptors release];
    [super dealloc];
}

- (void)setImageZoomLevel:(float)newValue { //custom setter
    //custom setter
    imageZoomLevel = newValue;
    [[NSUserDefaults standardUserDefaults] setFloat:newValue forKey:@"imageViewZoomLevel"];
}

- (void)createSortByOptions{
    //this dictionary corresponds to the available sort options
    _sortDescriptors = [[NSDictionary dictionaryWithObjectsAndKeys:
       [NSSortDescriptor sortDescriptorWithKey:@"authorText"    ascending:YES], @"Author",
       [NSSortDescriptor sortDescriptorWithKey:@"edition"       ascending:YES], @"Edition",
       [NSSortDescriptor sortDescriptorWithKey:@"isbn10"        ascending:YES], @"ISBN 10",
       [NSSortDescriptor sortDescriptorWithKey:@"isbn13"        ascending:YES], @"ISBN 13",
       [NSSortDescriptor sortDescriptorWithKey:@"publisherText" ascending:YES], @"Publisher",
       [NSSortDescriptor sortDescriptorWithKey:@"read"          ascending:YES], @"Read",
       [NSSortDescriptor sortDescriptorWithKey:@"subjectText"   ascending:YES], @"Subject",
       [NSSortDescriptor sortDescriptorWithKey:@"title"         ascending:YES], @"Title", nil] retain];

    [self setSortByOptions:[[_sortDescriptors allKeys] sortedArrayUsingSelector:@selector(compare:)]];
}

- (void)updateSortPopupSelection{
    NSString* newKey = [[[arrayController sortDescriptors] objectAtIndex:0] key];

    for(NSString* dictKey in [_sortDescriptors allKeys]){
        if([newKey isEqualToString:[[_sortDescriptors objectForKey:dictKey] key]]){
            [sortPopup selectItemWithTitle:dictKey];
        }
    }
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
								      subtitle:[theBook authorText]
                                                                       version:_currentVersion];
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
        _currentVersion++;
	[browserView reloadData];
    }

    if([keyPath isEqualToString:@"sortDescriptors"]){
        [self updateSortPopupSelection];
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

//delegate method performed by booksWindowController.
- (void)saveClicked:(BooksWindowController*)booksWindowController {
    //it is possible that the image has changed so need to force a version update
    _currentVersion++;          //TODO: this is crappy...
    [browserView reloadData];
}

// Action Methods ////////////////////////////////////////////////////////

- (IBAction)sortSelectionChanged:(id)sender{

    NSPopUpButton* btn = (NSPopUpButton*)sender;

    //no check -- guaranteed to be there as popup button was built from dictionary.
    NSSortDescriptor* newSortDesc = [_sortDescriptors objectForKey:[btn titleOfSelectedItem]];
    NSSortDescriptor* currentDesc = [[arrayController sortDescriptors] objectAtIndex:0];

    if([currentDesc.key isEqualToString:newSortDesc.key]){
        newSortDesc = [currentDesc reversedSortDescriptor];
    }

    [arrayController setSortDescriptors:[NSArray arrayWithObject:newSortDesc]];
}

@end
