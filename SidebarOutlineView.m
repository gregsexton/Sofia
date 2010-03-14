//
//  SidebarOutlineView.m
//  books
//
//  Created by Greg on 30/11/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SidebarOutlineView.h"


@implementation SidebarOutlineView

- (void) awakeFromNib {
    [super awakeFromNib];
    [self setDelegate:self];
    [self setDataSource:self];
    [self expandItem:nil expandChildren:true];
    managedObjectContext = [application managedObjectContext];
    [self assignLibraryObjects];
    [self setSelectedItem:@"Books"];
    currentlySelectedLibrary = bookLibrary;
}

- (void) assignLibraryObjects {

    NSFetchRequest *request = [self libraryExistsWithName:@"Books"];
    if(request != nil){
	NSError *error;
	bookLibrary = [[managedObjectContext executeFetchRequest:request error:&error] objectAtIndex:0];
    }else{
	bookLibrary = [NSEntityDescription insertNewObjectForEntityForName:@"Library" inManagedObjectContext:managedObjectContext];
	[bookLibrary setName:@"Books"];
    }

    request = [self libraryExistsWithName:@"Shopping List"];
    if(request != nil){
	NSError *error;
	shoppingListLibrary = [[managedObjectContext executeFetchRequest:request error:&error] objectAtIndex:0];
    }else{
	shoppingListLibrary = [NSEntityDescription insertNewObjectForEntityForName:@"Library" inManagedObjectContext:managedObjectContext];
	[shoppingListLibrary setName:@"Shopping List"];
    }
}

- (NSFetchRequest*) libraryExistsWithName:(NSString*)libraryName{
    //returns the request in order to get hold of the library
    //otherwise returns nil if the library cannot be found.
    NSError *error;
    NSString *predicate = [[NSString alloc] initWithFormat:@"name MATCHES '%@'", libraryName];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Library" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:predicate]];
    if([managedObjectContext countForFetchRequest:request error:&error] > 0){
	return request;
    }else{
	return nil;
    }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    if(item == nil){
	switch(index){
	    case 0:
		return @"LIBRARY";
	    case 1:
		return @"BOOK LISTS";
	    case 2:
		return @"SMART BOOK LISTS";
	}
    }
    if([item isEqualToString:@"LIBRARY"]){
	switch(index){
	    case 0:
		return @"Books";
	    case 1:
		return @"Shopping List";
	    default:
		return @"Error!";
	}
    }
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item{
    return item;
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item{
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item{
    if([item isEqualToString:@"LIBRARY"]){
	return true;
    }
    if([item isEqualToString:@"BOOK LISTS"]){
	return true;
    }
    if([item isEqualToString:@"SMART BOOK LISTS"]){
	return true;
    }
    return false;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    if(item == nil){
	return 3;
    }
    if([item isEqualToString:@"LIBRARY"]){
	return 2;
    }
    return 0;
}

- (BOOL)outlineView:(NSOutlineView*)outlineView isGroupItem:(id)item {
    if([item isEqualToString:@"LIBRARY"]){
	return true;
    }
    if([item isEqualToString:@"BOOK LISTS"]){
	return true;
    }
    if([item isEqualToString:@"SMART BOOK LISTS"]){
	return true;
    }
    return false;
}

- (void)setSelectedItem:(id)item {
    NSInteger itemIndex = [self rowForItem:item];
    if (itemIndex < 0) {
        return; //do nothing if item doesn't exist
    }

    [self selectRowIndexes:[NSIndexSet indexSetWithIndex:itemIndex] byExtendingSelection:NO];
}

- (Library*) selectedLibrary{
    return currentlySelectedLibrary;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification{

    NSInteger selectedRow = [self selectedRow];
    id item = [self itemAtRow:selectedRow];
    NSString *predString = nil;

    if([item isEqualToString:@"Books"]){
	predString = [[NSString alloc] initWithFormat:@"library.name MATCHES '%@'", @"Books"];
	currentlySelectedLibrary = bookLibrary;
    }

    if([item isEqualToString:@"Shopping List"]){
	predString = [[NSString alloc] initWithFormat:@"library.name MATCHES '%@'", @"Shopping List"];
	currentlySelectedLibrary = shoppingListLibrary;
    }

    if(predString != nil){
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
	[arrayController setFilterPredicate:predicate];
    }
}

@end
