//
//  SidebarOutlineView.m
//  books
//
//  Created by Greg on 30/11/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SidebarOutlineView.h"

// TODO: create abiltiy to edit smart book lists predicate using new window 
// TODO: icons! two columns?

@implementation SidebarOutlineView

- (void)awakeFromNib {
    [super awakeFromNib];
    managedObjectContext = [application managedObjectContext];
    [self assignLibraryObjects];
    [self registerForDraggedTypes:[NSArray arrayWithObjects:SofiaDragType, nil]];
    [self setDelegate:self];
    [self setDataSource:self];
    [self expandItem:nil expandChildren:true];
    [self setSelectedItem:bookLibrary];
}

- (void)assignLibraryObjects {

    NSFetchRequest *request = [self libraryExistsWithName:BOOK_LIBRARY];
    if(request != nil){
	NSError *error;
	bookLibrary = [[[managedObjectContext executeFetchRequest:request error:&error] objectAtIndex:0] retain];
    }else{
	bookLibrary = [NSEntityDescription insertNewObjectForEntityForName:@"Library" inManagedObjectContext:managedObjectContext];
	[bookLibrary setName:BOOK_LIBRARY];
    }

    request = [self libraryExistsWithName:SHOPPING_LIST_LIBRARY];
    if(request != nil){
	NSError *error;
	shoppingListLibrary = [[[managedObjectContext executeFetchRequest:request error:&error] objectAtIndex:0] retain];
    }else{
	shoppingListLibrary = [NSEntityDescription insertNewObjectForEntityForName:@"Library" inManagedObjectContext:managedObjectContext];
	[shoppingListLibrary setName:SHOPPING_LIST_LIBRARY];
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

- (IBAction)addListAction:(id)sender{
    NSManagedObjectModel *managedObjectModel = [application managedObjectModel];

    list *obj = [[list alloc] initWithEntity:[[managedObjectModel entitiesByName] objectForKey:@"list"]
						    insertIntoManagedObjectContext:managedObjectContext];

    [application saveAction:self];
    [self reloadData];
    [self setSelectedItem:obj];
    [self beginEditingCurrentlySelectedItem];
}

- (IBAction)addSmartListAction:(id)sender{
    NSManagedObjectModel *managedObjectModel = [application managedObjectModel];

    smartList* obj = [[smartList alloc] initWithEntity:[[managedObjectModel entitiesByName] objectForKey:@"smartList"] 
			insertIntoManagedObjectContext:managedObjectContext];

    [application saveAction:self];
    [self reloadData];
    [self setSelectedItem:obj];
    [self beginEditingCurrentlySelectedItem];
}

- (NSUInteger)numberOfBookLists{
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"list" inManagedObjectContext:managedObjectContext]];

    NSUInteger count = [managedObjectContext countForFetchRequest:request error:&error];
    return count;
}

- (NSUInteger)numberOfSmartBookLists{
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"smartList" inManagedObjectContext:managedObjectContext]];

    NSUInteger count = [managedObjectContext countForFetchRequest:request error:&error];
    return count;
}

- (NSArray*)getBookLists{
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"list" inManagedObjectContext:managedObjectContext]];

    return [managedObjectContext executeFetchRequest:request error:&error];
}

- (NSArray*)getSmartBookLists{
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"smartList" inManagedObjectContext:managedObjectContext]];

    return [managedObjectContext executeFetchRequest:request error:&error];
}

- (void)addBook:(book*)theBook toList:(list*)theList andSave:(BOOL)save{

    [theList addBooksObject:theBook];
    if(save){
	[application saveAction:self];
    }

}

- (void)moveBook:(book*)theBook toLibrary:(Library*)moveToLib andSave:(BOOL)save{

    Library* moveFromLib = [theBook library];

    [moveFromLib removeBooksObject:theBook];
    [moveToLib addBooksObject:theBook];

    if(save){
	[application saveAction:self];
    }
}

- (void)setSelectedItem:(id)item{
    NSInteger itemIndex = [self rowForItem:item];
    if (itemIndex < 0) {
        return; //do nothing if item doesn't exist
    }

    [self selectRowIndexes:[NSIndexSet indexSetWithIndex:itemIndex] byExtendingSelection:NO];
    //tell the delegate!
    [[self delegate] outlineViewSelectionDidChange:nil]; //FIXME: this will break if I start to use the notification in the delegate
}

- (Library*)selectedLibrary{
    return currentlySelectedLibrary;
}

- (id)selectedItem{
    return [self itemAtRow:[self selectedRow]];
}

- (void)removeCurrentlySelectedItem{
    //TODO: if you delete the last item it selects smart book lists
    id item = [self selectedItem];

    if([item isKindOfClass:[list class]] || [item isKindOfClass:[smartList class]]){
	int alertReturn = NSRunAlertPanel(@"Remove List?", @"Are you sure you wish to permanently remove this book list from Sofia?",
				  @"No", @"Yes", nil);
	if (alertReturn == NSAlertAlternateReturn){
	    [managedObjectContext deleteObject:item];
	    [application saveAction:self];
	    [self reloadData];
	}
    }
}

- (void) beginEditingCurrentlySelectedItem{
    [self editColumn:0
		 row:[self selectedRow]
	   withEvent:nil
	      select:YES];
}

- (NSPredicate*)getPredicateForSelectedItem{
    id item = [self selectedItem];
    NSString *predString = nil;

    currentlySelectedLibrary = bookLibrary; //default to bookLibrary, unless specified

    if([item isKindOfClass:[Library class]]){
	predString = [[NSString alloc] initWithFormat:@"library.name MATCHES '%@'", [item name]];

	if([[item name] isEqualToString:SHOPPING_LIST_LIBRARY]){
	    currentlySelectedLibrary = shoppingListLibrary;
	}
    }

    if([item isKindOfClass:[list class]]){
	predString = [[NSString alloc] initWithFormat:@"ANY lists.name MATCHES '%@'", [item name]];
    }

    if([item isKindOfClass:[smartList class]]){
	if([item filter] == nil || [[item filter] isEqualToString:@""]){
	    //TODO: don't display any books!
	}
	predString = [item filter];
    }

    if(predString != nil){
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
	return predicate;
    }

    return nil;
}

// Delegate Methods //////////////////////////////////////////////////////

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    if(item == nil){
	switch(index){
	    case 0:
		return CAT_LIBRARY;
	    case 1:
		return CAT_BOOK_LISTS;
	    case 2:
		return CAT_SMART_BOOK_LISTS;
	}
    }
    if([item isEqualToString:CAT_LIBRARY]){
	switch(index){
	    case 0:
		return bookLibrary;
	    case 1:
		return shoppingListLibrary;
	}
    }
    if([item isEqualToString:CAT_BOOK_LISTS]){
	NSArray *lists = [self getBookLists];
	list *list = [lists objectAtIndex:index];
	return [list retain];
    }

    if([item isEqualToString:CAT_SMART_BOOK_LISTS]){
	NSArray *lists = [self getSmartBookLists];
	smartList *list = [lists objectAtIndex:index];
	return [list retain];
    }

    return @"ERROR!";
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item{
    if([item isKindOfClass:[NSString class]]){
	return item;
    }else if([item isKindOfClass:[list class]]){
	return [[item name] retain];
    }else if([item isKindOfClass:[smartList class]]){
	return [[item name] retain];
    }else if([item isKindOfClass:[Library class]]){
	return [[item name] retain];
    }
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item{
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item{
    if([item isKindOfClass:[NSString class]]){
	return false;
    }else{
	return true;
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item{
    if([item isKindOfClass:[NSString class]]){
	if([item isEqualToString:CAT_LIBRARY]){
	    return false;
	}
    }

    return true;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item{
    if([item isKindOfClass:[NSString class]]){

	if([item isEqualToString:CAT_LIBRARY]){
	    return true;
	}
	if([item isEqualToString:CAT_BOOK_LISTS]){
	    return true;
	}
	if([item isEqualToString:CAT_SMART_BOOK_LISTS]){
	    return true;
	}
    }

    return false;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    if([item isKindOfClass:[NSString class]]){
	if([item isEqualToString:CAT_LIBRARY]){
	    return false;
	}
	if([item isEqualToString:CAT_BOOK_LISTS]){
	    return false;
	}
	if([item isEqualToString:CAT_SMART_BOOK_LISTS]){
	    return false;
	}
	if([item isEqualToString:BOOK_LIBRARY]){
	    return false;
	}
	if([item isEqualToString:SHOPPING_LIST_LIBRARY]){
	    return false;
	}
    }

    return true;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{

    if(item == nil){
	return 3;
    }

    if([item isKindOfClass:[NSString class]]){
	if([item isEqualToString:CAT_LIBRARY]){
	    return 2;
	}
	if([item isEqualToString:CAT_BOOK_LISTS]){
	    return [self numberOfBookLists];
	}
	if([item isEqualToString:CAT_SMART_BOOK_LISTS]){
	    return [self numberOfSmartBookLists];
	}
    }

    return 0;
}

- (BOOL)outlineView:(NSOutlineView*)outlineView isGroupItem:(id)item {

    if([item isKindOfClass:[NSString class]]){
	if([item isEqualToString:CAT_LIBRARY]){
	    return true;
	}
	if([item isEqualToString:CAT_BOOK_LISTS]){
	    return true;
	}
	if([item isEqualToString:CAT_SMART_BOOK_LISTS]){
	    return true;
	}
    }

    return false;
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor{
    //TODO: make sure the new name isn't one of my names or already exists and return false
    //TODO: renaming has a bug -- can't quite work it out...

    NSString *newName = [fieldEditor string];

    //perform checks on the new name:
    if([newName isEqualToString:@""]){
	return false;
    }

    if([[self selectedItem] isKindOfClass:[list class]]){
	list *theList = [self selectedItem];
	theList.name = newName;
    }

    if([[self selectedItem] isKindOfClass:[smartList class]]){
	smartList *theList = [self selectedItem];
	theList.name = newName;
    }

    [application saveAction:self];
    return true;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification{

    NSPredicate* predicate = [self getPredicateForSelectedItem];
    [arrayController setFilterPredicate:predicate];
    [application updateSummaryText];
    [searchField setStringValue:@""]; //clear out anything in search

}

//delegates for drag and drop

- (BOOL)outlineView:(NSOutlineView *)outlineView 
	 acceptDrop:(id < NSDraggingInfo >)info 
	       item:(id)item 
	 childIndex:(NSInteger)index{


    NSPasteboard* pBoard = [info draggingPasteboard];

    NSData* data = [pBoard dataForType:SofiaDragType];
    NSArray* theBooks = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    for(NSURL* objectURI in theBooks){
	NSManagedObjectID* objId = [[application persistentStoreCoordinator] managedObjectIDForURIRepresentation:objectURI];
	book* theBook = [managedObjectContext objectWithID:objId];

	if([item isKindOfClass:[Library class]]){

	    [self moveBook:theBook toLibrary:item andSave:false];

	    //refresh the filter
	    [managedObjectContext processPendingChanges];
	    [arrayController fetch:self];

	}else if([item isKindOfClass:[list class]]){

	    [self addBook:theBook toList:item andSave:false];

	}
    }

    [application saveAction:self];
    return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView 
		  validateDrop:(id < NSDraggingInfo >)info 
		  proposedItem:(id)item 
	    proposedChildIndex:(NSInteger)index{

    if([self selectedItem] == item){
	    return NSDragOperationNone; //can't drag from current selection into itself
    }

    if([item isKindOfClass:[list class]]){
	return NSDragOperationCopy;

    }else if([item isKindOfClass:[Library class]]){
	return NSDragOperationMove;

    }else{
	return NSDragOperationNone;
    }
}

// Overridden Methods //////////////////////////////////////////////////////

- (void)keyDown:(NSEvent *)theEvent{
    //NSLog(@"SidebarOutlineView: keyDown: %c", [[theEvent characters] characterAtIndex:0]);
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];

    if (key == NSDeleteCharacter || key == NSBackspaceCharacter){
	[self removeCurrentlySelectedItem];
    }else{
	//pass on to the next first responder
	[super keyDown:theEvent];
    }
}

-(NSMenu*)menuForEvent:(NSEvent*)evt{
    NSPoint pt = [self convertPoint:[evt locationInWindow] fromView:nil];
    int row = [self rowAtPoint:pt];

    [self setSelectedItem:[self itemAtRow:row]];

    NSMenu *theMenu = [[[NSMenu alloc] initWithTitle:@"Contextual Menu"] autorelease];
    [theMenu insertItemWithTitle:@"Rename"
			  action:@selector(beginEditingCurrentlySelectedItem)
		   keyEquivalent:@""
			 atIndex:0];

    [theMenu insertItemWithTitle:@"Delete"
			  action:@selector(removeCurrentlySelectedItem)
		   keyEquivalent:@""
			 atIndex:1];
    return theMenu;
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem{
    id item = [self selectedItem];
    NSString* title = [menuItem title];

    if([item isKindOfClass:[list class]]){
	return true; //everything is valid
    }
    
    if([item isKindOfClass:[smartList class]]){
	return true; //everything valid for now
    }
    
    if([title isEqualToString:@"Rename"]){
	return false;
    }else if([title isEqualToString:@"Delete"]){
	return false;
    }
    
    //shouldn't get here...
    return true;
}

@end
