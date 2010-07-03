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
