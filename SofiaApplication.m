//
//  SofiaApplication.m
//
//  Created by Greg Sexton on 14/09/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SofiaApplication.h"
#import "SidebarOutlineView.h"
#import "BooksTableView.h"


//TODO: reorder all of the methods into a more logical state!
//TODO: make table view a new inherited class with custom code self contained

@implementation SofiaApplication

- (void) awakeFromNib {
    //setup preferences
    AccessKeyViewController *accessKeys = [[AccessKeyViewController alloc] initWithNibName:@"Preferences_AccessKeys" bundle:nil];
    GeneralViewController *general = [[GeneralViewController alloc] initWithNibName:@"Preferences_General" bundle:nil];
    [[MBPreferencesController sharedController] setModules:[NSArray arrayWithObjects:general, accessKeys, nil]];
    [accessKeys release];
    [general release];

    //guarantee loaded before updating summary text. this works better than observing.
    NSError *error;
    [arrayController fetchWithRequest:nil merge:NO error:&error];
    [self updateSummaryText];

}


/**
 Returns the support folder for the application, used to store the Core Data
 store file.  This code uses a folder named "Sofia" for
 the content, either in the NSApplicationSupportDirectory location or (if the
 former cannot be found), the system's temporary directory.
 */

- (NSString*)applicationSupportFolder {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Sofia"];
}


/**
 Creates, retains, and returns the managed object model for the application 
 by merging all of the models found in the application bundle.
 */

- (NSManagedObjectModel*)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.  This 
 implementation will create and return a coordinator, having added the 
 store for the application to it.  (The folder for the store is created, 
 if necessary.)
 */

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
        [fileManager createDirectoryAtPath:applicationSupportFolder attributes:nil];
    }
    
#ifdef CONFIGURATION_Debug
    url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"Sofia.xml"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]){
        [[NSApplication sharedApplication] presentError:error];
    }    
#endif

#ifdef CONFIGURATION_Release
    url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"Sofia"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]){
        [[NSApplication sharedApplication] presentError:error];
    }    
#endif
	
    return persistentStoreCoordinator;
}


/**
 Returns the managed object context for the application (which is already
 bound to the persistent store coordinator for the application.) 
 */

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


/**
 Returns the NSUndoManager for the application.  In this case, the manager
 returned is that of the managed object context for the application.
 */

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.  Any encountered errors
 are presented to the user.
 */

- (IBAction) saveAction:(id)sender {
	
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
 Implementation of the applicationShouldTerminate: method, used here to
 handle the saving of changes in the application managed object context
 before the application terminates.
 */

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	
    NSError *error;
    int reply = NSTerminateNow;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext commitEditing]) {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
                // This error handling simply presents error information in a panel with an 
                // "Ok" button, which does not include any attempt at error recovery (meaning, 
                // attempting to fix the error.)  As a result, this implementation will 
                // present the information to the user and then follow up with a panel asking 
                // if the user wishes to "Quit Anyway", without saving the changes.
				
                // Typically, this process should be altered to include application-specific 
                // recovery steps.  
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


/**
 Implementation of dealloc, to release the retained variables.
 */

- (void) dealloc {
	
    [managedObjectContext release], managedObjectContext = nil;
    [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
    [managedObjectModel release], managedObjectModel = nil;
    [super dealloc];
}

- (IBAction) manageAuthorsClickAction:(id)sender {
	AuthorsWindowController *detailWin = [[AuthorsWindowController alloc] initWithManagedObjectContext:managedObjectContext];
	//[detailWin setDelegate:self];
	if (![NSBundle loadNibNamed:@"AuthorDetail" owner:detailWin]) {
	    NSLog(@"Error loading Nib!");
	}
}

- (IBAction) manageSubjectsClickAction:(id)sender {
	SubjectWindowController *detailWin = [[SubjectWindowController alloc] initWithManagedObjectContext:managedObjectContext];
	//[detailWin setDelegate:self];
	if (![NSBundle loadNibNamed:@"SubjectDetail" owner:detailWin]) {
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
    book *obj = [[book alloc] initWithEntity:[[managedObjectModel entitiesByName] objectForKey:@"book"]
						    insertIntoManagedObjectContext:managedObjectContext];

    //add to appropriate library
    Library *lib = [sideBar selectedLibrary];
    [lib addBooksObject:obj];

    BooksWindowController *detailWin = [[BooksWindowController alloc] initWithManagedObject:obj];
    [detailWin setDelegate:self];
    if (![NSBundle loadNibNamed:@"Detail" owner:detailWin]) {
	NSLog(@"Error loading Nib!");
    }
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

//delegate method performed by booksWindowController.
- (void) saveClicked:(BooksWindowController*)booksWindowController {
    if(![[arrayController arrangedObjects] containsObject:[booksWindowController obj]]){
	[arrayController addObject:[booksWindowController obj]];
    }
    [self updateSummaryText];
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

//this method registers to observe the objects held in the
//tableview it is used to update the summary text when the
//application first loads. After first running it is disabled and
//future updating is handled by the delgate method saveClicked.
//TODO: delete these 3?
- (void)registerAsArrayControllerObserver{
    [arrayController addObserver:self
		     forKeyPath:@"arrangedObjects"
		     options:NSKeyValueObservingOptionNew
		     context:NULL];
}

- (void)unregisterForArrayControllerChangeNotification{
    [arrayController removeObserver:self
                     forKeyPath:@"arrangedObjects"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqual:@"arrangedObjects"]) {
	[self updateSummaryText];
	[self unregisterForArrayControllerChangeNotification]; //perform once at startup then unregister.
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


- (IBAction) aboutClickAction:(id)sender {
	NSDictionary *aboutDict = [NSDictionary dictionaryWithObjectsAndKeys:
				@"Greg Sexton 2009", @"Copyright", nil];
	[[NSApplication sharedApplication] orderFrontStandardAboutPanelWithOptions:aboutDict];
}

- (IBAction) displayPreferencesClickAction:(id)sender{

    [[MBPreferencesController sharedController] showWindow:sender];
}    

@end
