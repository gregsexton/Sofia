//
// PredicateEditorWindowController.h
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
#import "smartList.h"
#import "PredicateEditorWindowControllerDelegate.h"
#import "list.h"
#import <math.h>

#define PRED_NOT_IN_SHOPPING_LIST @"NOT library.name MATCHES 'Shopping List'"

#define SECS_IN_A_DAY 86400.0
#define SECS_IN_A_WEEK 604800.0
#define SECS_IN_A_MONTH 2419200.0

@interface PredicateEditorWindowController : NSWindowController {

    IBOutlet NSPredicateEditor*	    predicateEditor;
    IBOutlet NSButton*              includeShoppingListBtn;

    id<PredicateEditorWindowControllerDelegate> delegate;
    NSPredicate*				predicate;
    smartList*					listToTransferTo;

    NSInteger   includeItemsFromShoppingList;

    NSArray* smartLists;
    NSArray* lists;
}

@property (nonatomic, assign) id<PredicateEditorWindowControllerDelegate> delegate;
@property (nonatomic) NSInteger includeItemsFromShoppingList;
@property (nonatomic, retain) NSArray* smartLists;
@property (nonatomic, retain) NSArray* lists;

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

- (NSPopUpButton *)keypathPopUp;
- (NSPopUpButton *)boolPopUp;

@end

//custom row for book lists
@interface ListEditorRowTemplate : NSPredicateEditorRowTemplate <NSCopying>{
    NSPopUpButton *keypathPopUp;
    NSPopUpButton *listPopUp;
    NSPopUpButton *boolPopUp;

    NSArray* smartLists;
    NSArray* lists;
}
@property (nonatomic, retain) NSArray* smartLists;
@property (nonatomic, retain) NSArray* lists;

- (NSPopUpButton *)keypathPopUp;
- (NSPopUpButton *)listPopUp;
- (NSPopUpButton*)boolPopUp;

@end

//custom row for friendly date ranges
typedef enum {timeFrameDays,
              timeFrameWeeks,
              timeFrameMonths} timeFrame;

@interface DateEditorRowTemplate : NSPredicateEditorRowTemplate{
    NSPopUpButton *keypathPopUp;
    NSPopUpButton *boolPopUp;
    NSTextField   *quantityTextField;
    NSPopUpButton *timeFramePopUp;
}

- (NSPopUpButton *)keypathPopUp;
- (NSPopUpButton *)boolPopUp;
- (NSTextField   *)quantityTextField;
- (NSPopUpButton *)timeFramePopUp;
- (void)setQuantityTextFieldFromPredicate:(NSPredicate*)pred;
- (void)setTimeFramePopUpFromPredicate:(NSPredicate*)pred;
- (NSInteger)reverseEngineerQuantityFrom:(NSInteger)timeInterval;
- (timeFrame)reverseEngineerTimeFrameFrom:(NSInteger)timeInterval;
- (NSInteger)timeIntervalFromPredicate:(NSPredicate*)pred;
- (BOOL)isIntegral:(double)x;

@end
