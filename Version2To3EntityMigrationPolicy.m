//
// Version2To3EntityMigrationPolicy.m
//
// Copyright 2011 Greg Sexton
//
// This file is part of Sofia.
// 
// Sofia is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// Sofia is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with Sofia.  If not, see <http://www.gnu.org/licenses/>.
//

#import "Version2To3EntityMigrationPolicy.h"


@implementation Version2To3EntityMigrationPolicy

- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject*)sInstance
                                      entityMapping:(NSEntityMapping*)mapping
                                            manager:(NSMigrationManager*)manager
                                              error:(NSError **)error{

    NSManagedObject *newObject;
    NSEntityDescription *sourceInstanceEntity = [sInstance entity];
    
    if([[sourceInstanceEntity name] isEqualToString:@"book"]){

        newObject = [NSEntityDescription insertNewObjectForEntityForName:@"book"
                                                  inManagedObjectContext:[manager destinationContext]];

        //NSDictionary* keyValDict = [sInstance committedValuesForKeys:nil];
        NSArray* allKeys = [[[sInstance entity] attributesByName] allKeys];

        NSInteger max = [allKeys count];

        for(NSInteger i=0; i< max; i++){
            // Get key and value
            NSString *key = [allKeys objectAtIndex:i];
            id value = [sInstance valueForKey:key];

            if([key isEqualToString:@"noOfCopies"]){

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

@end
