//
//  GeneralViewController.m
//  books
//
//  Created by Greg on 28/11/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GeneralViewController.h"


@implementation GeneralViewController

- (NSString *)title
{
	return @"General";
}

- (NSString *)identifier
{
	return @"GeneralPane";
}

- (NSImage *)image
{
	return [NSImage imageNamed:@"NSPreferencesGeneral"];
}

@end
