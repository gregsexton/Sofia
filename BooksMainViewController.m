//
// BooksMainViewController.m
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

#import "BooksMainViewController.h"


@implementation BooksMainViewController
@synthesize arrayController;
@synthesize sideBar;
@synthesize application;

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

- (void)writeBooksWithIndexes:(NSIndexSet*)rowIndexes toPasteboard:(NSPasteboard*)pboard{
    [pboard declareTypes:[NSArray arrayWithObject:SofiaDragType] owner:self];

    //get an array of URIs for the selected objects
    NSMutableArray* rows = [NSMutableArray array];
    NSArray* selectedObjects = [[arrayController arrangedObjects] objectsAtIndexes:rowIndexes];

    for (NSManagedObject* o in selectedObjects) {
	[rows addObject:[[o objectID] URIRepresentation]];
    }

    NSData* encodedIDs = [NSKeyedArchiver archivedDataWithRootObject:rows];

    [pboard setData:encodedIDs forType:SofiaDragType];
}

- (void)openDetailWindowForBook:(book*)obj{
    BooksWindowController *detailWin = [[BooksWindowController alloc] initWithManagedObject:obj
                                                                                    withApp:application
										 withSearch:NO];
    [detailWin setDelegate:self];
    [detailWin loadWindow];
    //the application delegate will release the controller when the window closes.
    [[detailWin window] setDelegate:application];
}

// menu methods ////////////////////////////////////////////////////////

- (NSMenu*)menuForBook:(book*)bookObj{
    NSMenu *theMenu = [[[NSMenu alloc] initWithTitle:@"Contextual Menu"] autorelease];

    [theMenu insertItemWithTitle:@"View Detail"
			  action:@selector(menuOpenDetailWindowForBook:)
		   keyEquivalent:@""
			 atIndex:0];
    [[theMenu itemAtIndex:0] setRepresentedObject:bookObj];
    [[theMenu itemAtIndex:0] setTarget:self];

    [theMenu insertItem:[NSMenuItem separatorItem]
		atIndex:1];

    [theMenu insertItemWithTitle:@"Remove Book"
			  action:@selector(removeSelectedItems)
		   keyEquivalent:@""
			 atIndex:2];
    [[theMenu itemAtIndex:2] setTarget:self];

    [theMenu insertItemWithTitle:@"View Book On"
			  action:nil
		   keyEquivalent:@""
			 atIndex:3];
    [[theMenu itemAtIndex:3] setSubmenu:[self submenuViewBookOnForBook:bookObj]];

    return theMenu;
}

- (NSMenu*)submenuViewBookOnForBook:(book*)bookObj{

    NSMenu *theMenu = [[[NSMenu alloc] initWithTitle:@"Contextual Menu"] autorelease];

    NSDictionary* menuItems = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"viewBookOnMenu"];
    if(menuItems == nil)
	menuItems = [self createDefaultViewBookOnMenuItems];

    NSArray* sortedMenuItemsKeys = [[menuItems allKeys] sortedArrayUsingSelector:@selector(compare:)];
    int index = 0;
    for(NSString* key in sortedMenuItemsKeys){
	[theMenu insertItemWithTitle:key
			      action:@selector(menuOpenBrowserUrlForBook:)
		       keyEquivalent:@""
			     atIndex:index];
	[[theMenu itemAtIndex:index] setRepresentedObject:[self parseFormatString:[menuItems objectForKey:key] usingBook:bookObj]];
	[[theMenu itemAtIndex:index] setTarget:self];
	index++;
    }

    [theMenu insertItem:[NSMenuItem separatorItem] atIndex:index++];
    [theMenu insertItemWithTitle:@"Edit Menu..."
			  action:@selector(menuEditViewBookOnItems)
		   keyEquivalent:@""
			 atIndex:index];
    [[theMenu itemAtIndex:index] setTarget:self];

    return theMenu;
}

- (NSString*)parseFormatString:(NSString*)formatString usingBook:(book*)bookObj{
    NSString* retStr = formatString;
    retStr = [retStr stringByReplacingOccurrencesOfString:@"{isbn10}" withString:[bookObj isbn10]];
    retStr = [retStr stringByReplacingOccurrencesOfString:@"{isbn13}" withString:[bookObj isbn13]];
    retStr = [retStr stringByReplacingOccurrencesOfString:@"{title}" withString:[bookObj title]];

    retStr = [retStr stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];

    return retStr;
}

- (NSDictionary*)createDefaultViewBookOnMenuItems{

    NSArray* objects = [NSArray arrayWithObjects:@"http://www.google.co.uk/search?q={title}",
						 @"http://books.google.com/books?q=isbn:{isbn13}",
						 @"http://www.amazon.co.uk/s/url=search-alias%3Dstripbooks&field-keywords={isbn13}", nil];
    NSArray* keys = [NSArray arrayWithObjects:@"Google",
					      @"Google Books",
					      @"Amazon", nil];

    NSDictionary* dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"viewBookOnMenu"];
    return dict;
}

- (IBAction)menuOpenDetailWindowForBook:(id)sender{
    [self openDetailWindowForBook:[sender representedObject]];
}

- (IBAction)menuOpenBrowserUrlForBook:(id)sender{
    NSString* urlStr = [sender representedObject];
    NSURL* url = [NSURL URLWithString:urlStr];

    if(url == nil)
	NSRunInformationalAlertPanel(@"URL Error", @"The requested URL is invalid. Please try checking the URL used in the link editor.",
				     @"Ok", nil, nil);
    else
	[[NSWorkspace sharedWorkspace] openURL:url];
}

- (void)menuEditViewBookOnItems{
    ExternalLinkEditorController* control = [[ExternalLinkEditorController alloc] init];
    [control loadWindow];
    //the application delegate will release the controller when the window closes.
    [[control window] setDelegate:application]; //this is not a leak -- application releases the controller
}

// delegate methods ////////////////////////////////////////////////////

//delegate method performed by booksWindowController.
- (void)saveClicked:(BooksWindowController*)booksWindowController {
    //default behaviour does nothing. this is more a placeholder to be overridden
}

@end
