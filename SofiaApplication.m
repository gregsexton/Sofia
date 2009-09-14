//
//  SofiaApplication.m
//  books
//
//  Created by Greg Sexton on 14/09/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SofiaApplication.h"
#import "OverviewWindowController.h"


@implementation SofiaApplication

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	//launch overview window.
	NSLog(@"Got here.");
	OverviewWindowController *winController = [[OverviewWindowController alloc] init];
	[NSBundle loadNibNamed:@"Overview" owner:winController];
}
@end
