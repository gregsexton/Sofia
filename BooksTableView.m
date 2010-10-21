//
// BooksTableView.m
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

#import "BooksTableView.h"


@implementation BooksTableView

// Overridden Methods //////////////////////////////////////////////////////

- (void)keyDown:(NSEvent *)theEvent{
    //NSLog(@"SidebarOutlineView: keyDown: %c", [[theEvent characters] characterAtIndex:0]);
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];

    if (key == NSDeleteCharacter || key == NSBackspaceCharacter){
	[viewController removeSelectedItems];
    }else{
	//pass on to next first responder if not going to handle it
	[super keyDown:theEvent];
    }
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent{
    //select the item right clicked on
    NSPoint pt = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSInteger row = [self rowAtPoint:pt];
    [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];

    NSMenu* menu = [viewController menuForBook:[viewController currentlySelectedBook]];
    return menu;
}

@end
