//
//  SofiaApplication.m
//  books
//
//  Created by Greg Sexton on 14/09/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SofiaApplication.h"
#import "BooksWindowController.h"

@implementation SofiaApplication

- (void) awakeFromNib {
    [tableView setDoubleAction:@selector(doubleClickAction:)];
    [tableView setTarget:self]; 
}


/**
 Returns the support folder for the application, used to store the Core Data
 store file.  This code uses a folder named "Sofia" for
 the content, either in the NSApplicationSupportDirectory location or (if the
 former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportFolder {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Sofia"];
}


/**
 Creates, retains, and returns the managed object model for the application 
 by merging all of the models found in the application bundle.
 */

- (NSManagedObjectModel *)managedObjectModel {
	
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
    
    url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"Sofia.xml"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]){
        [[NSApplication sharedApplication] presentError:error];
    }    
	
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

- (IBAction) doubleClickAction:(id)sender {
    //use the first object if multiple are selected
    NSManagedObject *obj = [[arrayController selectedObjects] objectAtIndex:0];

    BooksWindowController *detailWin = [[BooksWindowController alloc] initWithManagedObject:obj];
    if (![NSBundle loadNibNamed:@"Detail" owner:detailWin]) {
	NSLog(@"Error loading Nib!");
    }
} 

- (IBAction) addRemoveClickAction:(id)sender {
    if ([addRemoveButtons selectedSegment] == 0){ //new book
	NSManagedObject *obj = [[NSManagedObject alloc] initWithEntity:[[managedObjectModel entitiesByName] objectForKey:@"book"]
							insertIntoManagedObjectContext:managedObjectContext];
	[arrayController addObject:obj];

	BooksWindowController *detailWin = [[BooksWindowController alloc] initWithManagedObject:obj];
	if (![NSBundle loadNibNamed:@"Detail" owner:detailWin]) {
	    NSLog(@"Error loading Nib!");
	}
    }else{ //remove book
	int alertReturn = -1;
	int noOfRowsSelected = [tableView numberOfSelectedRows];
	if(noOfRowsSelected == 0){
	    NSRunInformationalAlertPanel(@"Selection Error", @"You must select at least one book to remove." , @"Ok", nil, nil);
	}else if(noOfRowsSelected == 1){
	    alertReturn = NSRunAlertPanel(@"Remove Book?", @"Are you sure you wish to permanently remove this book?",
					  @"No", @"Yes", nil);
	}else if(noOfRowsSelected > 1){
	    alertReturn = NSRunAlertPanel(@"Remove Books?", @"Are you sure you wish to permanently remove these books?",
					  @"No", @"Yes", nil);
	}
	if (alertReturn == NSAlertAlternateReturn){
	    [arrayController remove:self];
	    [self saveAction:self];
	}
    }
}

- (IBAction) aboutClickAction:(id)sender {
	NSDictionary *aboutDict = [NSDictionary dictionaryWithObjectsAndKeys:
				@"Greg Sexton 2009", @"Copyright", nil];
	[[NSApplication sharedApplication] orderFrontStandardAboutPanelWithOptions:aboutDict];
}
@end
