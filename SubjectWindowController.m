//
// SubjectWindowController.m
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

#import "SubjectWindowController.h"

//TODO: refactor this extract superclass for both this and AuthorsWindowController

@implementation SubjectWindowController
@synthesize delegate;

- (id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator*)coord{
    coordinator = coord;
    initialSelection = nil;
    useSelectButton = false;
    return self;
}

- (id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator*)coord
                         selectedSubject:(subject*)subjectInput
                            selectButton:(BOOL)withSelect{
    coordinator = coord;
    initialSelection = subjectInput;
    useSelectButton = withSelect;
    return self;
}

- (void)dealloc{
    [managedObjectContext release];
    [bookArrayController release];
    [subjectArrayController release];

    [super dealloc];
}

- (void)awakeFromNib {
    [[self window] makeKeyAndOrderFront:self];

    [bookTableView setDoubleAction:@selector(doubleClickBookAction:)];
    [bookTableView setTarget:self];

    [managedObjectContext setPersistentStoreCoordinator:coordinator];

    //guarantees loaded as next instruction doesn't execute until afterwards
    NSError *error;
    [subjectArrayController fetchWithRequest:nil merge:NO error:&error];

    //sort two tables
    [subjectTableView setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:true]]];
    [bookTableView    setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:true]]];

    if(initialSelection != nil){
        [self selectAndScrollToSubject:initialSelection];
    }

    if(useSelectButton){
        [saveButton setTitle:@"Select"];
    }
}

- (void)loadWindow{
    if (![NSBundle loadNibNamed:@"SubjectDetail" owner:self]) {
        NSLog(@"Error loading Nib!");
        return;
    }
}

- (void)selectAndScrollToSubject:(subject*)subjectObj{
    //linear search -- this is a hack and won't work for mulitple subjects with the same name FIXME
    NSUInteger idx = NSNotFound;
    NSUInteger count = 0;
    for(subject* s in [subjectArrayController arrangedObjects]){
        if([[s name] isEqualToString:[subjectObj name]]){
            idx = count;
            break;
        }
        count++;
    }
    if(idx == NSNotFound){
        return;
    }

    NSIndexSet *index = [NSIndexSet indexSetWithIndex:idx];
    [subjectTableView selectRowIndexes:index byExtendingSelection:NO];
    [subjectTableView scrollRowToVisible:[index firstIndex]];
}

- (void)beginEditingCurrentlySelectedItemInSubjectsTable{
    [subjectTableView editColumn:0
                             row:[subjectTableView selectedRow]
                       withEvent:nil
                          select:YES];
}

- (IBAction)saveClicked:(id)sender {
    [self saveManagedObjectContext:managedObjectContext];
    //let delegate know
    if([[self delegate] respondsToSelector:@selector(savedWithSubjectSelection:)]) {
        [[self delegate] savedWithSubjectSelection:[[subjectArrayController selectedObjects] objectAtIndex:0]];
    }
    [[self window] performClose:self];
}

- (IBAction)cancelClicked:(id)sender {
    [[self window] performClose:self];
}

- (void)saveManagedObjectContext:(NSManagedObjectContext*)context {
    NSError *error = nil;
    if (![context save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (IBAction)doubleClickBookAction:(id)sender {
    //use the first object if multiple are selected
    book *obj = [[bookArrayController selectedObjects] objectAtIndex:0];

    BooksWindowController *detailWin = [[BooksWindowController alloc] initWithManagedObject:obj
                                                                                 withSearch:false];
    if (![NSBundle loadNibNamed:@"Detail" owner:[detailWin autorelease]]) {
        NSLog(@"Error loading Nib!");
    }
}

- (IBAction)addSubjectAction:(id)sender{
    subject* subjectObj = [[subjectArrayController newObject] autorelease];
    [subjectArrayController addObject:subjectObj];
    [self selectAndScrollToSubject:subjectObj];
    [self beginEditingCurrentlySelectedItemInSubjectsTable];
}
@end


//custom NSTableView
@implementation SubjectsTableView

- (void)keyDown:(NSEvent *)theEvent{
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];

    if (key == NSDeleteCharacter || key == NSBackspaceCharacter){
        [subjectArrayController remove:self];
    }else{
        //pass on to next first responder if not going to handle it
        [super keyDown:theEvent];
    }
}

@end
