//
//  BooksImageBrowserView.h
//  books
//
//  Created by Greg on 02/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
@class BooksImageBrowserController;


@interface BooksImageBrowserView : IKImageBrowserView {

    IBOutlet BooksImageBrowserController* viewController;

}

@end



//The item to be used by BooksImageBrowserView

@interface BooksImageBrowserItem : NSObject {

    NSImage* image;
    NSString* imageID;
    NSString* imageSub;
    
}
@property(readwrite,copy) NSImage * image;
@property(readwrite,copy) NSString * imageID;

- (id)initWithImage:(NSImage*)anImage imageID:(NSString*)anImageID subtitle:(NSString*)aSubtitle;
- (NSString *)imageUID;
- (NSString *)imageRepresentationType;
- (id)imageRepresentation;
- (NSString*)imageTitle;

@end
