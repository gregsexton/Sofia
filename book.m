//
// book.m
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

#import "book.h"

#import "Library.h"
#import "author.h"
#import "list.h"
#import "subject.h"

@implementation book 

@dynamic isbn13;
@dynamic dewey_normalised;
@dynamic title;
@dynamic language;
@dynamic summary;
@dynamic isbn10;
@dynamic authorText;
@dynamic lccNumber;
@dynamic awards;
@dynamic toc;
@dynamic edition;
@dynamic noOfCopies;
@dynamic read;
@dynamic subjectText;
@dynamic titleLong;
@dynamic coverImage;
@dynamic physicalDescription;
@dynamic publisherText;
@dynamic dewey;
@dynamic urls;
@dynamic notes;
@dynamic dateAdded;
@dynamic publisher;
@dynamic lists;
@dynamic subjects;
@dynamic authors;
@dynamic library;

- (NSImage*)coverImageImage{
    NSString* imgPath = [self coverImage];

    if(imgPath){
        NSImage* img = [[NSImage alloc] initWithContentsOfFile:imgPath];
        return [img autorelease];

    }else{
        return nil;
    }
}

- (void)setCoverImageImage:(NSImage*)image{
    NSString* imgPath = [self coverImage];
    if(imgPath){
        //delete old image
        NSFileManager* fileManager = [[NSFileManager alloc] init];
        NSError* error;
        [fileManager removeItemAtPath:imgPath error:&error];
        [fileManager release];
    }

    if(image){
        //generate unique path
        NSString* fileName = [NSString stringWithFormat:@"%@.tiff", [[NSProcessInfo processInfo] globallyUniqueString]];
        NSString* filePath = [[self applicationSupportFolder] stringByAppendingPathComponent:fileName];

        NSData* data = [image TIFFRepresentation];
        [data writeToFile:filePath atomically:NO];

        [self setCoverImage:filePath];
    }
}

- (NSString*)applicationSupportFolder{
    //Returns the support folder for the application
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Sofia"];
}

@end
