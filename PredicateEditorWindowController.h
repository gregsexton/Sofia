//
// PredicateEditorWindowController.h
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
#import "smartList.h"
#import "PredicateEditorWindowControllerDelegate.h"

#define PRED_NOT_IN_SHOPPING_LIST @"NOT library.name MATCHES 'Shopping List'"

@interface PredicateEditorWindowController : NSObject {

    IBOutlet NSWindow*		    window;
    IBOutlet NSPredicateEditor*	    predicateEditor;

    id<PredicateEditorWindowControllerDelegate> delegate;
    NSPredicate*				predicate;
    smartList*					listToTransferTo;

    NSInteger   includeItemsFromShoppingList;
}

@property (nonatomic, assign) id<PredicateEditorWindowControllerDelegate> delegate;
@property (nonatomic) NSInteger includeItemsFromShoppingList;

- (id)initWithSmartList:(smartList*)list;
- (IBAction)okClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;
- (NSPredicate*)parsePredicateAndSetFlags:(NSString*)predStr;

@end

//custom row for bool values
@interface BoolEditorRowTemplate : NSPredicateEditorRowTemplate{
	NSPopUpButton *keypathPopUp;
	NSPopUpButton *boolPopUp;
}

-(NSPopUpButton *)keypathPopUp;
-(NSPopUpButton *)boolPopUp;

@end
