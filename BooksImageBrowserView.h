//
//  BooksImageBrowserView.h
//  books
//
//  Created by Greg on 02/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "book.h"


@interface BooksImageBrowserView : IKImageBrowserView {

    IBOutlet NSArrayController *arrayController;

}

@end



//The item to be used by BooksImageBrowserView

@interface BooksImageBrowserItem : NSObject {

    NSImage* image;
    NSString* imageID;
    
}
@property(readwrite,copy) NSImage * image;
@property(readwrite,copy) NSString * imageID;

- (id)initWithImage:(NSImage *)image imageID:(NSString *)imageID;
- (NSString *)imageUID;
- (NSString *)imageRepresentationType;
- (id)imageRepresentation;
- (NSString*)imageTitle;

@end
