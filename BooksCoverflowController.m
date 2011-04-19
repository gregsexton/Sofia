//
// BooksCoverflowController.m
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

#import "BooksCoverflowController.h"


@implementation BooksCoverflowController
@synthesize coverflow;
@synthesize mainTableView;
@synthesize tableViewSuper;

- (void)awakeFromNib{

    [coverflow setDelegate:self];
    [coverflow setDataSource:self];
    [coverflow reloadData];

    //register as an observer to keep the data up to date.
    [arrayController addObserver:self
		      forKeyPath:@"arrangedObjects"
			 options:NSKeyValueObservingOptionInitial //send message immediately
			 context:NULL];
    [arrayController addObserver:self
		      forKeyPath:@"selectedObjects"
			 options:NSKeyValueObservingOptionInitial //send message immediately
			 context:NULL];
}

- (void)addAndRepositionTableView{
    //this method needs to be called if the tableview has been
    //added to a different view hierarchy e.g when switching view
    if([mainTableView superview] != tableViewSuper){
	NSRect rect = [tableViewSuper frame];
	rect.origin.x = 0;
	rect.origin.y = 0;
	[mainTableView setFrame:rect];
	[tableViewSuper addSubview:mainTableView];
    }
}

///////////////////////    DELEGATE METHODS   ///////////////////////////////////////////////////

- (NSUInteger)numberOfItemsInCoverflow:(GSCoverflow*)aCoverflow{
    NSUInteger count = [[arrayController arrangedObjects] count];
    return count;
}

- (id)coverflow:(GSCoverflow*)aCoverflow itemAtIndex:(NSUInteger)index{
    book* theBook = [[arrayController arrangedObjects] objectAtIndex:index];
    NSImage* img = [theBook coverImageImage];
    if(img == nil) //use default image
	img = [NSImage imageNamed:@"missing_coverflow.png"];

    CGImageRef imgRep = [img CGImageForProposedRect:nil context:nil hints:nil];
    GSCoverflowItem* item = [[GSCoverflowItem alloc] initWithUID:[theBook title]
						  representation:imgRep
							   title:[theBook title]
							subtitle:[theBook authorText]];

    return [item autorelease];
}

- (void)observeValueForKeyPath:(NSString *)keyPath 
		      ofObject:(id)object 
			change:(NSDictionary *)change 
		       context:(void *)context{
    //this works nicely but will it be efficient enough for a large book collection?
    if([keyPath isEqualToString:@"arrangedObjects"]){
	[coverflow reloadData];
    }
    if([keyPath isEqualToString:@"selectedObjects"]){
	if([coverflow selectionIndex] != [arrayController selectionIndex]){
	    [coverflow setSelectionIndex:[arrayController selectionIndex]];
	}
    }
}

- (void)coverflow:(GSCoverflow*)aCoverflow cellWasDoubleClickedAtIndex:(NSUInteger)index{
    book *obj = [[arrayController arrangedObjects] objectAtIndex:index];

    [self openDetailWindowForBook:obj];
}

- (void)coverflowSelectionDidChange:(GSCoverflow*)aCoverflow{
    //let the arraycontroller know
    [arrayController setSelectionIndex:[coverflow selectionIndex]];
}


- (void)coverflow:(GSCoverflow*)aCoverflow cellWasRightClickedAtIndex:(NSUInteger)index
	withEvent:(NSEvent*)event{

    book *obj = [[arrayController arrangedObjects] objectAtIndex:index];
    NSMenu* menu = [self menuForBook:obj];

    [NSMenu popUpContextMenu:menu withEvent:event forView:aCoverflow];
}

- (NSUInteger)coverflow:(GSCoverflow*)aCoverflow writeItemsAtIndexes:(NSIndexSet*)itemIndexes
	   toPasteboard:(NSPasteboard*)pasteboard{

    [self writeBooksWithIndexes:itemIndexes toPasteboard:pasteboard];
    return [itemIndexes count];
}

//delegate method performed by booksWindowController.
- (void)saveClicked:(BooksWindowController*)booksWindowController {
    [super saveClicked:booksWindowController]; //this should be called first.
    //it is possible that the image has changed so need to force an update
    [coverflow reloadData];
}

@end
