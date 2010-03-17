//
//  SidebarOutlineView.m
//  books
//
//  Created by Greg on 30/11/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SidebarOutlineView.h"

// TODO: seriously refactor out all the string literals!

@implementation SidebarOutlineView

- (void) awakeFromNib {
    managedObjectContext = [application managedObjectContext];
    [super awakeFromNib];
    [self setDelegate:self];
    [self setDataSource:self];
    [self expandItem:nil expandChildren:true];
    [self assignLibraryObjects];
    [self setSelectedItem:@"Books"];
    currentlySelectedLibrary = bookLibrary;
}

- (void) assignLibraryObjects {

    NSFetchRequest *request = [self libraryExistsWithName:@"Books"];
    if(request != nil){
	NSError *error;
	bookLibrary = [[[managedObjectContext executeFetchRequest:request error:&error] objectAtIndex:0] retain];
    }else{
	bookLibrary = [NSEntityDescription insertNewObjectForEntityForName:@"Library" inManagedObjectContext:managedObjectContext];
	[bookLibrary setName:@"Books"];
    }

    request = [self libraryExistsWithName:@"Shopping List"];
    if(request != nil){
	NSError *error;
	shoppingListLibrary = [[[managedObjectContext executeFetchRequest:request error:&error] objectAtIndex:0] retain];
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
    if([item isEqualToString:@"BOOK LISTS"]){
	NSArray *lists = [self getBookLists];
	list *list = [lists objectAtIndex:index];
	NSString *name = [NSString stringWithString:list.name];
	return [name retain];
    }

    return @"ERROR!";
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

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    if([item isEqualToString:@"LIBRARY"]){
	return false;
    }
    if([item isEqualToString:@"BOOK LISTS"]){
	return false;
    }
    if([item isEqualToString:@"SMART BOOK LISTS"]){
	return false;
    }
    if([item isEqualToString:@"Books"]){
	return false;
    }
    if([item isEqualToString:@"Shopping List"]){
	return false;
    }

    return true;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    if(item == nil){
	return 3;
    }
    if([item isEqualToString:@"LIBRARY"]){
	return 2;
    }
    if([item isEqualToString:@"BOOK LISTS"]){
	return [self numberOfBookLists];
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

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor{
    //TODO: make sure the new name isn't one of my names or already exists and return false

    NSString *newName = [fieldEditor string];

    //perform checks on the new name:
    if([newName isEqualToString:@""]){
	return false;
    }

    NSString *oldName = [self itemAtRow:[self selectedRow]];
    list *theList = [self getBookList:oldName];
    [oldName release];
    theList.name = newName;
    [application saveAction:self];
    return true;
}

- (void)setSelectedItem:(id)item {
    NSInteger itemIndex = [self rowForItem:item];
    if (itemIndex < 0) {
        return; //do nothing if item doesn't exist
    }

    [self selectRowIndexes:[NSIndexSet indexSetWithIndex:itemIndex] byExtendingSelection:NO];
}

- (Library*)selectedLibrary{
    return currentlySelectedLibrary;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification{
    //TODO update book count when selection changes

    NSInteger selectedRow = [self selectedRow];
    id item = [self itemAtRow:selectedRow];
    NSString *predString = nil;

    currentlySelectedLibrary = bookLibrary; //default to bookLibrary, unless specified

    if([item isEqualToString:@"Books"]){
	predString = [[NSString alloc] initWithFormat:@"library.name MATCHES '%@'", @"Books"];
    }

    if([item isEqualToString:@"Shopping List"]){
	predString = [[NSString alloc] initWithFormat:@"library.name MATCHES '%@'", @"Shopping List"];
	currentlySelectedLibrary = shoppingListLibrary;
    }

    if([[self parentForItem:item] isEqualToString:@"BOOK LISTS"]){
	predString = [[NSString alloc] initWithFormat:@"ANY lists.name MATCHES '%@'", item];
    }

    if(predString != nil){
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
	[arrayController setFilterPredicate:predicate];
    }
}

- (IBAction)addListAction:(id)sender{
    NSManagedObjectModel *managedObjectModel = [application managedObjectModel];

    list *obj = [[list alloc] initWithEntity:[[managedObjectModel entitiesByName] objectForKey:@"list"]
						    insertIntoManagedObjectContext:managedObjectContext];

    [application saveAction:self];
    [self reloadData];
    [self setSelectedItem:[obj name]];
}

- (NSUInteger)numberOfBookLists{
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"list" inManagedObjectContext:managedObjectContext]];

    NSInteger blah = [managedObjectContext countForFetchRequest:request error:&error];
    return blah;
}

- (NSArray*)getBookLists{
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"list" inManagedObjectContext:managedObjectContext]];

    return [managedObjectContext executeFetchRequest:request error:&error];
}

- (list*)getBookList:(NSString*)listName{
    NSError *error;
    //TODO: need to escape bad characters (e.g ') in listName; this probably applies elsewhere!
    NSString *predicate = [[NSString alloc] initWithFormat:@"name MATCHES '%@'", listName];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"list" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:predicate]];

    return [[managedObjectContext executeFetchRequest:request error:&error] objectAtIndex:0];
}


@end
