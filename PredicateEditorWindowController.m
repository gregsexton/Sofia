//
// PredicateEditorWindowController.m
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

#import "PredicateEditorWindowController.h"


@implementation PredicateEditorWindowController
@synthesize delegate;
@synthesize includeItemsFromShoppingList;
@synthesize lists;
@synthesize smartLists;

//TODO: convert noOfCopies to an integer

- (id)initWithSmartList:(smartList*)list{
    if(self = [super init]){
        //unwrap predicate -- wrapped in the okClicked method
        predicate = [[self parsePredicateAndSetFlags:[list filter]] retain];
        listToTransferTo = list;
    }
    return self;
}

- (void)dealloc{
    if(predicate)
        [predicate release];
    if(lists)
        [lists release];
    if(smartLists)
        [smartLists release];

    [super dealloc];
}

- (void)awakeFromNib {
    [window makeKeyAndOrderFront:self];

    //add ListEditorRowTemplate -- has to be done programatically as need to pass lists/smartLists to it.
    ListEditorRowTemplate* leRowTemplate = [[ListEditorRowTemplate alloc] init];
    [leRowTemplate setLists:[self lists]];
    [leRowTemplate setSmartLists:[self smartLists]];

    NSArray* templates = [predicateEditor rowTemplates];
    templates = [templates arrayByAddingObject:leRowTemplate];
    [predicateEditor setRowTemplates:templates];

    [leRowTemplate release];

    [predicateEditor setObjectValue:predicate];
}

- (NSPredicate*)parsePredicateAndSetFlags:(NSString*)predStr{ //has side effects
    //parses the compound predicate string and returns the
    //subpredicate that was wrapped (potentially) in okClicked
    //also sets the relevant flags

    NSString* subPred;

    if([predStr hasPrefix:[NSString stringWithFormat:@"(%@)", PRED_NOT_IN_SHOPPING_LIST]]){
        self.includeItemsFromShoppingList = NSOffState;

        //pred length + brackets (2) + " AND " (5)
        subPred = [predStr substringFromIndex:[PRED_NOT_IN_SHOPPING_LIST length]+2+5];
    }else{
        self.includeItemsFromShoppingList = NSOnState;

        NSString* prefix = @"(TRUEPREDICATE) AND ";
        if([predStr hasPrefix:prefix]){
            subPred = [predStr substringFromIndex:[prefix length]];
        }else{
            subPred = predStr;
        }
    }

    return [NSPredicate predicateWithFormat:subPred];
}

- (IBAction)okClicked:(id)sender{
    NSString* pred = [[predicateEditor objectValue] predicateFormat];
    NSString* shoppingPred;

    if(includeItemsFromShoppingList == NSOffState){ //predicate should not include shopping list items
        shoppingPred = PRED_NOT_IN_SHOPPING_LIST;
    }else{
        //NOTE: AND with something as process needs to be reversible
        shoppingPred = @"TRUEPREDICATE";
    }

    pred = [NSString stringWithFormat:@"(%@) AND (%@)",
                                      shoppingPred, pred];

    //let delegate know
    if([[self delegate] respondsToSelector:@selector(predicateEditingDidFinish:)]){
        [[self delegate] predicateEditingDidFinish:[NSPredicate predicateWithFormat:pred]];
    }

    NSLog(@"%@", pred);

    [listToTransferTo setFilter:pred];
    [window close];
}

- (IBAction)cancelClicked:(id)sender {
    [window close];
}
@end

//The basis for the following class code was found on
//http://www.codecollector.net/view/CB180CA1-407A-45D6-BACD-5AD156BC1CE7
@implementation BoolEditorRowTemplate

- (NSPopUpButton *)keypathPopUp {
    if(!keypathPopUp){
	NSMenu *keypathMenu = [[[NSMenu allocWithZone:[NSMenu menuZone]] initWithTitle:@"ReadMenu"] autorelease];

	NSMenuItem *menuItem = [[[NSMenuItem alloc] initWithTitle:@"Is Read" action:nil keyEquivalent:@""] autorelease];
	[menuItem setRepresentedObject:[NSExpression expressionForKeyPath:@"read"]];
	[menuItem setEnabled:YES];

	[keypathMenu addItem:menuItem];

	keypathPopUp = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
	[keypathPopUp setMenu:keypathMenu];
    }

    return keypathPopUp;
}

- (NSPopUpButton *)boolPopUp {
    if(!boolPopUp){
	NSMenu *boolMenu = [[[NSMenu allocWithZone:[NSMenu menuZone]] initWithTitle:@"bool menu"] autorelease];

	NSMenuItem *yesItem = [[[NSMenuItem alloc] initWithTitle:@"Yes" action:nil keyEquivalent:@""] autorelease];
	[yesItem setRepresentedObject:[NSExpression expressionForConstantValue:[NSNumber numberWithBool:YES]]];
	[yesItem setEnabled:YES];
	[yesItem setTag:1];

	NSMenuItem *noItem = [[[NSMenuItem alloc] initWithTitle:@"No" action:nil keyEquivalent:@""] autorelease];
	[noItem setRepresentedObject:[NSExpression expressionForConstantValue:[NSNumber numberWithBool:NO]]];
	[noItem setEnabled:YES];
	[noItem setTag:0];

	[boolMenu addItem:yesItem];
	[boolMenu addItem:noItem];

	boolPopUp = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
	[boolPopUp setMenu:boolMenu];
    }

    return boolPopUp;
}

- (void)dealloc {

    [keypathPopUp release];
    [boolPopUp release];

    [super dealloc];
}

- (double)matchForPredicate:(NSPredicate *)predicate{
    //this will work for now
    if([[predicate predicateFormat] isEqualToString:@"read == 1"] ||
	    [[predicate predicateFormat] isEqualToString:@"read == 0"]){
	return 1;
    }

    return 0;
}

- (NSArray *)templateViews{
    NSArray *newViews = [NSArray arrayWithObjects:[self keypathPopUp], [self boolPopUp], nil];

    return newViews;
}

- (void) setPredicate:(NSPredicate *)predicate{
    // Sets the Yes/No popup when a predicate is set on the template.
    id rightValue = [[(NSComparisonPredicate *)predicate rightExpression] constantValue];
    if([rightValue isKindOfClass:[NSNumber class]])
	[[self boolPopUp] selectItemWithTag:[rightValue integerValue]];
}

- (NSPredicate *)predicateWithSubpredicates:(NSArray *) subpredicates{
    NSPredicate *newPredicate = [NSComparisonPredicate predicateWithLeftExpression:[[[self keypathPopUp] selectedItem] representedObject]
								   rightExpression:[[[self boolPopUp] selectedItem] representedObject]
									  modifier:NSDirectPredicateModifier
									      type:NSEqualToPredicateOperatorType
									   options:0];
    return newPredicate;
}

@end

@implementation ListEditorRowTemplate
@synthesize lists;
@synthesize smartLists;

- (void)dealloc {

    [keypathPopUp release];
    [listPopUp release];
    [boolPopUp release];
    if(lists)
        [lists release];
    if(smartLists)
        [smartLists release];

    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone{
    return [self retain];
}

- (NSPopUpButton *)keypathPopUp {
    if(!keypathPopUp){
	NSMenu *keypathMenu = [[[NSMenu allocWithZone:[NSMenu menuZone]] initWithTitle:@"ListKeypathMenu"] autorelease];

	NSMenuItem *menuItem = [[[NSMenuItem alloc] initWithTitle:@"Booklist" action:nil keyEquivalent:@""] autorelease];
	[menuItem setEnabled:YES];

	[keypathMenu addItem:menuItem];

	keypathPopUp = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
	[keypathPopUp setMenu:keypathMenu];
    }

    return keypathPopUp;
}

- (NSPopUpButton*)boolPopUp{
    if(!boolPopUp){
	NSMenu *boolMenu = [[[NSMenu allocWithZone:[NSMenu menuZone]] initWithTitle:@"bool menu"] autorelease];

	NSMenuItem *yesItem = [[[NSMenuItem alloc] initWithTitle:@"is" action:nil keyEquivalent:@""] autorelease];
	[yesItem setRepresentedObject:[NSNumber numberWithBool:YES]];
	[yesItem setEnabled:YES];
	[yesItem setTag:1];

	NSMenuItem *noItem = [[[NSMenuItem alloc] initWithTitle:@"is not" action:nil keyEquivalent:@""] autorelease];
	[noItem setRepresentedObject:[NSNumber numberWithBool:NO]];
	[noItem setEnabled:YES];
	[noItem setTag:0];

	[boolMenu addItem:yesItem];
	[boolMenu addItem:noItem];

	boolPopUp = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
	[boolPopUp setMenu:boolMenu];
    }

    return boolPopUp;
}

- (NSPopUpButton *)listPopUp{
    if(!listPopUp){
	NSMenu *listMenu = [[[NSMenu allocWithZone:[NSMenu menuZone]] initWithTitle:@"list menu"] autorelease];

        for(list* lst in [self lists]){
            NSMenuItem *listItem = [[[NSMenuItem alloc] initWithTitle:[lst name] action:nil keyEquivalent:@""] autorelease];
            [listItem setRepresentedObject:[NSExpression expressionForConstantValue:[lst name]]];
            [listItem setEnabled:YES];
            [listItem setTag:1];

            [listMenu addItem:listItem];
        }

        for(smartList* lst in [self smartLists]){
            NSMenuItem *listItem = [[[NSMenuItem alloc] initWithTitle:[lst name] action:nil keyEquivalent:@""] autorelease];
            [listItem setRepresentedObject:[NSPredicate predicateWithFormat:[lst filter]]];
            [listItem setEnabled:YES];
            [listItem setTag:1];

            [listMenu addItem:listItem];
        }

	listPopUp = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
	[listPopUp setMenu:listMenu];
    }

    return listPopUp;
}

- (NSPredicate *)predicateWithSubpredicates:(NSArray *) subpredicates{

    BOOL inverse = ![[[[self boolPopUp] selectedItem] representedObject] boolValue];

    if([[[[self listPopUp] selectedItem] representedObject] isKindOfClass:[NSPredicate class]]){ //smart list is selected
        NSPredicate* pred = [[[self listPopUp] selectedItem] representedObject];

        if(inverse){
            return [NSCompoundPredicate notPredicateWithSubpredicate:pred];
        }else{
            return pred;
        }
    }else{
        NSPredicate* pred = [NSComparisonPredicate predicateWithLeftExpression:[NSExpression expressionForKeyPath:@"lists.name"]
                                                               rightExpression:[[[self listPopUp] selectedItem] representedObject]
                                                                      modifier:NSAnyPredicateModifier
                                                                          type:NSLikePredicateOperatorType
                                                                       options:0];
        if(inverse){
            return [NSCompoundPredicate notPredicateWithSubpredicate:pred];
        }else{
            return pred;
        }
    }
}

- (double)matchForPredicate:(NSPredicate *)predicate{ //return 1 if can display for pred

    NSPredicate* pred = predicate;

    //if a smart list is chosen and then edited independently
    //it is possible for the 'TRUEPREDICATE' of the smart list
    //to become 'trapped' as it is won't be stripped by the PredicateEditorWindowController
    //TODO: is there a solution?

    if([pred isKindOfClass:[NSCompoundPredicate class]]){
        if([(NSCompoundPredicate*)pred compoundPredicateType] == NSNotPredicateType){
            pred = [[(NSCompoundPredicate*)pred subpredicates] objectAtIndex:0];
        }else{
            return 0;
        }
    }

    if([pred isKindOfClass:[NSComparisonPredicate class]]){
        if([[[(NSComparisonPredicate*)pred leftExpression] keyPath] isEqualToString:@"lists.name"]){
            return 1;
        }
    }

    if([pred isKindOfClass:[NSCompoundPredicate class]]){
        for(smartList* lst in [self smartLists]){
            NSPredicate* testPred = [NSPredicate predicateWithFormat:[lst filter]];
            if([[testPred predicateFormat] isEqualToString:[pred predicateFormat]])
                return 1;
        }
    }

    return 0;
}

- (void)setPredicate:(NSPredicate *)predicate{

    NSPredicate* pred = predicate;

    if([pred isKindOfClass:[NSCompoundPredicate class]]){
        [[self boolPopUp] selectItemWithTag:0];
        pred = [[(NSCompoundPredicate*)pred subpredicates] objectAtIndex:0];
    }else{
        [[self boolPopUp] selectItemWithTag:1];
    }
        
    if([pred isKindOfClass:[NSComparisonPredicate class]]){
        NSString* rightValue = [[(NSComparisonPredicate *)pred rightExpression] constantValue];
        if([rightValue isKindOfClass:[NSString class]])
            [[self listPopUp] selectItemWithTitle:rightValue];
    }

    if([pred isKindOfClass:[NSCompoundPredicate class]]){
        for(smartList* lst in [self smartLists]){
            NSPredicate* testPred = [NSPredicate predicateWithFormat:[lst filter]];
            if([[testPred predicateFormat] isEqualToString:[pred predicateFormat]])
                [[self listPopUp] selectItemWithTitle:[lst name]];
        }
    }
}

- (NSArray *)templateViews{
    NSArray *newViews = [NSArray arrayWithObjects:[self keypathPopUp], [self boolPopUp], [self listPopUp], nil];

    return newViews;
}

@end
