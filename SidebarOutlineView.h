//
// SidebarOutlineView.h
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

#import <Cocoa/Cocoa.h>
#import "Library.h"
#import "SofiaApplication.h"
#import "list.h"
#import "smartList.h"
#import "ImageAndTextCell.h"
#import "PredicateEditorWindowController.h"

#define SofiaDragType @"SofiaDragType"

#define CAT_LIBRARY @"LIBRARY"
#define CAT_BOOK_LISTS @"BOOK LISTS"
#define CAT_SMART_BOOK_LISTS @"SMART BOOK LISTS"

#define BOOK_LIBRARY @"Books"
#define SHOPPING_LIST_LIBRARY @"Shopping List"

@interface SidebarOutlineView : NSOutlineView <NSOutlineViewDelegate, NSOutlineViewDataSource> {

    IBOutlet NSArrayController *arrayController;
    IBOutlet SofiaApplication *application;
    IBOutlet NSSearchField *searchField;

    Library* bookLibrary;
    Library* shoppingListLibrary;
    Library* currentlySelectedLibrary;
    NSManagedObjectContext *managedObjectContext;

}

- (IBAction)addListAction:(id)sender;
- (IBAction)addSmartListAction:(id)sender;

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
- (NSPredicate*)getPredicateForSelectedItem;
- (NSArray*)getAllManagedObjectsWithEntityName:(NSString*)entityName sortDescriptorKey:(NSString*)sortKey;
- (void) editCurrentlySelectedSmartList;
- (void)updateFilterPredicateWith:(NSPredicate*)predicate;
- (void)addToCurrentLibraryTheBook:(book*)obj;
- (BOOL)listOrSmartlistAlreadyNamed:(NSString*)name notIncluding:(NSManagedObject*)obj;
@end
