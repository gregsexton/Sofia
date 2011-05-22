//
//  Version2To4EntityMigrationPolicy.m
//  books
//
//  Created by Greg on 19/05/2011.
//  Copyright 2011 Greg Sexton Software. All rights reserved.
//

#import "Version2To4EntityMigrationPolicy.h"


@implementation Version2To4EntityMigrationPolicy

- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject*)sInstance
                                      entityMapping:(NSEntityMapping*)mapping
                                            manager:(NSMigrationManager*)manager
                                              error:(NSError **)error{

    NSLog(@"here.");
    NSManagedObject *newObject;
    NSEntityDescription *sourceInstanceEntity = [sInstance entity];

    if([[sourceInstanceEntity name] isEqualToString:@"book"]){

        newObject = [NSEntityDescription insertNewObjectForEntityForName:@"book"
                                                  inManagedObjectContext:[manager destinationContext]];

        //NSDictionary* keyValDict = [sInstance committedValuesForKeys:nil];
        NSArray* allKeys = [[[sInstance entity] attributesByName] allKeys];

        NSString* applicationSupportFolder = [self applicationSupportFolder];

        NSInteger max = [allKeys count];

        for(NSInteger i=0; i< max; i++){
            // Get key and value
            NSString *key = [allKeys objectAtIndex:i];
            id value = [sInstance valueForKey:key];

            if([key isEqualToString:@"coverImage"]){

                NSString* fileName = [NSString stringWithFormat:@"%@.tiff", [[NSProcessInfo processInfo] globallyUniqueString]];
                NSString* filePath = [applicationSupportFolder stringByAppendingPathComponent:fileName];

                NSImage* img = (NSImage*)value;
                NSData* data = [img TIFFRepresentation];
                [data writeToFile:filePath atomically:NO];

                [newObject setValue:filePath forKey:key];

            }else if([key isEqualToString:@"noOfCopies"]){
                [newObject setValue:[NSDecimalNumber numberWithInteger:[(NSString*)value integerValue]]
                             forKey:key];
            }else{
                if(value != nil){
                    [newObject setValue:value forKey:key];
                }
            }
        }
    }

    [manager associateSourceInstance:sInstance
             withDestinationInstance:newObject
                    forEntityMapping:mapping];

    return YES;
}

- (NSString*)applicationSupportFolder{
    //Returns the support folder for the application

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Sofia"];
}

@end
