//
// SofiaApplication.m
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

#import "SofiaApplication.h"
#import "SidebarOutlineView.h"
#import "BooksTableView.h"
#import "BooksCoverflowController.h"

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
    else if([view isEqualToString:COVER_VIEW])
	[self changeToCoverflowView:self];
    
    //setup preferences
    AccessKeyViewController *accessKeys = [[AccessKeyViewController alloc] initWithNibName:@"Preferences_AccessKeys" bundle:nil];
    GeneralViewController *general = [[GeneralViewController alloc] initWithNibName:@"Preferences_General" bundle:nil];
    [[MBPreferencesController sharedController] setModules:[NSArray arrayWithObjects:general,accessKeys, nil]];
    [accessKeys release];
    [general release];

    [self updateSummaryText];

    //setup periodic save timer
    [NSTimer scheduledTimerWithTimeInterval:FIVE_MINUTES
                                     target:self
                                   selector:@selector(saveAction:)
                                   userInfo:nil
                                    repeats:YES];

    //disable auto enabling items (for remove filter) in view menu
    [viewMenu setAutoenablesItems:NO];
}

- (void) dealloc {
	
    [managedObjectContext release], managedObjectContext = nil;
    [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
    [managedObjectModel release], managedObjectModel = nil;

    if(revealFilterAnimation)
        [revealFilterAnimation release];
    if(hideFilterAnimation)
        [hideFilterAnimation release];

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
    url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"Sofia-debug"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&error]){
        [[NSApplication sharedApplication] presentError:error];
    }    
    [window setTitle:@"!!!!!!! DEBUG DEBUG DEBUG !!!!!!!"];
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

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication{
    return YES;
}

- (IBAction) saveAction:(id)sender {
    NSError *error = nil;
    if ([managedObjectContext hasChanges] && ![[self managedObjectContext] save:&error]) {
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
    [self createBookAndOpenDetailWindow];
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
        [sideBar removeCurrentFilter]; //does nothing if no filter applied

        NSString* escapedSearchVal = [searchVal escapeSingleQuote];
	NSArray* predicates = [NSArray arrayWithObjects:
	    [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"title contains[cd] '%@'",         escapedSearchVal]],
	    [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"authorText contains[cd] '%@'",    escapedSearchVal]],
	    [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"publisherText contains[cd] '%@'", escapedSearchVal]],
	    [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"subjectText contains[cd] '%@'",   escapedSearchVal]],
	    [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"isbn10 contains[cd] '%@'",        escapedSearchVal]],
	    [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"isbn13 contains[cd] '%@'",        escapedSearchVal]], nil];
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
	[self changeToCoverflowView:self];
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

- (IBAction)changeToCoverflowView:(id)sender{
    [self changeMainViewFor:mainCoverflowView];
    [zoomSlider setHidden:true];
    [changeViewButtons setSelectedSegment:2];
    [[NSUserDefaults standardUserDefaults] setObject:COVER_VIEW forKey:@"currentView"];
    [coverflowController addAndRepositionTableView];
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

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"book" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[arrayController filterPredicate]];

    NSError *err;
    NSUInteger count = [managedObjectContext countForFetchRequest:request error:&err];

    [request release];

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
    [detailWin setDelegate:self];
    return [detailWin autorelease];
}

- (NSViewAnimation*)revealFilterAnimation{
    if(!revealFilterAnimation){
        NSRect frame = [mainViewContainerView bounds];
        NSMutableDictionary* mainViewDict = [NSMutableDictionary dictionaryWithCapacity:3];
 
        // Specify which view to modify.
        [mainViewDict setObject:mainView forKey:NSViewAnimationTargetKey];

        // Specify the starting position of the view.
        [mainViewDict setObject:[NSValue valueWithRect:frame]
                         forKey:NSViewAnimationStartFrameKey];
 
        // Change the ending position of the view.
        frame.size.height -= FILTER_NOTIFICATION_VIEW_HEIGHT;
 
        [mainViewDict setObject:[NSValue valueWithRect:frame]
                         forKey:NSViewAnimationEndFrameKey];

        revealFilterAnimation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:mainViewDict]];
        [revealFilterAnimation setDuration:0.25];
    }

    return revealFilterAnimation;
}

- (NSViewAnimation*)hideFilterAnimation{
    if(!hideFilterAnimation){
        NSRect frame = [mainViewContainerView bounds];
        frame.size.height -= FILTER_NOTIFICATION_VIEW_HEIGHT;

        NSMutableDictionary* mainViewDict = [NSMutableDictionary dictionaryWithCapacity:3];
 
        // Specify which view to modify.
        [mainViewDict setObject:mainView forKey:NSViewAnimationTargetKey];

        // Specify the starting position of the view.
        [mainViewDict setObject:[NSValue valueWithRect:frame]
                         forKey:NSViewAnimationStartFrameKey];
 
        // Change the ending position of the view.
        frame.size.height += FILTER_NOTIFICATION_VIEW_HEIGHT;
 
        [mainViewDict setObject:[NSValue valueWithRect:frame]
                         forKey:NSViewAnimationEndFrameKey];

        hideFilterAnimation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:mainViewDict]];
        [hideFilterAnimation setDuration:0.25];
    }

    return hideFilterAnimation;
}

- (void)revealFilterNotificationView{
    NSViewAnimation* hideAnim = [self hideFilterAnimation];
    NSViewAnimation* revealAnim = [self revealFilterAnimation];

    if([hideAnim isAnimating]){
        [revealAnim startWhenAnimation:hideAnim reachesProgress:1.0];
    }else{
        [hideAnim   clearStartAnimation];
        [hideAnim   clearStopAnimation];
        [revealAnim clearStartAnimation];
        [revealAnim clearStopAnimation];
        [revealAnim startAnimation];
    }
}

- (void)hideFilterNotificationView{
    NSViewAnimation* revealAnim = [self revealFilterAnimation];
    NSViewAnimation* hideAnim = [self hideFilterAnimation];

    if([revealAnim isAnimating]){
        [hideAnim startWhenAnimation:revealAnim reachesProgress:1.0];
    }else{
        [revealAnim clearStartAnimation];
        [revealAnim clearStopAnimation];
        [hideAnim   clearStartAnimation];
        [hideAnim   clearStopAnimation];
        [hideAnim   startAnimation];
    }
}

/////////////Delegate Methods/////////////////////////////////////////////////////////////////////

//delegate methods performed by BooksWindowController.
- (void)saveClicked:(BooksWindowController*)booksWindowController {
    [arrayController rearrangeObjects]; //sort the newly added book this also has the side
					//affect of keeping smart lists updated after adding a book
    [self updateSummaryText];
    [imagesView reloadData];
}

- (void)cancelClicked:(BooksWindowController*)booksWindowController{
    //NOTE: this method should only be called as part of adding a book not viewing a book
    [arrayController removeObject:[booksWindowController obj]];
    [self saveAction:self];
    [self updateSummaryText];
}

//delegate methods performed by ImportBooksController.
- (void)closeClickedOnImportBooksController:(ImportBooksController*)controller{
    //released here as a new autorelease pool is created for this
    //modal window and the object is released early. Here is the
    //only sensible place to release.
    [controller release];
}

@end
