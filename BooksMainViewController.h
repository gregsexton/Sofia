//
// BooksMainViewController.h
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

#import <Cocoa/Cocoa.h>
#import "SidebarOutlineView.h"
#import "SofiaApplication.h"
#import "ExternalLinkEditorController.h"
#import "book.h"

#define SofiaDragType @"SofiaDragType"

@interface BooksMainViewController : NSViewController <BooksWindowControllerDelegate>{

    NSArrayController *arrayController;
    SidebarOutlineView* sideBar;
    SofiaApplication* application;
}
@property (nonatomic, assign) IBOutlet NSArrayController *arrayController;
@property (nonatomic, assign) IBOutlet SidebarOutlineView* sideBar;
@property (nonatomic, assign) IBOutlet SofiaApplication* application;

- (void)removeSelectedItems;
- (void)writeBooksWithIndexes:(NSIndexSet*)rowIndexes toPasteboard:(NSPasteboard*)pboard;
- (void)openDetailWindowForBook:(book*)obj;

- (NSMenu*)menuForBook:(book*)bookObj;
- (NSMenu*)submenuViewBookOnForBook:(book*)bookObj;
- (NSDictionary*)createDefaultViewBookOnMenuItems;
- (NSString*)parseFormatString:(NSString*)formatString usingBook:(book*)bookObj;
- (IBAction)menuOpenDetailWindowForBook:(id)sender;
- (IBAction)menuOpenBrowserUrlForBook:(id)sender;

@end
