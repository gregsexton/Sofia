//
// SidebarOutlineView.m
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

//TODO: this class acts as the view and the controller performing all logic for anything to do with
//libraries, lists or smart lists as well as predicates for filtering. Extract a controller class!

#import "SidebarOutlineView.h"

@implementation SidebarOutlineView
@synthesize bookLists;
@synthesize smartBookLists;
@synthesize selectedPredicate;

- (void)awakeFromNib {
    [super awakeFromNib];

    managedObjectContext = [application managedObjectContext];

    [self assignLibraryObjects];
    [self registerForDraggedTypes:[NSArray arrayWithObjects:SofiaDragType, nil]];
    [self setDelegate:self];
    [self setDataSource:self];

    NSTableColumn* tableColumn = [[self tableColumns] objectAtIndex:0];
    ImageAndTextCell* imageAndTextCell = [[[ImageAndTextCell alloc] init] autorelease];
    [imageAndTextCell setEditable: YES];
    [tableColumn setDataCell:imageAndTextCell];

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

- (void)dealloc{
    [bookLibrary release];
    [shoppingListLibrary release];
    if(bookLists)
        [bookLists release];
    if(smartBookLists)
        [smartBookLists release];
    [super dealloc];
}

- (NSFetchRequest*)libraryExistsWithName:(NSString*)libraryName{
    //returns the request in order to get hold of the library
    //otherwise returns nil if the library cannot be found.
    NSError *error;
    NSString *predicate = [[NSString alloc] initWithFormat:@"name MATCHES '%@'", [libraryName escapeSingleQuote]];

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Library" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:predicate]];

    [predicate release];

    if([managedObjectContext countForFetchRequest:request error:&error] > 0){
	return [request autorelease];
    }else{
	[request release];
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
    //TODO: hold option key and click for this
    NSManagedObjectModel *managedObjectModel = [application managedObjectModel];

    smartList* obj = [[smartList alloc] initWithEntity:[[managedObjectModel entitiesByName] objectForKey:@"smartList"]
			insertIntoManagedObjectContext:managedObjectContext];

    [application saveAction:self];
    [self reloadData];
    [self setSelectedItem:obj];
    [self beginEditingCurrentlySelectedItem];
}

- (IBAction)applyFilterToCurrentView:(id)sender{

    [self setupToApplyFilter];
    //display predicate editor, delegate method handles applying filter

    PredicateEditorWindowController *predWin = [[PredicateEditorWindowController alloc] init];
    [predWin setDelegate:self];
    [predWin setLists:[self getBookLists]];
    [predWin setSmartLists:[self getSmartBookLists]];
    if (![NSBundle loadNibNamed:@"PredicateEditor" owner:predWin]) {
        NSLog(@"Error loading Nib!");
    }
}

- (IBAction)removeFilterFromCurrentView:(id)sender{
    [self removeCurrentFilter];
}

- (IBAction)showBooksWithoutAnAuthor:(id)sender{
    [self setSelectedItem:bookLibrary];
    [self programaticallyApplyFilterToCurrentView:[NSPredicate predicateWithFormat:@"authors.@count == 0"]];
}

- (IBAction)showBooksWithoutASubject:(id)sender{
    [self setSelectedItem:bookLibrary];
    [self programaticallyApplyFilterToCurrentView:[NSPredicate predicateWithFormat:@"subjects.@count == 0"]];
}

- (void)programaticallyApplyFilterToCurrentView:(NSPredicate*)predicate{
    [self setupToApplyFilter];
    [self predicateEditingDidFinish:predicate];
}

- (void)setupToApplyFilter{
    [self removeCurrentFilter]; //does nothing if no filter applied
    //invariant: if selectedPredicate is not nil then a filter is being applied
    [self setSelectedPredicate:[self getPredicateForSelectedItem]];
}

- (NSUInteger)numberOfBookLists{
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"list" inManagedObjectContext:managedObjectContext]];

    NSUInteger count = [managedObjectContext countForFetchRequest:request error:&error];
    [request release];
    return count;
}

- (NSUInteger)numberOfSmartBookLists{
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"smartList" inManagedObjectContext:managedObjectContext]];

    NSUInteger count = [managedObjectContext countForFetchRequest:request error:&error];
    [request release];
    return count;
}

- (NSArray*)getBookLists{
    [self setBookLists:[self getAllManagedObjectsWithEntityName:@"list" sortDescriptorKey:@"name"]];
    return [self bookLists];
}

- (NSArray*)getSmartBookLists{
    [self setSmartBookLists:[self getAllManagedObjectsWithEntityName:@"smartList" sortDescriptorKey:@"name"]];
    return [self smartBookLists];
}

- (NSArray*)getAllManagedObjectsWithEntityName:(NSString*)entityName sortDescriptorKey:(NSString*)sortKey{
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext]];

    NSArray* objects = [managedObjectContext executeFetchRequest:request error:&error];
    NSSortDescriptor* descriptor = [[[NSSortDescriptor alloc] initWithKey:sortKey
								ascending:YES] autorelease];
    objects = [objects sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];

    [request release];

    return objects;
}

- (BOOL)listOrSmartlistAlreadyNamed:(NSString*)name notIncluding:(NSManagedObject*)obj{
    NSArray* lists = [self getBookLists];
    NSArray* slists = [self getSmartBookLists];

    //this could be a binary search as these arrays are sorted based on name.
    for(list* l in lists){
	if([[l name] isEqualToString:name] && l!=obj)
	    return true;
    }
    for(smartList* l in slists){
	if([[l name] isEqualToString:name] && l!=obj)
	    return true;
    }
    return false;
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
    [self outlineViewSelectionDidChange:nil]; //this will break if the notification is used in the delegate
}

- (Library*)selectedLibrary{
    return currentlySelectedLibrary;
}

- (id)selectedItem{
    return [self itemAtRow:[self selectedRow]];
}

- (void)removeCurrentlySelectedItem{
    id item = [self selectedItem];

    if([item isKindOfClass:[list class]] || [item isKindOfClass:[smartList class]]){
	int alertReturn = NSRunAlertPanel(@"Remove List?", @"Are you sure you wish to permanently remove this book list from Sofia?",
				  @"No", @"Yes", nil);
	if (alertReturn == NSAlertAlternateReturn){
	    //check for last item deleted and select book library
	    if([item isKindOfClass:[list class]] && [[self getBookLists] count] == 0)
		[self setSelectedItem:bookLibrary];
	    if([item isKindOfClass:[smartList class]] && [[self getSmartBookLists] count] == 0)
		[self setSelectedItem:bookLibrary];

	    //don't select the list below if this is the last list
	    if(item == [[self getBookLists] lastObject] || item == [[self getSmartBookLists] lastObject])
		[self setSelectedItem:bookLibrary];

	    [managedObjectContext deleteObject:item];
	    [application saveAction:self];
	    [self reloadData];
	}
    }
}

- (void)beginEditingCurrentlySelectedItem{
    [self editColumn:0
		 row:[self selectedRow]
	   withEvent:nil
	      select:YES];
}

- (void)editCurrentlySelectedSmartList{
    id item = [self selectedItem];
    if([item isKindOfClass:[smartList class]]){
	smartList* list = item;
	PredicateEditorWindowController *predWin = [[PredicateEditorWindowController alloc] initWithSmartList:list];
	[predWin setDelegate:self];
        [predWin setLists:[self getBookLists]];
        [predWin setSmartLists:[self getSmartBookLists]];
	if (![NSBundle loadNibNamed:@"PredicateEditor" owner:predWin]) {
	    NSLog(@"Error loading Nib!");
	}
    }
}

- (NSPredicate*)getPredicateForSelectedItem{
    id item = [self selectedItem];
    NSString *predString = nil;

    currentlySelectedLibrary = bookLibrary; //default to bookLibrary, unless specified

    if([item isKindOfClass:[Library class]]){
	predString = [[NSString alloc] initWithFormat:@"library.name MATCHES '%@'", [[item name] escapeSingleQuote]];

	if([[item name] isEqualToString:SHOPPING_LIST_LIBRARY]){
	    currentlySelectedLibrary = shoppingListLibrary;
	}

    }else if([item isKindOfClass:[list class]]){
	predString = [[NSString alloc] initWithFormat:@"ANY lists.name MATCHES '%@'", [[item name] escapeSingleQuote]];

    }else if([item isKindOfClass:[smartList class]]){
	smartList* list = item;
	NSString* filter = [list filter];
	predString = [filter retain]; //retained as about to be released due to alloc's above
    }

    if(predString != nil){
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
	[predString release];
	return predicate;
    }

    return nil;
}

- (void)updateFilterPredicateWith:(NSPredicate*)predicate{

    NSPredicate* pred = predicate;

    //invariant: if selectedPredicate is not nil then a filter is being applied
    if([self selectedPredicate]){
        //apply the filter AND the current predicate
        NSArray* preds = [NSArray arrayWithObjects:pred, [self selectedPredicate], nil];
        pred = [NSCompoundPredicate andPredicateWithSubpredicates:preds];
    }

    [arrayController setFilterPredicate:pred];
    [application updateSummaryText];
    [searchField setStringValue:@""]; //clear out anything in search

}

- (void)addToCurrentLibraryTheBook:(book*)obj{
    Library *lib = [self selectedLibrary];
    [lib addBooksObject:obj];

    id item = [self selectedItem];
    if([item isKindOfClass:[list class]]){
	[self addBook:obj toList:item andSave:false];
    }
}

- (void)removeCurrentFilter{
    //does nothing if no filter applied
    if([self selectedPredicate]){
        //filter applied
        NSPredicate* oldPred = [[self selectedPredicate] copy];
        [self setSelectedPredicate:nil];
        [self updateFilterPredicateWith:oldPred];

        [application hideFilterNotificationView];
        [removeFilterMenuItem setEnabled:NO];
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
		return bookLibrary;
	    case 1:
		return shoppingListLibrary;
	}
    }
    if([item isEqualToString:CAT_BOOK_LISTS]){
	NSArray *lists = [self getBookLists];
	list *list = [lists objectAtIndex:index];
	return list;
    }

    if([item isEqualToString:CAT_SMART_BOOK_LISTS]){
	NSArray *lists = [self getSmartBookLists];
	smartList *list = [lists objectAtIndex:index];
	return list;
    }

    return @"ERROR!";
}

- (id)outlineView:(NSOutlineView *)outlineView persistentObjectForItem:(id)item{
    return item;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item{
    if([item isKindOfClass:[NSString class]]){
	return item;
    }else if([item isKindOfClass:[list class]]){
	return [item name];
    }else if([item isKindOfClass:[smartList class]]){
	return [item name];
    }else if([item isKindOfClass:[Library class]]){
	return [item name];
    }
    return @"Error!";
}

- (void)outlineView:(NSOutlineView*)olv willDisplayCell:(NSCell*)cell forTableColumn:(NSTableColumn*)tableColumn item:(id)item{
    if([item isKindOfClass:[NSString class]]){

	[(ImageAndTextCell*)cell setImage:nil];

    }else if([item isKindOfClass:[list class]]){

	[(ImageAndTextCell*)cell setImage:[NSImage imageNamed:@"list.tif"]];

    }else if([item isKindOfClass:[smartList class]]){

	[(ImageAndTextCell*)cell setImage:[NSImage imageNamed:@"smartlist.tif"]];

    }else if([item isKindOfClass:[Library class]]){

	if([[item name] isEqualToString:BOOK_LIBRARY]){

	    [(ImageAndTextCell*)cell setImage:[NSImage imageNamed:@"book.tif"]];

	}else if([[item name] isEqualToString:SHOPPING_LIST_LIBRARY]){

	    [(ImageAndTextCell*)cell setImage:[NSImage imageNamed:@"shopping2.tif"]];
	}
    }else{
	[(ImageAndTextCell*)cell setImage:nil];
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
    }
    if([item isKindOfClass:[Library class]]){
	if([[item name] isEqualToString:BOOK_LIBRARY]){
	    return false;
	}
	if([[item name] isEqualToString:SHOPPING_LIST_LIBRARY]){
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
    NSString *newName = [fieldEditor string];
    id item = [self selectedItem];

    if([newName isEqualToString:@""] || [self listOrSmartlistAlreadyNamed:newName notIncluding:item]){
	return false;
    }

    if([item isKindOfClass:[list class]]){
	list *theList = item;
	[theList setName:[NSString stringWithString:newName]];
    }

    if([item isKindOfClass:[smartList class]]){
	smartList *theList = item;
	[theList setName:[NSString stringWithString:newName]];
    }

    [application saveAction:self];
    [self reloadData]; //reorder and then reselect
    [self setSelectedItem:item];
    return true;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification{

    [self removeCurrentFilter];

    NSPredicate* predicate = [self getPredicateForSelectedItem];
    [self updateFilterPredicateWith:predicate];

}

//delegate methods for PredicateEditorWindowController.

- (void)predicateEditingDidFinish:(NSPredicate*)predicate{
    //invariant: if selectedPredicate is not nil then a filter is being applied
    if([self selectedPredicate]){
        //filter being applied
        [application revealFilterNotificationView];
        [removeFilterMenuItem setEnabled:YES];
    }

    [self updateFilterPredicateWith:predicate];
}

- (void)predicateEditingWasCancelled{
    [self removeCurrentFilter];
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
	book* theBook = (book*)[managedObjectContext objectWithID:objId];

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

    if([[self selectedItem] isKindOfClass:[smartList class]]){
	[theMenu insertItemWithTitle:@"Edit Smart Book List"
			      action:@selector(editCurrentlySelectedSmartList)
		       keyEquivalent:@""
			     atIndex:2];
    }

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
