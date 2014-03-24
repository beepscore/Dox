//
//  BSAppDelegate.m
//  Dox
//
//  Created by Steve Baker on 3/22/14.
//  Copyright (c) 2014 Beepscore LLC. All rights reserved.
//

#import "BSAppDelegate.h"

#define kFILENAME @"mydocument.dox"

@implementation BSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    // Call URLForUbiquityContainerIdentifier: to give app permission to access the URL.
    // nil argument returns the first iCloud Container set up for the project.
    // iCloud does not work on simulator
    NSURL *ubiq = [[NSFileManager defaultManager]
                   URLForUbiquityContainerIdentifier:nil];

    if (ubiq) {
        NSLog(@"iCloud access at %@", ubiq);
        [self loadDocument];
    } else {
        NSLog(@"No iCloud access");
    }
    return YES;
}
							
- (void)loadDocument
{
    self.query = [[NSMetadataQuery alloc] init];

    // iCloud uses NSMetadataQueryUbiquitousDocumentsScope
    [self.query setSearchScopes:[NSArray arrayWithObject:
                                 NSMetadataQueryUbiquitousDocumentsScope]];

    // use %K to avoid adding " delimiters around keypath
    NSPredicate *pred = [NSPredicate predicateWithFormat:
                         @"%K == %@", NSMetadataItemFSNameKey, kFILENAME];
    [self.query setPredicate:pred];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queryDidFinishGathering:)
                                                 name:NSMetadataQueryDidFinishGatheringNotification
                                               object:self.query];

    // ask iCloud for current contents.
    [self.query startQuery];
}

- (void)queryDidFinishGathering:(NSNotification *)notification
{
    NSMetadataQuery *query = [notification object];

    // must explicitly stop query or else it will keep running for the life of the application
    [query disableUpdates];
    // stop query but don't delete its results
    [query stopQuery];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSMetadataQueryDidFinishGatheringNotification
                                                  object:query];
	[self loadData:query];
    self.query = nil;
}

- (void)loadData:(NSMetadataQuery *)query
{
    if ([query resultCount] == 1) {
        
        // NSMetadataItem has a set of keys that you can use to look up information about each file
        NSMetadataItem *item = [query resultAtIndex:0];
        NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
        
        self.doc = [[BSNote alloc] initWithFileURL:url];
        
        [self.doc openWithCompletionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"iCloud document opened");
            } else {
                NSLog(@"failed opening document from iCloud");
            }
        }];
        
	} else {

        NSURL *ubiq = [[NSFileManager defaultManager]
                       URLForUbiquityContainerIdentifier:nil];
        NSURL *ubiquitousPackage = [[ubiq URLByAppendingPathComponent:
                                     @"Documents"] URLByAppendingPathComponent:kFILENAME];
        
        self.doc = [[BSNote alloc] initWithFileURL:ubiquitousPackage];
        
        [self.doc saveToURL:[self.doc fileURL]
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success) {
                  [self.doc openWithCompletionHandler:^(BOOL success) {
                      NSLog(@"new document opened from iCloud");
                  }];                
              }
          }];
    }
}

@end
