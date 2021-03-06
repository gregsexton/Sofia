//
// BooksImageBrowserView.h
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
#import <Quartz/Quartz.h>
@class BooksImageBrowserController;


@interface BooksImageBrowserView : IKImageBrowserView {

    BooksImageBrowserController* viewController;

}
@property (nonatomic, assign) IBOutlet BooksImageBrowserController* viewController;

@end



//The item to be used by BooksImageBrowserView

@interface BooksImageBrowserItem : NSObject {

    NSImage* image;
    NSString* imageID;
    NSString* imageSub;
    NSUInteger version;

}

- (id)initWithImage:(NSImage*)anImage imageID:(NSString*)anImageID subtitle:(NSString*)aSubtitle version:(NSUInteger)aVersion;
- (NSString *)imageUID;
- (NSString *)imageRepresentationType;
- (id)imageRepresentation;
- (NSString*)imageTitle;

@end
