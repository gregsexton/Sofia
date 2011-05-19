//
// BooksWindowController.m
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

#import "BooksWindowController.h"

//TODO: TOC formatting. Save the format? Remove formatting at the download stage?

@implementation BooksWindowController

@synthesize obj;
@synthesize delegate;
@synthesize displaySearch;

@synthesize txt_search;

@synthesize txt_isbn10;
@synthesize txt_isbn13;
@synthesize txt_title;
@synthesize txt_titleLong;
@synthesize txt_author;
@synthesize txt_publisher;
@synthesize txt_subject;
@synthesize txt_edition;
@synthesize txt_physicalDescrip;
@synthesize txt_dewey;
@synthesize txt_deweyNormal;
@synthesize txt_lccNumber;
@synthesize txt_language;
@synthesize txt_noOfCopies;
@synthesize step_noOfCopies;

@synthesize txt_summary;
@synthesize txt_notes;
@synthesize txt_awards;
@synthesize txt_urls;

@synthesize txt_toc;

@synthesize btn_search;
@synthesize btn_clear;
@synthesize btn_save;
@synthesize btn_cancel;

//for the summary tab
@synthesize lbl_summary_isbn10;
@synthesize lbl_summary_isbn13;
@synthesize lbl_summary_title;
@synthesize lbl_summary_titleLong;
@synthesize lbl_summary_author;
@synthesize lbl_summary_publisher;
@synthesize lbl_summary_subject;
@synthesize lbl_summary_edition;
@synthesize lbl_summary_physicalDescrip;
@synthesize lbl_summary_dewey;
@synthesize lbl_summary_deweyNormal;
@synthesize lbl_summary_lccNumber;
@synthesize lbl_summary_language;
@synthesize lbl_summary_noOfCopies;
@synthesize lbl_summary_summary;

@synthesize img_summary_cover;
@synthesize img_cover;

@synthesize authorsTableView;
@synthesize subjectsTableView;
@synthesize progIndicator;

//top level objects
@synthesize managedObjectContext;
@synthesize bookObjectController;
@synthesize authorsArrayController;
@synthesize subjectsArrayController;
@synthesize similarBooksController;
@synthesize reviewsController;
@synthesize progressSheet;

@synthesize errorLabel;

- (id)initWithManagedObject:(book*)object withApp:(SofiaApplication*)app withSearch:(BOOL)withSearch{
    self = [super init];
    [self setObj:object];
    displaySearch        = !withSearch;
    sofiaApplication     = app;
    isbnSearchErrors     = [[NSMutableArray alloc] initWithCapacity:2];
    return self;
}

- (void)dealloc{
    [isbnSearchErrors release];

    //release retained properties
    [obj release];

    //release top level nib objects
    [managedObjectContext    release];
    [bookObjectController    release];
    [authorsArrayController  release];
    [subjectsArrayController release];
    [similarBooksController  release];
    [reviewsController       release];
    [progressSheet           release];

    [super dealloc];
}

- (void)awakeFromNib {
    [[self window] makeKeyAndOrderFront:self];
    if (obj != nil){
        [self updateUIFromManagedObject];
        [self updateSummaryTabView];
    }

    [similarBooksController setApplication:sofiaApplication];
    [bookObjectController setContent:[self obj]];
    NSPersistentStoreCoordinator* coord = [[obj managedObjectContext] persistentStoreCoordinator];
    [managedObjectContext setPersistentStoreCoordinator:coord];

    [authorsTableView setDoubleAction:@selector(doubleClickAuthorAction:)];
    [authorsTableView setTarget:self];
    [subjectsTableView setDoubleAction:@selector(doubleClickSubjectAction:)];
    [subjectsTableView setTarget:self];
}

- (void)loadWindow{
    if (![NSBundle loadNibNamed:@"Detail" owner:self]) {
	NSLog(@"Error loading Nib!");
        return;
    }
}

- (void)saveManagedObjectContext{
    [sofiaApplication saveAction:self];
}

- (void)searchForISBN:(NSString*)isbn{
    //programatically search for an isbn
    [txt_search setStringValue:isbn];
    [self searchClicked:self];
}

- (void)updateManagedObjectFromUI {
    if (obj != nil){
        [obj setIsbn10:              [txt_isbn10          stringValue]];
        [obj setIsbn13:              [txt_isbn13          stringValue]];
        [obj setAuthorText:          [txt_author          stringValue]];
        [obj setSubjectText:         [txt_subject         stringValue]];
        [obj setAwards:              [txt_awards          string]];
        [obj setDewey:               [txt_dewey           stringValue]];
        [obj setDewey_normalised:    [txt_deweyNormal     stringValue]];
        [obj setEdition:             [txt_edition         stringValue]];
        [obj setLanguage:            [txt_language        stringValue]];
        [obj setLccNumber:           [txt_lccNumber       stringValue]];
        [obj setNotes:               [txt_notes           string]];
        [obj setPhysicalDescription: [txt_physicalDescrip stringValue]];
        [obj setPublisherText:       [txt_publisher       stringValue]];
        [obj setSummary:             [txt_summary         string]];
        [obj setTitle:               [txt_title           stringValue]];
        [obj setTitleLong:           [txt_titleLong       stringValue]];
        [obj setUrls:                [txt_urls            string]];
        [obj setCoverImageImage:     [img_summary_cover   image]];
        [obj setToc:                 [txt_toc             string]];
        [obj setNoOfCopies:          (NSDecimalNumber*)[NSDecimalNumber     numberWithInteger:[txt_noOfCopies integerValue]]];
    }
}

- (void)updateUIFromManagedObject{ //TODO: refactor
    if(obj){
        [txt_isbn10      setStringValue:[obj isbn10]           ? [obj isbn10]           : @""];
        [txt_isbn13      setStringValue:[obj isbn13]           ? [obj isbn13]           : @""];
        [txt_edition     setStringValue:[obj edition]          ? [obj edition]          : @""];
        [txt_dewey       setStringValue:[obj dewey]            ? [obj dewey]            : @""];
        [txt_deweyNormal setStringValue:[obj dewey_normalised] ? [obj dewey_normalised] : @""];
        [txt_lccNumber   setStringValue:[obj lccNumber]        ? [obj lccNumber]        : @""];
        [txt_language    setStringValue:[obj language]         ? [obj language]         : @""];

        [txt_summary     setString:[obj summary] ? [obj summary] : @""];
        [txt_notes       setString:[obj notes]   ? [obj notes]   : @""];
        [txt_awards      setString:[obj awards]  ? [obj awards]  : @""];
        [txt_urls        setString:[obj urls]    ? [obj urls]    : @""];

        if([obj noOfCopies]){
            [txt_noOfCopies setIntValue:[[obj noOfCopies] intValue]];
            [step_noOfCopies setIntValue:[[obj noOfCopies] intValue]];
        }

        if([obj title]){
            [txt_title addItemWithObjectValue:[obj title]];
            [txt_title selectItemAtIndex:0];
        }
        if([obj titleLong]){
            [txt_titleLong addItemWithObjectValue:[obj titleLong]];
            [txt_titleLong selectItemAtIndex:0];
        }
        if([obj publisherText]){
            [txt_publisher addItemWithObjectValue:[obj publisherText]];
            [txt_publisher selectItemAtIndex:0];
        }
        if([obj authorText]){
            [txt_author addItemWithObjectValue:[obj authorText]];
            [txt_author selectItemAtIndex:0];
        }
        if([obj subjectText]){
            [txt_subject addItemWithObjectValue:[obj subjectText]];
            [txt_subject selectItemAtIndex:0];
        }
        if([obj physicalDescription]){
            [txt_physicalDescrip addItemWithObjectValue:[obj physicalDescription]];
            [txt_physicalDescrip selectItemAtIndex:0];
        }

        if([obj coverImageImage]){
            NSImage* img = [obj coverImageImage];
            [img_summary_cover setImage:img];
            [img_cover setImage:img];
        }
        if([obj toc]){
            [txt_toc setString:@""]; //no setString method that accepts NSAttributedString
            [txt_toc insertText:[obj toc]];
        }

        [self updateSummaryTabView];
    }
}

- (BOOL)updateUIFromAmazonWithISBN:(NSString*)searchedISBN {

    amazonInterface* amazon = [[amazonInterface alloc] init];

    if(![amazon searchISBN:searchedISBN]){
        [self displayErrorMessage:@"Unable to retrieve information from Amazon. Please check internet connectivity and a valid access key in your preferences."];
        [amazon release];
        return false;
    }

    if(![amazon successfullyFoundBook]){
        [isbnSearchErrors addObject:@"Amazon"];
        [self displayErrorMessage:[NSString stringWithFormat:@"No results found for this ISBN on %@.",
                                                            [NSString stringFromArray:isbnSearchErrors withCombiner:@"or"]]];
        [amazon release];
        return false;
    }

    //NSLog([amazon imageURL]);
    [img_summary_cover setImage:[amazon frontCover]];
    [img_cover setImage:[amazon frontCover]];

    BOOL downloadTOC = [[NSUserDefaults standardUserDefaults] boolForKey:@"download_toc"];
    if(downloadTOC){
        NSAttributedString* toc = [amazon getTableOfContentsFromURL:[amazon amazonLink]];
        if(toc){
            [txt_toc setString:@""]; //no setString method that accepts NSAttributedString
            [txt_toc insertText:toc];
        }
    }

    if([amazon bookTitle])
        [txt_title addItemWithObjectValue:[amazon bookTitle]];
    if([amazon bookAuthorsText])
        [txt_author addItemWithObjectValue:[amazon bookAuthorsText]];
    if([amazon bookPublisher])
        [txt_publisher addItemWithObjectValue:[amazon bookPublisher]];
    if([amazon bookPhysicalDescrip])
        [txt_physicalDescrip addItemWithObjectValue:[amazon bookPhysicalDescrip]];
    if([amazon bookEdition])
        [txt_edition setStringValue:[amazon bookEdition]];
    if([amazon bookSummary])
        [txt_summary setString:[amazon bookSummary]];

    [amazon release];

    return true;
}

- (BOOL)updateUIFromISBNDbWithISBN:(NSString*)searchedISBN {

    isbndbInterface *isbndb = [[isbndbInterface alloc] init];
    if(![isbndb searchISBN:searchedISBN]){
        [self displayErrorMessage:@"Unable to retrieve information from ISBNDb. Please check internet connectivity and a valid access key in your preferences."];
        [isbndb release];
        return false;
    }

    if(![isbndb successfullyFoundBook]){
        [isbnSearchErrors addObject:@"ISBNDb"];
        [self displayErrorMessage:[NSString stringWithFormat:@"No results found for this ISBN on %@.",
                                                            [NSString stringFromArray:isbnSearchErrors withCombiner:@"or"]]];
        [isbndb release];
        return false;
    }

    //programmatically set ui elements
    [txt_isbn10 setStringValue:[isbndb bookISBN10]];
    [txt_isbn13 setStringValue:[isbndb bookISBN13]];

    if([[txt_edition stringValue] isEqualToString:@""])
        [txt_edition setStringValue:[isbndb bookEdition]];

    [txt_dewey       setStringValue:[isbndb bookDewey]];
    [txt_deweyNormal setStringValue:[isbndb bookDeweyNormalized]];
    [txt_lccNumber   setStringValue:[isbndb bookLCCNumber]];
    [txt_language    setStringValue:[isbndb bookLanguage]];

    if([[txt_summary string] isEqualToString:@""]){
        [txt_summary setString:[isbndb bookSummary]];
    }else{
        [txt_summary setString:[NSString stringWithFormat:@"%@\n\n%@", [txt_summary string], [isbndb bookSummary]]];
    }

    [txt_notes  setString:[isbndb bookNotes]];
    [txt_awards setString:[isbndb bookAwards]];
    [txt_urls   setString:[isbndb bookUrls]];

    [txt_title           addItemWithObjectValue:[isbndb bookTitle]];
    [txt_titleLong       addItemWithObjectValue:[isbndb bookTitleLong]];
    [txt_publisher       addItemWithObjectValue:[isbndb bookPublisher]];
    [txt_author          addItemWithObjectValue:[isbndb bookAuthorsText]];
    [txt_subject         addItemWithObjectValue:[isbndb bookSubjectText]];
    [txt_physicalDescrip addItemWithObjectValue:[isbndb bookPhysicalDescrip]];

    [self updateAuthorsAndSubjectsFromISBNDb:isbndb];

    [isbndb release];
    return true;
}

- (void)updateAuthorsAndSubjectsFromISBNDb:(isbndbInterface*)isbndb{
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
            authorObj = [NSEntityDescription insertNewObjectForEntityForName:@"author" inManagedObjectContext:[obj managedObjectContext]];
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
            subjectObj = [NSEntityDescription insertNewObjectForEntityForName:@"subject" inManagedObjectContext:[obj managedObjectContext]];
        }
        [subjectObj setValue:object forKey:@"name"];
        [subjectObj addBooksObject:obj];
    }
}

- (void)clearAllFields {
    [txt_isbn10             setStringValue:@""];
    [txt_isbn13             setStringValue:@""];
    [txt_edition            setStringValue:@""];
    [txt_dewey              setStringValue:@""];
    [txt_deweyNormal        setStringValue:@""];
    [txt_lccNumber          setStringValue:@""];
    [txt_language           setStringValue:@""];
    [txt_noOfCopies         setStringValue:@"1"];

    [txt_summary            setString:@""];
    [txt_notes              setString:@""];
    [txt_awards             setString:@""];
    [txt_urls               setString:@""];

    [txt_title              removeAllItems];
    [txt_title              setStringValue:@""];
    [txt_titleLong          removeAllItems];
    [txt_titleLong          setStringValue:@""];
    [txt_publisher          removeAllItems];
    [txt_publisher          setStringValue:@""];
    [txt_author             removeAllItems];
    [txt_author             setStringValue:@""];
    [txt_subject            removeAllItems];
    [txt_subject            setStringValue:@""];
    [txt_physicalDescrip    removeAllItems];
    [txt_physicalDescrip    setStringValue:@""];

    [img_summary_cover setImage:nil];
    [img_cover setImage:nil];

    [self updateSummaryTabView];
}

- (void)updateSummaryTabView{
    [lbl_summary_isbn10             setStringValue:[txt_isbn10          stringValue]];
    [lbl_summary_isbn13             setStringValue:[txt_isbn13          stringValue]];
    [lbl_summary_edition            setStringValue:[txt_edition         stringValue]];
    [lbl_summary_dewey              setStringValue:[txt_dewey           stringValue]];
    [lbl_summary_deweyNormal        setStringValue:[txt_deweyNormal     stringValue]];
    [lbl_summary_lccNumber          setStringValue:[txt_lccNumber       stringValue]];
    [lbl_summary_language           setStringValue:[txt_language        stringValue]];
    [lbl_summary_noOfCopies         setStringValue:[txt_noOfCopies      stringValue]];
    [lbl_summary_summary            setStringValue:[txt_summary         string]];

    [lbl_summary_title              setStringValue:[txt_title           stringValue]];
    [lbl_summary_titleLong          setStringValue:[txt_titleLong       stringValue]];
    [lbl_summary_author             setStringValue:[txt_author          stringValue]];
    [lbl_summary_publisher          setStringValue:[txt_publisher       stringValue]];
    [lbl_summary_subject            setStringValue:[txt_subject         stringValue]];
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

- (NSFetchRequest*)authorExistsWithName:(NSString*)authorName{
    //returns the request in order to get hold of these authors
    //otherwise returns nil if the author cannot be found.
    return [self entity:@"author" existsWithName:authorName];
}

- (NSFetchRequest*)subjectExistsWithName:(NSString*)subjectName{
    //returns the request in order to get hold of these subjects
    //otherwise returns nil if the subject cannot be found.
    return [self entity:@"subject" existsWithName:subjectName];
}

- (NSFetchRequest*)entity:(NSString*)entity existsWithName:(NSString*)entityName{
    NSError *error;
    NSString *predicate = [[NSString alloc] initWithFormat:@"name MATCHES '%@'", [entityName escapeSingleQuote]];
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

- (book*)bookInLibraryWithISBN:(NSString*)searchedISBN{
    //could use [self entity:existsWithName:] ?
    NSError *error;
    NSString *predicate = [[NSString alloc] initWithFormat:@"isbn10 MATCHES '%@' OR isbn13 MATCHES '%@'",
                                                           [searchedISBN escapeSingleQuote],
                                                           [searchedISBN escapeSingleQuote]];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"book" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:predicate]];
    [predicate release];
    if([managedObjectContext countForFetchRequest:request error:&error] > 0){
        book* bookObj = [[managedObjectContext executeFetchRequest:request error:NULL] objectAtIndex:0];
        [request release];
        return bookObj;
    }else{
        [request release];
        return nil;
    }
}

- (BOOL)bookExistsInLibraryWithISBN:(NSString*)searchedISBN{ //NOTE: has possible side effects
    book* bookObj = [self bookInLibraryWithISBN:searchedISBN];
    if(bookObj){
        int alertReturn;
        alertReturn = NSRunInformationalAlertPanel(@"Duplicate Entry",
                                                   @"A book with this ISBN number is already in your library.",
                                                   @"Cancel",
                                                   @"Display",
                                                   nil);
        if (alertReturn == NSAlertAlternateReturn){
            [[obj managedObjectContext] deleteObject:obj];
            //get hold of existing object and update UI.
            [self setObj:bookObj];
            [self updateUIFromManagedObject];
        }
        return true;
    }
    return false;
}

- (IBAction)searchClicked:(id)sender {
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
    [NSApp beginSheet:progressSheet modalForWindow:[self window]
                                     modalDelegate:self
                                    didEndSelector:NULL
                                       contextInfo:nil];

    [self clearAllFields];
    if([self updateUIFromAmazonWithISBN:searchedISBN]){
        [self selectFirstItemInComboBox:txt_title];
        [self selectFirstItemInComboBox:txt_author];
        [self selectFirstItemInComboBox:txt_publisher];
        [self selectFirstItemInComboBox:txt_physicalDescrip];
    }

    if([self updateUIFromISBNDbWithISBN:searchedISBN]){
        [self selectFirstItemInComboBox:txt_titleLong];
        [self selectFirstItemInComboBox:txt_subject];
    }

    //lastly update the summary tab
    [self updateSummaryTabView];

    [progIndicator stopAnimation:self];
    [progressSheet orderOut:nil];
    [NSApp endSheet:progressSheet];
}

- (IBAction)saveClicked:(id)sender {
    [self updateManagedObjectFromUI];
    [self saveManagedObjectContext];
    [[self window] close];

    if([[self delegate] respondsToSelector:@selector(saveClicked:)]){
        [delegate saveClicked:self];
    }
}

- (IBAction)clearClicked:(id)sender {
    [txt_search setStringValue:@""];
    [self clearAllFields];
}

- (IBAction)cancelClicked:(id)sender {
    if([[self delegate] respondsToSelector:@selector(cancelClicked:)]){
        [delegate cancelClicked:self];
    }

    [[self window] close];
}

- (IBAction)copiesValueChanged:(id)sender {
    int theValue = [sender intValue];

    [step_noOfCopies setIntValue:theValue];
    [txt_noOfCopies setIntValue:theValue];
}

- (void)selectFirstItemInComboBox:(NSComboBox*)combo{
    if([combo numberOfItems] > 0)
        [combo selectItemAtIndex:0];
}

///////////////////////    DELEGATE METHODS   //////////////////////////////////////////////////////////////////////////

- (BOOL)tabView:(NSTabView*)tabView shouldSelectTabViewItem:(NSTabViewItem*)tabViewItem{
    [self updateSummaryTabView];
    return true;
}

- (void)tabView:(NSTabView*)tabView didSelectTabViewItem:(NSTabViewItem*)tabViewItem{

    if([[tabViewItem identifier] isEqualToString:@"similartab"]){

        if([[txt_isbn13 stringValue] isEqualToString:@""])
            [similarBooksController setISBN:[txt_isbn10 stringValue]];
        else
            [similarBooksController setISBN:[txt_isbn13 stringValue]];
    }

    if([[tabViewItem identifier] isEqualToString:@"reviewstab"]){

        if([[txt_isbn13 stringValue] isEqualToString:@""])
            [reviewsController setISBN:[txt_isbn10 stringValue]];
        else
            [reviewsController setISBN:[txt_isbn13 stringValue]];
    }
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag{

    if(flag && [[animation valueForKey:@"name"] isEqual:@"errorLabelDisplay"]){

        CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
/*      [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];*/
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
- (IBAction)doubleClickAuthorAction:(id)sender {
    //use the first object if multiple are selected
    author *authorobj = [[authorsArrayController selectedObjects] objectAtIndex:0];
    doubleClickedAuthor = authorobj;
    [self displayManagedAuthorsWithSelectedAuthor:authorobj];
}

- (void)savedWithAuthorSelection:(author*)selectedAuthor{ //delegate method
    if(doubleClickedAuthor != nil){
        [doubleClickedAuthor removeBooksObject:obj];
        doubleClickedAuthor = nil;
    }
    [selectedAuthor addBooksObject:obj];
}

- (void)displayManagedAuthorsWithSelectedAuthor:(author*)authorObj{
    AuthorsWindowController *detailWin = [[AuthorsWindowController alloc] initWithPersistentStoreCoordinator:[managedObjectContext persistentStoreCoordinator]
                                                                                                 application:sofiaApplication
                                                                                              selectedAuthor:authorObj
                                                                                                selectButton:true];
    [detailWin setDelegate:self];
    [detailWin loadWindow];
    [[detailWin window] setDelegate:sofiaApplication];
}

- (IBAction)addAuthorClicked:(id)sender{
    doubleClickedAuthor = nil; //just to make sure!
    [self displayManagedAuthorsWithSelectedAuthor:nil];
}

//subject methods
- (IBAction)doubleClickSubjectAction:(id)sender {
    //use the first object if multiple are selected
    subject *subjectobj = [[subjectsArrayController selectedObjects] objectAtIndex:0];
    doubleClickedSubject = subjectobj;
    [self displayManagedSubjectsWithSelectedSubject:subjectobj];
}

- (void)savedWithSubjectSelection:(subject*)selectedSubject{ //delegate method
    if(doubleClickedSubject != nil){
        [doubleClickedSubject removeBooksObject:obj];
        doubleClickedSubject = nil;
    }
    [selectedSubject addBooksObject:obj];
}

- (void)displayManagedSubjectsWithSelectedSubject:(subject*)subjectObj{
    SubjectWindowController *detailWin = [[SubjectWindowController alloc] initWithPersistentStoreCoordinator:[managedObjectContext persistentStoreCoordinator]
                                                                                                     withApp:sofiaApplication
                                                                                             selectedSubject:subjectObj
                                                                                                selectButton:true];
    [detailWin setDelegate:self];
    [detailWin loadWindow];
    [[detailWin window] setDelegate:sofiaApplication];
}

- (IBAction)addSubjectClicked:(id)sender{
    doubleClickedSubject = nil; //just to make sure!
    [self displayManagedSubjectsWithSelectedSubject:nil];
}

@end
