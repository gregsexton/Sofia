//
//  BooksImageBrowserView.m
//  books
//
//  Created by Greg on 02/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
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
