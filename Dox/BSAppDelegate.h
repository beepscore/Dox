//
//  BSAppDelegate.h
//  Dox
//
//  Created by Steve Baker on 3/22/14.
//  Copyright (c) 2014 Beepscore LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSTableViewController.h"
#import "BSNote.h"
#import "BSViewController.h"

@interface BSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) BSViewController *viewController;
@property (strong) BSNote *doc;
@property (strong) NSMetadataQuery *query;

- (void)loadDocument;

@end
