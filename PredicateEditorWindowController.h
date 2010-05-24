//
//  PredicateEditorWindowController.h
//  books
//
//  Created by Greg on 30/03/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "smartList.h"


@interface PredicateEditorWindowController : NSObject {

    IBOutlet NSWindow*		    window;
    IBOutlet NSPredicateEditor*	    predicateEditor;

    id*			    delegate;
    NSPredicate*	    predicate;
    smartList*		    listToTransferTo;
}

@property (nonatomic, assign) id *delegate;

- (id)initWithSmartList:(smartList*)list;
- (IBAction)okClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;

@end
