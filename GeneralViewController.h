//
//  GeneralViewController.h
//  books
//
//  Created by Greg on 28/11/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBPreferencesController.h"


@interface GeneralViewController : NSViewController <MBPreferencesModule> {

}

- (NSString *)identifier;
- (NSImage *)image;

@end
