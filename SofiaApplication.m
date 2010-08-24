//
// SofiaApplication.m
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

#import "SofiaApplication.h"
#import "SidebarOutlineView.h"
#import "BooksTableView.h"

@implementation SofiaApplication

- (void) awakeFromNib {
    
    //setup the main view
    currentView = nil;
    NSString* view = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentView"];
    if(view == nil) //initial launch
	[self changeToListView:self];
    if([view isEqualToString:LIST_VIEW])
	[self changeToListView:self];
    else if([view isEqualToString:IMAGE_VIEW])
	[self changeToImagesView:self];
    
    //setup preferences
    AccessKeyViewController *accessKeys = [[AccessKeyViewController alloc] initWithNibName:@"Preferences_AccessKeys" bundle:nil];
    GeneralViewController *general = [[GeneralViewController alloc] initWithNibName:@"Preferences_General" bundle:nil];
    [[MBPreferencesController sharedController] setModules:[NSArray arrayWithObjects:general,accessKeys, nil]];
    [accessKeys release];
    [general release];

    //guarantee loaded before updating summary text. This works better than observing.
    NSError *error;
    [arrayController fetchWithRequest:nil merge:NO error:&error];
    [self updateSummaryText];

}

- (void) dealloc {
	
    [managedObjectContext release], managedObjectContext = nil;
    [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
    [managedObjectModel release], managedObjectModel = nil;
    [super dealloc];
}

- (NSString*)applicationSupportFolder {
    //Returns the support folder for the application, used to store the Core Data store file.
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Sofia"];
}


- (NSManagedObjectModel*)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSFileManager *fileManager;
    NSString *applicationSupportFolder = nil;
    NSURL *url;
    NSError *error;
    
    fileManager = [NSFileManager defaultManager];
    applicationSupportFolder = [self applicationSupportFolder];
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
        [fileManager createDirectoryAtPath:applicationSupportFolder 
	       withIntermediateDirectories:true
				attributes:nil
				     error:NULL];
    }

    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
	[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
	[NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    
#ifdef CONFIGURATION_Debug
    url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"Sofia.xml"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:options error:&error]){
        [[NSApplication sharedApplication] presentError:error];
    }    
#endif

#ifdef CONFIGURATION_Release
    url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"Sofia"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&error]){
        [[NSApplication sharedApplication] presentError:error];
    }    
#endif
	
    return persistentStoreCoordinator;
}


- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
	//this line was suggested as fixing the EXC_BAD_ACCESS error, turns out I don't need it.
	//[managedObjectContext setRetainsRegisteredObjects:YES];
    }
    
    return managedObjectContext;
}


- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	
    NSError *error;
    int reply = NSTerminateNow;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext commitEditing]) {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
                BOOL errorResult = [[NSApplication sharedApplication] presentError:error];
                if (errorResult == YES) {
                    reply = NSTerminateCancel;
                } 
                else {
                    int alertReturn = NSRunAlertPanel(nil, @"Could not save changes while quitting. Quit anyway?",
						      @"Quit anyway", @"Cancel", nil);
                    if (alertReturn == NSAlertAlternateReturn) {
                        reply = NSTerminateCancel;	
		    }
                }
            }
        }else {
            reply = NSTerminateCancel;
        }
    }
    return reply;
}

- (IBAction) saveAction:(id)sender {
	
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


- (IBAction) manageAuthorsClickAction:(id)sender {
	AuthorsWindowController *detailWin = [[AuthorsWindowController alloc] initWithManagedObjectContext:managedObjectContext];
	//[detailWin setDelegate:self];
	if (![NSBundle loadNibNamed:@"AuthorDetail" owner:[detailWin autorelease]]) {
	    NSLog(@"Error loading Nib!");
	}
}

- (IBAction) manageSubjectsClickAction:(id)sender {
	SubjectWindowController *detailWin = [[SubjectWindowController alloc] initWithManagedObjectContext:managedObjectContext];
	//[detailWin setDelegate:self];
	if (![NSBundle loadNibNamed:@"SubjectDetail" owner:[detailWin autorelease]]) {
	    NSLog(@"Error loading Nib!");
	}
}

- (IBAction) addRemoveClickAction:(id)sender {
    if ([addRemoveButtons selectedSegment] == 0){
	[self addBookAction:self];
    }else{
	[self removeBookAction:self];
    }
}

- (IBAction) addBookAction:(id)sender {
    BooksWindowController* detailWin = [self createBookAndOpenDetailWindow];
    [detailWin setDelegate:self];
}

- (IBAction) removeBookAction:(id)sender {
    int alertReturn = -1;
    int noOfRowsSelected = [tableView numberOfSelectedRows];
    if(noOfRowsSelected == 0){
	NSRunInformationalAlertPanel(@"Selection Error", @"You must select at least one book to remove." , @"Ok", nil, nil);
    }else if(noOfRowsSelected == 1){
	alertReturn = NSRunAlertPanel(@"Remove Book?", @"Are you sure you wish to permanently remove this book from Sofia?",
				      @"No", @"Yes", nil);
    }else if(noOfRowsSelected > 1){
	alertReturn = NSRunAlertPanel(@"Remove Books?", @"Are you sure you wish to permanently remove these books from Sofia?",
				      @"No", @"Yes", nil);
    }
    if (alertReturn == NSAlertAlternateReturn){
	[arrayController remove:self];
	[self saveAction:self];
	[self updateSummaryText];
    }
}

- (IBAction) aboutClickAction:(id)sender {
	NSDictionary *aboutDict = [NSDictionary dictionaryWithObjectsAndKeys:
				@"Greg Sexton 2009", @"Copyright", nil];
	[[NSApplication sharedApplication] orderFrontStandardAboutPanelWithOptions:aboutDict];
}

- (IBAction) displayPreferencesClickAction:(id)sender{

    [[MBPreferencesController sharedController] showWindow:sender];
}    

- (IBAction)search:(id)sender{

    NSString* searchVal = [sender stringValue];
    NSPredicate* totalPred;

    if([searchVal isEqualToString:@""]){
	totalPred = [sideBar getPredicateForSelectedItem];
    }else{
	NSArray* predicates = [NSArray arrayWithObjects:
	    [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"title contains[cd] '%@'", searchVal]],
	    [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"authorText contains[cd] '%@'", searchVal]],
	    [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"publisherText contains[cd] '%@'", searchVal]],
	    [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"subjectText contains[cd] '%@'", searchVal]],
	    [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"isbn10 contains[cd] '%@'", searchVal]],
	    [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"isbn13 contains[cd] '%@'", searchVal]], nil];
	NSPredicate* searchPred = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];

	NSArray* searchAndCurrentFilter = [NSArray arrayWithObjects:searchPred, [sideBar getPredicateForSelectedItem], nil];
	totalPred = [NSCompoundPredicate andPredicateWithSubpredicates:searchAndCurrentFilter];
    }

    [arrayController setFilterPredicate:totalPred];
    [self updateSummaryText];
}

- (IBAction) importBooks:(id)sender{
    ImportBooksController *importWin = [[ImportBooksController alloc] initWithSofiaApplication:self];
    [importWin setWindowToAttachTo:window];
    [importWin setDelegate:self];
    if (![NSBundle loadNibNamed:@"ImportBooks" owner:importWin]) {
	[importWin release];
	NSLog(@"Error loading Nib!");
    }
}

- (IBAction)changeViewClickAction:(id)sender{
    if ([changeViewButtons selectedSegment] == 0){
	[self changeToListView:self];
    }else if([changeViewButtons selectedSegment] == 1){
	[self changeToImagesView:self];
    }else if([changeViewButtons selectedSegment] == 2){
	//TODO
    }else{
	//serious error!
    }
}

- (IBAction)changeToListView:(id)sender{
    [self changeMainViewFor:mainTableView];
    [zoomSlider setHidden:true];
    [changeViewButtons setSelectedSegment:0];
    [tableView scrollRowToVisible:[arrayController selectionIndex]];
    [[NSUserDefaults standardUserDefaults] setObject:LIST_VIEW forKey:@"currentView"];
}

- (IBAction)changeToImagesView:(id)sender{
    [self changeMainViewFor:mainImagesView];
    [zoomSlider setHidden:false];
    [changeViewButtons setSelectedSegment:1];
    [imagesView setSelectionIndexes:[arrayController selectionIndexes]
	       byExtendingSelection:NO];
    [imagesView scrollIndexToVisible:[arrayController selectionIndex]];
    [[NSUserDefaults standardUserDefaults] setObject:IMAGE_VIEW forKey:@"currentView"];
}

- (void)changeMainViewFor:(NSView*)viewToChangeTo{
    //handle size and position
    NSRect rect = [mainView frame];
    rect.origin.x = 0;
    rect.origin.y = 0;
    [viewToChangeTo setFrame:rect];

    if(currentView == nil){
	[mainView addSubview:viewToChangeTo];
    }else{
	[mainView replaceSubview:[currentView retain] with:viewToChangeTo];
    }
    currentView = viewToChangeTo;
}

- (void) updateSummaryText {
    int count = [[arrayController arrangedObjects] count];
    if(count == 0){
	[summaryText setStringValue:@"Empty"];
    }else if(count == 1){
	[summaryText setStringValue:@"1 book"];
    }else {
	[summaryText setStringValue:[NSString stringWithFormat:@"%d books", count]];
    }
}

- (BooksWindowController*) createBookAndOpenDetailWindow{
    book *obj = [[book alloc] initWithEntity:[[managedObjectModel entitiesByName] objectForKey:@"book"]
						    insertIntoManagedObjectContext:managedObjectContext];

    [obj setDateAdded:[NSDate date]];

    //add to appropriate library
    [sideBar addToCurrentLibraryTheBook:obj];

    BooksWindowController *detailWin = [[BooksWindowController alloc] initWithManagedObject:obj 
										 withSearch:YES];
    if (![NSBundle loadNibNamed:@"Detail" owner:detailWin]) {
	NSLog(@"Error loading Nib!");
    }

    [obj release];
    return [detailWin autorelease];
}


/////////////Delegate Methods/////////////////////////////////////////////////////////////////////


//delegate method performed by booksWindowController.
- (void)saveClicked:(BooksWindowController*)booksWindowController {
    [arrayController rearrangeObjects]; //sort the newly added book this also has the side
					//affect of keeping smart lists updated after adding a book
    [self updateSummaryText];
    [imagesView reloadData];
}

- (void)closeClickedOnImportBooksController:(ImportBooksController*)controller{
    //released here as a new autorelease pool is created for this
    //modal window and the object is released early. Here is the
    //only sensible place to release.
    [controller release];
}

@end
