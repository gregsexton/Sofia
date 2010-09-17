//
// BooksCoverflowController.m
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

#import "BooksCoverflowController.h"


@implementation BooksCoverflowController

- (void)awakeFromNib{

    [coverflow setDelegate:self];
    [coverflow setDataSource:self];
    [coverflow reloadData];

    //register as an observer to keep the data up to date.
    [arrayController addObserver:self
		      forKeyPath:@"arrangedObjects"
			 options:NSKeyValueObservingOptionInitial //send message immediately
			 context:NULL];
}

///////////////////////    DELEGATE METHODS   ///////////////////////////////////////////////////

- (NSUInteger)numberOfItemsInCoverflow:(GSCoverflow*)aCoverflow{
    NSUInteger count = [[arrayController arrangedObjects] count];
    return count;
}

- (id)coverflow:(GSCoverflow*)aCoverflow itemAtIndex:(NSUInteger)index{
    book* theBook = [[arrayController arrangedObjects] objectAtIndex:index];
    NSImage* img = [theBook coverImage];
    if(img == nil) //use default image
	img = [NSImage imageNamed:@"missing.png"]; //TODO: change to be more coverflowy?

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

@end
