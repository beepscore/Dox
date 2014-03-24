//
//  BSTableViewController.h
//  Dox
//
//  Created by Steve Baker on 3/23/14.
//  Copyright (c) 2014 Beepscore LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSNote.h"
#import "BSViewController.h"

@interface BSTableViewController : UITableViewController

@property (strong) NSMutableArray *notes;
@property (strong) BSViewController *detailViewController;
@property (strong) NSMetadataQuery *query;

- (void)loadNotes;

@end
