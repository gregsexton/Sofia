//
//  SidebarOutlineView.m
//  books
//
//  Created by Greg on 30/11/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SidebarOutlineView.h"


@implementation SidebarOutlineView

- (void) awakeFromNib {
    [super awakeFromNib];
    [self setDelegate:self];
    [self setDataSource:self];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    NSLog(item);
    if(item == nil){
	return @"LIBRARY";
    }
    if([item isEqualToString:@"LIBRARY"]){
	switch(index){
	    case 0:
		return @"Books";
	    case 1:
		return @"Shopping List";
	    default:
		return @"Error!";
	}
    }
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item{
    NSLog(item);
    return item;
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item{
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item{
    if([item isEqualToString:@"LIBRARY"]){
	return true;
    }
    return false;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    if(item == nil){
	return 1;
    }
    if([item isEqualToString:@"LIBRARY"]){
	return 2;
    }
    return 0;
}

- (BOOL)outlineView:(NSOutlineView*)outlineView isGroupItem:(id)item {
    if([item isEqualToString:@"LIBRARY"]){
	return true;
    }
    return false;
}

@end
