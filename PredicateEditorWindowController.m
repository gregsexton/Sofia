//
//  PredicateEditorWindowController.m
//  books
//
//  Created by Greg on 30/03/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PredicateEditorWindowController.h"


@implementation PredicateEditorWindowController
@synthesize delegate;

//TODO: custom row template for read boolean
//TODO: convert noOfCopies to an integer

- (id)initWithSmartList:(smartList*)list{
    self = [super init];
    predicate = [[NSPredicate predicateWithFormat:[list filter]] retain];
    listToTransferTo = list;
    return self;
}

- (void)dealloc{
    [predicate release];
    [super dealloc];
}

- (void)awakeFromNib {
    [window makeKeyAndOrderFront:self];
}

- (IBAction)okClicked:(id)sender {
    NSString* pred = [[predicateEditor objectValue] predicateFormat];
//NSLog(pred);
    [listToTransferTo setFilter:pred];
    [window close];

    //let delegate know
    if([[self delegate] respondsToSelector:@selector(predicateEditingDidFinish:)]) {
	[[self delegate] predicateEditingDidFinish:[predicateEditor objectValue]];
    }
}

- (IBAction)cancelClicked:(id)sender {
    [window close];
}
@end
