//
// BooksImageBrowserView.m
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

#import "BooksImageBrowserView.h"


@implementation BooksImageBrowserView

- (void)awakeFromNib {
    
    //setup colors TODO: have these as user preferences?
    //[self setValue:[NSColor darkGrayColor] forKey:IKImageBrowserBackgroundColorKey];

}

// Overridden Methods //////////////////////////////////////////////////////

- (void)keyDown:(NSEvent *)theEvent{

    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];

    if (key == NSDeleteCharacter || key == NSBackspaceCharacter){
	[viewController removeSelectedItems];
    }else{
	//pass on to next first responder if not going to handle it
	[super keyDown:theEvent];
    }

}

@end




//////////////////////////////////////////////////////////////////////////////////////////////





//The item to be used by BooksImageBrowserView
@implementation BooksImageBrowserItem

- (id)initWithImage:(NSImage*)anImage imageID:(NSString*)anImageID subtitle:(NSString*)aSubtitle{
    if (self = [super init]) {
	    image = [anImage copy];
	    imageID = [anImageID copy];
	    imageSub = [aSubtitle copy];
    }
    return self;
}

- (void)dealloc{
    [image release];
    [imageID release];
    [super dealloc];
}

- (NSString *) imageUID{
    return imageID;
}

- (NSString *) imageRepresentationType{
    return IKImageBrowserNSImageRepresentationType;
}

- (id) imageRepresentation{
    return image;
}

- (NSString*) imageTitle{
    return imageID;
}

- (NSString*) imageSubtitle{
    return imageSub;
}

@end
