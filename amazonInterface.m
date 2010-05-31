//
//  amazonInterface.m
//  books
//
//  Created by Greg on 26/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "amazonInterface.h"
#import "SignedAwsSearchRequest.h"


@implementation amazonInterface

- (void) testUrlGeneration{

    NSString *accessKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"amazon_accessKey"];
    NSString *secretAccessKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"amazon_secretAccessKey"];

    //char* keyBytes = [secretAccessKey UTF8String];

    //NSString *secretKey = [SignedAwsSearchRequest decodeKey:keyBytes length:[secretAccessKey length]];
    SignedAwsSearchRequest *req = [[[SignedAwsSearchRequest alloc] initWithAccessKeyId:accessKey secretAccessKey:secretAccessKey] autorelease];

    //req.associateTag = @"wwwentropych-20";

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@"ItemSearch"           forKey:@"Operation"];
    [params setValue:@"Books"                forKey:@"SearchIndex"];
    [params setValue:@"Images"               forKey:@"ResponseGroup"];
    [params setValue:@"0201558025"		     forKey:@"Keywords"];
    
    NSString *urlString = [req searchUrlForParameterDictionary:params];
    NSLog(@"request URL: %@", urlString);

    NSError *error = nil;
    NSXMLDocument *doc = [[[NSXMLDocument alloc] initWithContentsOfURL:[NSURL URLWithString:urlString] options:0 error:&error] autorelease];
	
}   

@end
