//
//  SidebarOutlineView.m
//  books
//
//  Created by Greg on 30/11/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SidebarOutlineView.h"

// TODO: use uri representation for items
// TODO: remove the disclosure triangles from headers
// TODO: make the header text just slightly smaller
// TODO: make it impossible to select headers
// TODO: searching displays all books!
// TODO: add right click context menus
// TODO: implement smart book lists
// TODO: create abiltiy to edit smart book lists predicate using new window 

@implementation SidebarOutlineView

- (void)awakeFromNib {
    managedObjectContext = [application managedObjectContext];
    [super awakeFromNib];
    [self setDelegate:self];
    [self setDataSource:self];
    [self expandItem:nil expandChildren:true];
    [self assignLibraryObjects];
    [self setSelectedItem:BOOK_LIBRARY];
    [self registerForDraggedTypes:[NSArray arrayWithObjects:SofiaDragType, nil]];

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
    [self setSelectedItem:[obj name]];
}

- (NSUInteger)numberOfBookLists{
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"list" inManagedObjectContext:managedObjectContext]];

    NSInteger count = [managedObjectContext countForFetchRequest:request error:&error];
    return count;
}

- (NSArray*)getBookLists{
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"list" inManagedObjectContext:managedObjectContext]];

    return [managedObjectContext executeFetchRequest:request error:&error];
}

- (void)addBook:(book*)theBook toList:(NSString*)theList andSave:(BOOL)save{
    list* lst = [self getBookList:theList];
    [lst addBooksObject:theBook];
    if(save){
	[application saveAction:self];
    }
}

- (void)moveBook:(book*)theBook toLibrary:(NSString*)theLibrary andSave:(BOOL)save{
    //get hold of the libraries
    Library* moveToLib = nil;
    Library* moveFromLib = theBook.library;

    if([theLibrary isEqualToString:BOOK_LIBRARY]){
	moveToLib = bookLibrary;
    }else if([theLibrary isEqualToString:SHOPPING_LIST_LIBRARY]){
	moveToLib = shoppingListLibrary;
    }else{
	return; //error!
    }

    [moveFromLib removeBooksObject:theBook];
    [moveToLib addBooksObject:theBook];

    if(save){
	[application saveAction:self];
    }
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

- (void)removeCurrentlySelectedList{
	NSString* item = [self selectedItem];
	if([[self parentForItem:item] isEqualToString:CAT_BOOK_LISTS]){
	    //confirm!
	    int alertReturn = NSRunAlertPanel(@"Remove List?", @"Are you sure you wish to permanently remove this book list from Sofia?",
				      @"No", @"Yes", nil);
	    if (alertReturn == NSAlertAlternateReturn){
		list* theListToDelete = [self getBookList:item];
		[managedObjectContext deleteObject:theListToDelete];
		[application saveAction:self];
		[self reloadData];
	    }
	}
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
		return BOOK_LIBRARY;
	    case 1:
		return SHOPPING_LIST_LIBRARY;
	}
    }
    if([item isEqualToString:CAT_BOOK_LISTS]){
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
    if([item isEqualToString:CAT_LIBRARY]){
	return true;
    }
    if([item isEqualToString:CAT_BOOK_LISTS]){
	return true;
    }
    if([item isEqualToString:CAT_SMART_BOOK_LISTS]){
	return true;
    }
    return false;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
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

    return true;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    if(item == nil){
	return 3;
    }
    if([item isEqualToString:CAT_LIBRARY]){
	return 2;
    }
    if([item isEqualToString:CAT_BOOK_LISTS]){
	return [self numberOfBookLists];
    }
    return 0;
}

- (BOOL)outlineView:(NSOutlineView*)outlineView isGroupItem:(id)item {
    if([item isEqualToString:CAT_LIBRARY]){
	return true;
    }
    if([item isEqualToString:CAT_BOOK_LISTS]){
	return true;
    }
    if([item isEqualToString:CAT_SMART_BOOK_LISTS]){
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

    NSString *oldName = [self selectedItem];
    list *theList = [self getBookList:oldName];
    [oldName release];
    theList.name = newName;
    [application saveAction:self];
    return true;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification{

    id item = [self selectedItem];
    NSString *predString = nil;

    currentlySelectedLibrary = bookLibrary; //default to bookLibrary, unless specified

    if([item isEqualToString:BOOK_LIBRARY]){
	predString = [[NSString alloc] initWithFormat:@"library.name MATCHES '%@'", BOOK_LIBRARY];
    }

    if([item isEqualToString:SHOPPING_LIST_LIBRARY]){
	predString = [[NSString alloc] initWithFormat:@"library.name MATCHES '%@'", SHOPPING_LIST_LIBRARY];
	currentlySelectedLibrary = shoppingListLibrary;
    }

    if([[self parentForItem:item] isEqualToString:CAT_BOOK_LISTS]){
	predString = [[NSString alloc] initWithFormat:@"ANY lists.name MATCHES '%@'", item];
    }

    if(predString != nil){
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
	[arrayController setFilterPredicate:predicate];
    }

    [application updateSummaryText];
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

	if([[self parentForItem:item] isEqualToString:CAT_LIBRARY]){

	    [self moveBook:theBook toLibrary:item andSave:false];

	    //refresh the filter
	    [managedObjectContext processPendingChanges];
	    [arrayController fetch:self];

	}else if([[self parentForItem:item] isEqualToString:CAT_BOOK_LISTS]){

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
    //can't drag from current selection into itself
	    return NSDragOperationNone;
    }

    if([[self parentForItem:item] isEqualToString:CAT_BOOK_LISTS]){
	return NSDragOperationCopy;

    }else if([[self parentForItem:item] isEqualToString:CAT_LIBRARY]){
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
	[self removeCurrentlySelectedList];
    }

    //TODO: pass on to next first responder if not going to handle it
}

@end
