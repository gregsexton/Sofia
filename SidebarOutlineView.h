//
// SidebarOutlineView.h
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

@interface SidebarOutlineView : NSOutlineView <NSOutlineViewDelegate, NSOutlineViewDataSource, PredicateEditorWindowControllerDelegate> {

    IBOutlet NSArrayController *arrayController;
    IBOutlet SofiaApplication *application;
    IBOutlet NSSearchField *searchField;

    Library* bookLibrary;
    Library* shoppingListLibrary;
    Library* currentlySelectedLibrary;
    NSManagedObjectContext *managedObjectContext;

    NSArray* bookLists;
    NSArray* smartBookLists;

    //NOTE: this is used for filtering and is not an accurate reflection of the current selected predicate
    //invariant: if selectedPredicate is not nil then a filter is being applied
    NSPredicate* selectedPredicate;
    IBOutlet NSMenuItem* removeFilterMenuItem;

}

@property (nonatomic, copy) NSArray* bookLists;
@property (nonatomic, copy) NSArray* smartBookLists;
@property (nonatomic, retain) NSPredicate* selectedPredicate;

- (IBAction)addListAction:(id)sender;
- (IBAction)addSmartListAction:(id)sender;
- (IBAction)applyFilterToCurrentView:(id)sender;
- (IBAction)removeFilterFromCurrentView:(id)sender;
- (IBAction)showBooksWithoutASubject:(id)sender;
- (IBAction)showBooksWithoutAnAuthor:(id)sender;

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;

- (BOOL)listOrSmartlistAlreadyNamed:(NSString*)name notIncluding:(NSManagedObject*)obj;
- (Library*)selectedLibrary;
- (NSArray*)getAllManagedObjectsWithEntityName:(NSString*)entityName sortDescriptorKey:(NSString*)sortKey;
- (NSArray*)getBookLists;
- (NSArray*)getSmartBookLists;
- (NSFetchRequest*)libraryExistsWithName:(NSString*)libraryName;
- (NSPredicate*)getPredicateForSelectedItem;
- (NSUInteger)numberOfBookLists;
- (id)selectedItem;
- (void)addBook:(book*)theBook toList:(list*)theList andSave:(BOOL)save;
- (void)addToCurrentLibraryTheBook:(book*)obj;
- (void)assignLibraryObjects;
- (void)beginEditingCurrentlySelectedItem;
- (void)editCurrentlySelectedSmartList;
- (void)moveBook:(book*)theBook toLibrary:(Library*)theLibrary andSave:(BOOL)save;
- (void)programaticallyApplyFilterToCurrentView:(NSPredicate*)predicate;
- (void)removeCurrentFilter;
- (void)setSelectedItem:(id)item;
- (void)setupToApplyFilter;
- (void)updateFilterPredicateWith:(NSPredicate*)predicate;

@end
