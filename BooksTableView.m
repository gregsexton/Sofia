//
//  BooksTableView.m
//  books
//
//  Created by Greg on 21/03/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
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

@end
