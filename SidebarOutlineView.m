//
//  SidebarOutlineView.m
//  books
//
//  Created by Greg on 30/11/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SidebarOutlineView.h"

// TODO: seriously refactor out all the string literals!
// TODO: remove the disclosure triangles from headers
// TODO: make the header text just slightly smaller
// TODO: make it impossible to select headers

@implementation SidebarOutlineView

- (void)awakeFromNib {
    managedObjectContext = [application managedObjectContext];
    [super awakeFromNib];
    [self setDelegate:self];
    [self setDataSource:self];
    [self expandItem:nil expandChildren:true];
    [self assignLibraryObjects];
    [self setSelectedItem:@"Books"];
    [self registerForDraggedTypes:[NSArray arrayWithObjects:SofiaDragType, nil]];
}

- (void)assignLibraryObjects {

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
    [[self delegate]outlineViewSelectionDidChange:nil]; //FIXME: this will break if I start to use the notification in the delegate
}

- (Library*)selectedLibrary{
    return currentlySelectedLibrary;
}


// Delegate Methods //////////////////////////////////////////////////////

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

    [application updateSummaryText];
}

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
	[self addBook:theBook toList:item andSave:false];
    }

    [application saveAction:self];
    return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView 
		  validateDrop:(id < NSDraggingInfo >)info 
		  proposedItem:(id)item 
	    proposedChildIndex:(NSInteger)index{


    if([[self parentForItem:item] isEqualToString:@"BOOK LISTS"]){
	return NSDragOperationCopy;
    }else{
	return NSDragOperationNone;
    }
}

// Overridden Methods //////////////////////////////////////////////////////

- (void)keyDown:(NSEvent *)theEvent{
    NSLog(@"SidebarOutlineView: keyDown: %c", [[theEvent characters] characterAtIndex:0]);
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    if (key == NSDeleteCharacter || key == NSBackspaceCharacter){
	NSLog(@"NSDeleteCharacter or NSBackspaceCharacter pressed");
    }

}

@end
