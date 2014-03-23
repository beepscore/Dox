//
//  BSNote.m
//  Dox
//
//  Created by Steve Baker on 3/23/14.
//  Copyright (c) 2014 Beepscore LLC. All rights reserved.
//

#import "BSNote.h"

@implementation BSNote

// Called whenever the application reads data from the file system
- (BOOL)loadFromContents:(id)contents
                  ofType:(NSString *)typeName
                   error:(NSError **)outError
{

    if ([contents length] > 0) {
        self.noteContent = [[NSString alloc] initWithBytes:[contents bytes]
                                                    length:[contents length]
                                                  encoding:NSUTF8StringEncoding];
    } else {
        // When the note is first created, assign some default content
        self.noteContent = @"Empty"; 
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"noteModified"
                                                        object:self];
    
    return YES;    
}

// Called whenever the application (auto)saves the content of a note
- (id)contentsForType:(NSString *)typeName
                error:(NSError **)outError
{
    if ([self.noteContent length] == 0) {
        self.noteContent = @"Empty";
    }

    return [NSData dataWithBytes:[self.noteContent UTF8String]
                          length:[self.noteContent length]];
}

@end
