//
//  AccessKeyViewController.m
//  books
//
//  Created by Greg on 28/11/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AccessKeyViewController.h"


@implementation AccessKeyViewController

- (NSString *)title
{
	return @"Access Keys";
}

- (NSString *)identifier
{
	return @"AccessKeysPane";
}

- (NSImage *)image
{
	return [NSImage imageNamed:@"NSPreferencesGeneral"];
}

@end
