//
// BooksWindowController.m
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

#import "BooksWindowController.h"

//TODO: TOC formatting. Save the format? Remove formatting at the download stage?

@implementation BooksWindowController

@synthesize obj;
@synthesize delegate;
@synthesize displaySearch;

- (id)init {
    self = [super init];
    return self;
}

- (id)initWithManagedObject:(book*)object withSearch:(BOOL)withSearch{
    self = [super init];
    obj = [object retain];
    managedObjectContext = [obj managedObjectContext];
    displaySearch = !withSearch;
    isbnSearchErrors = [[NSMutableArray alloc] initWithCapacity:2];
    return self;
}

- (void) dealloc{
    [obj release];
    [isbnSearchErrors release];
    [super dealloc];
}

- (void) awakeFromNib {
    [window makeKeyAndOrderFront:self];
    if (obj != nil){
	[self updateUIFromManagedObject];
	[self updateSummaryTabView];
    }
    [authorsTableView setDoubleAction:@selector(doubleClickAuthorAction:)];
    [authorsTableView setTarget:self]; 
    [subjectsTableView setDoubleAction:@selector(doubleClickSubjectAction:)];
    [subjectsTableView setTarget:self]; 
}

- (NSManagedObjectContext *) managedObjectContext{
    if (managedObjectContext != nil)
        return managedObjectContext;
    return nil;
}

- (void) saveManagedObjectContext:(NSManagedObjectContext*)context {

    NSError *error = nil;
    if (![context save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }

}

- (void) searchForISBN:(NSString*)isbn{
    //programatically search for an isbn
    [txt_search setStringValue:isbn];
    [self searchClicked:self];
}

- (void) updateManagedObjectFromUI {
    if (obj != nil){
	[obj setIsbn10:		    [txt_isbn10 stringValue]];
	[obj setIsbn13:	    	    [txt_isbn13 stringValue]];
	[obj setAuthorText: 	    [txt_author stringValue]];
	[obj setSubjectText:	    [txt_subject stringValue]];
	[obj setAwards:		    [txt_awards stringValue]];
	[obj setDewey:		    [txt_dewey stringValue]];
	[obj setDewey_normalised:   [txt_deweyNormal stringValue]];
	[obj setEdition:	    [txt_edition stringValue]];
	[obj setLanguage:	    [txt_language stringValue]];
	[obj setLccNumber:	    [txt_lccNumber stringValue]];
	[obj setNotes:		    [txt_notes stringValue]];
	[obj setPhysicalDescription:[txt_physicalDescrip stringValue]];
	[obj setPublisherText:	    [txt_publisher stringValue]];
	[obj setSummary:	    [txt_summary stringValue]];
	[obj setTitle:		    [txt_title stringValue]];
	[obj setTitleLong:	    [txt_titleLong stringValue]];
	[obj setUrls:		    [txt_urls stringValue]];
	[obj setNoOfCopies:	    [txt_noOfCopies stringValue]];
	[obj setCoverImage:	    [img_summary_cover image]];
	[obj setToc:		    [txt_toc string]];
    }
}

- (void) updateUIFromManagedObject {
    if (obj != nil){
	if([obj isbn10] != nil){
	    [txt_isbn10 setStringValue:[obj isbn10]];
	}
	if([obj isbn13] != nil){
	    [txt_isbn13 setStringValue:[obj isbn13]];
	}
	if([obj edition] != nil){
	    [txt_edition setStringValue:[obj edition]];
	}
	if([obj dewey] != nil){
	    [txt_dewey setStringValue:[obj dewey]];
	}
	if([obj dewey_normalised] != nil){
	    [txt_deweyNormal setStringValue:[obj dewey_normalised]];
	}
	if([obj lccNumber] != nil){
	    [txt_lccNumber setStringValue:[obj lccNumber]];
	}
	if([obj language] != nil){
	    [txt_language setStringValue:[obj language]];
	}

	if([obj summary] != nil){
	    [txt_summary setStringValue:[obj summary]];
	}
	if([obj notes] != nil){
	    [txt_notes setStringValue:[obj notes]];
	}
	if([obj awards] != nil){
	    [txt_awards setStringValue:[obj awards]];
	}
	if([obj urls] != nil){
	    [txt_urls setStringValue:[obj urls]];
	}
	if([obj noOfCopies] != nil){
	    [txt_noOfCopies setIntValue:[[obj noOfCopies] intValue]];
	    [step_noOfCopies setIntValue:[[obj noOfCopies] intValue]];
	}

	if([obj title] != nil){
	    [txt_title addItemWithObjectValue:[obj title]];
	    [txt_title selectItemAtIndex:0];
	}
	if([obj titleLong] != nil){
	    [txt_titleLong addItemWithObjectValue:[obj titleLong]];
	    [txt_titleLong selectItemAtIndex:0];
	}
	if([obj publisherText] != nil){
	    [txt_publisher addItemWithObjectValue:[obj publisherText]];
	    [txt_publisher selectItemAtIndex:0];
	}
	if([obj authorText] != nil){
	    [txt_author addItemWithObjectValue:[obj authorText]];
	    [txt_author selectItemAtIndex:0];
	}
	if([obj subjectText] != nil){
	    [txt_subject addItemWithObjectValue:[obj subjectText]];
	    [txt_subject selectItemAtIndex:0];
	}
	if([obj physicalDescription] != nil){
	    [txt_physicalDescrip addItemWithObjectValue:[obj physicalDescription]];
	    [txt_physicalDescrip selectItemAtIndex:0];
	}

	if([obj coverImage] != nil){
	    NSImage* img = [obj coverImage];
	    [img_summary_cover setImage:img];
	    [img_cover setImage:img];
	}
	if([obj toc] != nil){
	    [txt_toc setString:@""]; //no setString method that accepts NSAttributedString
	    [txt_toc insertText:[obj toc]];
	}

	[self updateSummaryTabView];
    }
}

- (BOOL) updateUIFromAmazonWithISBN:(NSString*)searchedISBN {

    amazonInterface* amazon = [[amazonInterface alloc] init];

    if(![amazon searchISBN:searchedISBN]){
	[self displayErrorMessage:@"Unable to retrieve information from Amazon. Please check internet connectivity and a valid access key in your preferences."];
	[amazon release];
	return false;
    }

    if(![amazon successfullyFoundBook]){
	[isbnSearchErrors addObject:@"Amazon"];
	[self displayErrorMessage:[NSString stringWithFormat:@"No results found for this ISBN on %@.", 
							    [self stringFromArrayWithCombiners:isbnSearchErrors]]];
	[amazon release];
	return false;
    }

    //NSLog([amazon imageURL]);
    [img_summary_cover setImage:[amazon frontCover]];
    [img_cover setImage:[amazon frontCover]];

    BOOL downloadTOC = [[NSUserDefaults standardUserDefaults] boolForKey:@"download_toc"];
    if(downloadTOC){
	[txt_toc setString:@""]; //no setString method that accepts NSAttributedString
	[txt_toc insertText:[amazon getTableOfContentsFromURL:[amazon amazonLink]]];
    }

    [amazon release];

    return true;
}

- (BOOL) updateUIFromISBNDbWithISBN:(NSString*)searchedISBN {

    isbndbInterface *isbndb = [[isbndbInterface alloc] init];
    if(![isbndb searchISBN:searchedISBN]){
	[self displayErrorMessage:@"Unable to retrieve information from ISBNDb. Please check internet connectivity and a valid access key in your preferences."];
	[isbndb release];
	return false;
    }

    if(![isbndb successfullyFoundBook]){
	[isbnSearchErrors addObject:@"ISBNDb"];
	[self displayErrorMessage:[NSString stringWithFormat:@"No results found for this ISBN on %@.", 
							    [self stringFromArrayWithCombiners:isbnSearchErrors]]];
	[isbndb release];
	return false;
    }

    //programmatically set ui elements
    [txt_isbn10 setStringValue:[isbndb bookISBN10]];
    [txt_isbn13 setStringValue:[isbndb bookISBN13]];
    [txt_edition setStringValue:[isbndb bookEdition]];
    [txt_dewey setStringValue:[isbndb bookDewey]];
    [txt_deweyNormal setStringValue:[isbndb bookDeweyNormalized]];
    [txt_lccNumber setStringValue:[isbndb bookLCCNumber]];
    [txt_language setStringValue:[isbndb bookLanguage]];

    [txt_summary setStringValue:[isbndb bookSummary]];
    [txt_notes setStringValue:[isbndb bookNotes]];
    [txt_awards setStringValue:[isbndb bookAwards]];
    [txt_urls setStringValue:[isbndb bookUrls]];

    [txt_title addItemWithObjectValue:[isbndb bookTitle]];
    [txt_title selectItemAtIndex:0];
    [txt_titleLong addItemWithObjectValue:[isbndb bookTitleLong]];
    [txt_titleLong selectItemAtIndex:0];
    [txt_publisher addItemWithObjectValue:[isbndb bookPublisher]];
    [txt_publisher selectItemAtIndex:0];
    [txt_author addItemWithObjectValue:[isbndb bookAuthorsText]];
    [txt_author selectItemAtIndex:0];
    [txt_subject addItemWithObjectValue:[isbndb bookSubjectText]];
    [txt_subject selectItemAtIndex:0];
    [txt_physicalDescrip addItemWithObjectValue:[isbndb bookPhysicalDescrip]];
    [txt_physicalDescrip selectItemAtIndex:0];

    [self updateAuthorsAndSubjectsFromISBNDb:isbndb];
    
    [isbndb release];
    return true;
}

- (void) updateAuthorsAndSubjectsFromISBNDb:(isbndbInterface*)isbndb{
    //loop over authors and subject arrays and update tables

    NSString *object;
    //update authors
    NSEnumerator *baEnum = [[isbndb bookAuthors] objectEnumerator];
    while (object = [baEnum nextObject]) {
	author *authorObj;
	NSFetchRequest *request = [self authorExistsWithName:object];
	if(request != nil){
	    //author with exact name already exists HACK WARNING: this may not be the same author, the author may be named differently etc
	    //TODO: fix this! possibly do another isbndb lookup to see if it is the same author?
	    NSError *error;
	    authorObj = [[managedObjectContext executeFetchRequest:request error:&error] objectAtIndex:0];
	}else{
	    authorObj = [NSEntityDescription insertNewObjectForEntityForName:@"author" inManagedObjectContext:managedObjectContext];
	}
	[authorObj setValue:object forKey:@"name"];
	[authorObj addBooksObject:obj];
    }
    //update subjects
    NSEnumerator *bsEnum = [[isbndb bookSubjects] objectEnumerator];
    while (object = [bsEnum nextObject]) {
	subject *subjectObj;
	NSFetchRequest *request = [self subjectExistsWithName:object];
	if(request != nil){
	    //subject with exact name already exists -- add to this instead of creating a new subject
	    NSError *error;
	    subjectObj = [[managedObjectContext executeFetchRequest:request error:&error] objectAtIndex:0];
	}else{
	    subjectObj = [NSEntityDescription insertNewObjectForEntityForName:@"subject" inManagedObjectContext:managedObjectContext];
	}
	[subjectObj setValue:object forKey:@"name"];
	[subjectObj addBooksObject:obj];
    }
}

- (void) clearAllFields {
    [txt_isbn10 setStringValue:@""];
    [txt_isbn13 setStringValue:@""];
    [txt_edition setStringValue:@""];
    [txt_dewey setStringValue:@""];
    [txt_deweyNormal setStringValue:@""];
    [txt_lccNumber setStringValue:@""];
    [txt_language setStringValue:@""];
    [txt_noOfCopies setStringValue:@"1"];

    [txt_summary setStringValue:@""];
    [txt_notes setStringValue:@""];
    [txt_awards setStringValue:@""];
    [txt_urls setStringValue:@""];

    [txt_title removeAllItems];
    [txt_title setStringValue:@""];
    [txt_titleLong removeAllItems];
    [txt_titleLong setStringValue:@""];
    [txt_publisher removeAllItems];
    [txt_publisher setStringValue:@""];
    [txt_author removeAllItems];
    [txt_author setStringValue:@""];
    [txt_subject removeAllItems];
    [txt_subject setStringValue:@""];
    [txt_physicalDescrip removeAllItems];
    [txt_physicalDescrip setStringValue:@""];

    [img_summary_cover setImage:nil];
    [img_cover setImage:nil];

    [self updateSummaryTabView];
}

- (void) updateSummaryTabView{
    [lbl_summary_isbn10		    setStringValue:[txt_isbn10 stringValue]];
    [lbl_summary_isbn13	    	    setStringValue:[txt_isbn13 stringValue]];
    [lbl_summary_edition    	    setStringValue:[txt_edition stringValue]];
    [lbl_summary_dewey		    setStringValue:[txt_dewey stringValue]];
    [lbl_summary_deweyNormal	    setStringValue:[txt_deweyNormal stringValue]];
    [lbl_summary_lccNumber	    setStringValue:[txt_lccNumber stringValue]];
    [lbl_summary_language   	    setStringValue:[txt_language stringValue]];
    [lbl_summary_noOfCopies 	    setStringValue:[txt_noOfCopies stringValue]];
    [lbl_summary_summary    	    setStringValue:[txt_summary stringValue]];
    
    [lbl_summary_title		    setStringValue:[txt_title stringValue]];
    [lbl_summary_titleLong	    setStringValue:[txt_titleLong stringValue]];
    [lbl_summary_author		    setStringValue:[txt_author stringValue]];
    [lbl_summary_publisher	    setStringValue:[txt_publisher stringValue]];
    [lbl_summary_subject	    setStringValue:[txt_subject stringValue]];
    [lbl_summary_physicalDescrip    setStringValue:[txt_physicalDescrip stringValue]];
}

- (void)displayErrorMessage:(NSString*)error{
    [self removeErrorMessage:self];
    [errorLabel setStringValue:error];
    [errorLabel setHidden:NO];

    CABasicAnimation *animation = [CABasicAnimation animation];
    [animation setValue:@"errorLabelDisplay" forKey:@"name"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setDuration:0.5f];
    [animation setDelegate:self]; //delegate fades the error message back out see animationDidStop:finished:

    [errorLabel setAnimations:[NSDictionary dictionaryWithObject:animation forKey:@"alphaValue"]];
    [[errorLabel animator] setAlphaValue:1.0];
}

- (IBAction)removeErrorMessage:(id)sender{
    [errorLabel setHidden:YES];
    [errorLabel setAlphaValue:0.0];
}

- (NSFetchRequest*) authorExistsWithName:(NSString*)authorName{
    //returns the request in order to get hold of these authors
    //otherwise returns nil if the author cannot be found.
    return [self entity:@"author" existsWithName:authorName];
}

- (NSFetchRequest*) subjectExistsWithName:(NSString*)subjectName{
    //returns the request in order to get hold of these subjects
    //otherwise returns nil if the subject cannot be found.
    return [self entity:@"subject" existsWithName:subjectName];
}

- (NSFetchRequest*)entity:(NSString*)entity existsWithName:(NSString*)entityName{
    NSError *error;
    //TODO: stip ' characters from this and any other instances -- real world haskell produces this bug.
    NSString *predicate = [[NSString alloc] initWithFormat:@"name MATCHES '%@'", entityName];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:entity inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:predicate]];

    [predicate release];

    if([managedObjectContext countForFetchRequest:request error:&error] > 0){
	return [request autorelease];
    }else{
	[request release];
	return nil;
    }
}

- (BOOL)bookExistsInLibraryWithISBN:(NSString*)searchedISBN{ //has possible side effects
    //could use [self entity:existsWithName:] ?
    NSError *error;
    NSString *predicate = [[NSString alloc] initWithFormat:@"isbn10 MATCHES '%@' OR isbn13 MATCHES '%@'",
							   searchedISBN,
							   searchedISBN];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"book" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:predicate]];
    [predicate release];
    if([managedObjectContext countForFetchRequest:request error:&error] > 0){
        //[[NSApplication sharedApplication] presentError:error];
	int alertReturn;
	alertReturn = NSRunInformationalAlertPanel(@"Duplicate Entry",
						   @"A book with this ISBN number is already in your library.",
						   @"Cancel",
						   @"Display",
						   nil);
	if (alertReturn == NSAlertAlternateReturn){
	    [managedObjectContext deleteObject:obj];
	    //get hold of existing object and update UI.
	    [self setObj:[[managedObjectContext executeFetchRequest:request error:&error] objectAtIndex:0]];
	    [self updateUIFromManagedObject];
	}
	[request release];
	return true;
    }
    [request release];
    return false;
}

- (NSString*)stringFromArrayWithCombiners:(NSArray*)array{
    //this function returns a string of the form "foo, bar and foobar"
    //from the array ["foo", "bar", "foobar"]

    if([array count] <= 0)
	return @"";
    if([array count] == 1)
	return [array objectAtIndex:0];

    NSString* buildUp = [array objectAtIndex:0];

    for(int i=1; i < [array count]-1; i++){
	buildUp = [NSString stringWithFormat:@"%@, %@", buildUp, [array objectAtIndex:i]];
    }

    buildUp = [NSString stringWithFormat:@"%@ or %@", buildUp, [array lastObject]];

    return buildUp;

}

- (IBAction) searchClicked:(id)sender {
    [self removeErrorMessage:self];
    [isbnSearchErrors removeAllObjects];

    isbnExtractor* extractor = [[isbnExtractor alloc] initWithContent:[txt_search stringValue]];
    NSArray* isbns = [extractor discoveredISBNs];
    [extractor release];
    if([isbns count] != 1){
	[self displayErrorMessage:@"Please search for a book by the ISBN number."];
	return;
    }

    NSString* searchedISBN = [isbns objectAtIndex:0]; //this will produce a formatted isbn, e.g hyphens removed

    if([self bookExistsInLibraryWithISBN:searchedISBN])
	return;

    [progIndicator setUsesThreadedAnimation:true];
    [progIndicator startAnimation:self];
    [NSApp beginSheet:progressSheet modalForWindow:window 
				     modalDelegate:self 
				    didEndSelector:NULL 
				       contextInfo:nil];
    
    [self clearAllFields];
    if ([self updateUIFromISBNDbWithISBN:searchedISBN]) {
	[txt_title selectItemAtIndex:0];
	[txt_titleLong selectItemAtIndex:0];
	[txt_author selectItemAtIndex:0];
	[txt_subject selectItemAtIndex:0];
	[txt_publisher selectItemAtIndex:0];
	[txt_physicalDescrip selectItemAtIndex:0];
    }

    [self updateUIFromAmazonWithISBN:searchedISBN];
    
    //lastly update the summary tab
    [self updateSummaryTabView];

    [progIndicator stopAnimation:self];
    [progressSheet orderOut:nil];
    [NSApp endSheet:progressSheet];
}

- (IBAction)saveClicked:(id)sender {
    [self updateManagedObjectFromUI];
    [self saveManagedObjectContext:managedObjectContext];
    [window close];

    if([[self delegate] respondsToSelector:@selector(saveClicked:)]){
	[delegate saveClicked:self];
    }
}

- (IBAction) clearClicked:(id)sender {
    [txt_search setStringValue:@""];
    [self clearAllFields];
}

- (IBAction) cancelClicked:(id)sender {
    [managedObjectContext rollback];
    [window close];

    if([[self delegate] respondsToSelector:@selector(cancelClicked:)]){
	[delegate cancelClicked:self];
    }
}

- (IBAction) copiesValueChanged:(id)sender {
    int theValue = [sender intValue];

    [step_noOfCopies setIntValue:theValue];
    [txt_noOfCopies setIntValue:theValue];
}

///////////////////////    DELEGATE METHODS   //////////////////////////////////////////////////////////////////////////

- (BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem{
    [self updateSummaryTabView];
    return true;
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag{

    if(flag && [[animation valueForKey:@"name"] isEqual:@"errorLabelDisplay"]){

	CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
/*	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];*/
	[animation setValues:[NSArray arrayWithObjects:[NSNumber numberWithFloat:1.0],
						       [NSNumber numberWithFloat:0.0], nil]];
	[animation setKeyTimes:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.8],
							 [NSNumber numberWithFloat:1.0], nil]];
	[animation setDuration:6.0f];

	[errorLabel setAnimations:[NSDictionary dictionaryWithObject:animation forKey:@"alphaValue"]];
	[[errorLabel animator] setAlphaValue:0.0];
    }
}

//author methods
- (IBAction) doubleClickAuthorAction:(id)sender {
    //use the first object if multiple are selected
    author *authorobj = [[authorsArrayController selectedObjects] objectAtIndex:0];
    doubleClickedAuthor = authorobj;
    [self displayManagedAuthorsWithSelectedAuthor:authorobj];
}

- (void) savedWithAuthorSelection:(author*)selectedAuthor{ //delegate method
    if(doubleClickedAuthor != nil){
	[doubleClickedAuthor removeBooksObject:obj];
	doubleClickedAuthor = nil;
    }
    [selectedAuthor addBooksObject:obj];
}

- (void) displayManagedAuthorsWithSelectedAuthor:(author*)authorObj{
    AuthorsWindowController *detailWin = [[AuthorsWindowController alloc] initWithManagedObjectContext:managedObjectContext
									  selectedAuthor:authorObj 
									    selectButton:true];
    [detailWin setDelegate:self];
    if (![NSBundle loadNibNamed:@"AuthorDetail" owner:detailWin]) {
	NSLog(@"Error loading Nib!");
    }
}

- (IBAction)addAuthorClicked:(id)sender{
    doubleClickedAuthor = nil; //just to make sure!
    [self displayManagedAuthorsWithSelectedAuthor:nil];
}

//subject methods
- (IBAction) doubleClickSubjectAction:(id)sender {
    //use the first object if multiple are selected
    subject *subjectobj = [[subjectsArrayController selectedObjects] objectAtIndex:0];
    doubleClickedSubject = subjectobj;
    [self displayManagedSubjectsWithSelectedSubject:subjectobj];
}

- (void) savedWithSubjectSelection:(subject*)selectedSubject{ //delegate method
    if(doubleClickedSubject != nil){
	[doubleClickedSubject removeBooksObject:obj];
	doubleClickedSubject = nil;
    }
    [selectedSubject addBooksObject:obj];
}

- (void) displayManagedSubjectsWithSelectedSubject:(subject*)subjectObj{
    SubjectWindowController *detailWin = [[SubjectWindowController alloc] initWithManagedObjectContext:managedObjectContext
									  selectedSubject:subjectObj 
									     selectButton:true];
    [detailWin setDelegate:self];
    if (![NSBundle loadNibNamed:@"SubjectDetail" owner:detailWin]) {
	NSLog(@"Error loading Nib!");
    }
}

- (IBAction)addSubjectClicked:(id)sender{
    doubleClickedSubject = nil; //just to make sure!
    [self displayManagedSubjectsWithSelectedSubject:nil];
}

@end
