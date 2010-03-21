//
//  SidebarOutlineView.h
//  books
//
//  Created by Greg on 30/11/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Library.h"
#import "SofiaApplication.h"
#import "list.h"

#define SofiaDragType @"SofiaDragType"

#define CAT_LIBRARY @"LIBRARY"
#define CAT_BOOK_LISTS @"BOOK LISTS"
#define CAT_SMART_BOOK_LISTS @"SMART BOOK LISTS"

#define BOOK_LIBRARY @"Books"
#define SHOPPING_LIST_LIBRARY @"Shopping List"

@interface SidebarOutlineView : NSOutlineView <NSOutlineViewDelegate, NSOutlineViewDataSource> {

    IBOutlet NSArrayController *arrayController;
    IBOutlet SofiaApplication *application;

    Library* bookLibrary;
    Library* shoppingListLibrary;
    Library* currentlySelectedLibrary;
    NSManagedObjectContext *managedObjectContext;

}

- (IBAction) addListAction:(id)sender;

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
- (void)setSelectedItem:(id)item;
- (Library*) selectedLibrary;
- (NSUInteger)numberOfBookLists;
- (void)addBook:(book*)theBook toList:(list*)theList andSave:(BOOL)save;
- (id)selectedItem;
- (void)moveBook:(book*)theBook toLibrary:(Library*)theLibrary andSave:(BOOL)save;
@end
