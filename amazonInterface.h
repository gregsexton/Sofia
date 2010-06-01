//
//  amazonInterface.h
//  books
//
//  Created by Greg on 26/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface amazonInterface : NSObject <NSXMLParserDelegate>{

    NSString* accessKey;
    NSString* secretAccessKey;

    NSString*	imageURL;
    NSImage*	frontCover;

    int currentProperty;
    NSMutableString* currentStringValue;
    enum amazonProperties {pNone, pLargeImage, pImageURL};
}

@property (nonatomic,copy) NSString* imageURL;
@property (nonatomic,copy) NSImage* frontCover;

- (BOOL)searchISBN:(NSString*)isbn;
- (BOOL)searchForImagesWithISBN:(NSString*)isbn;
- (BOOL)processImagesWithUrl:(NSURL*)url;
@end
