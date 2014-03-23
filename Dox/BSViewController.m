//
//  BSViewController.m
//  Dox
//
//  Created by Steve Baker on 3/22/14.
//  Copyright (c) 2014 Beepscore LLC. All rights reserved.
//

#import "BSViewController.h"

@interface BSViewController ()

@end

@implementation BSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataReloaded:)
                                                 name:@"noteModified" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noteModified" object:nil];
}

- (void)dataReloaded:(NSNotification *)notification
{
    // Overwrite doc
    // In general substituting the old content with the new one is NOT a good practice.
    // When we receive a notification of change from iCloud we should have a conflict resolution policy
    // to enable the user to accept/refuse/merge the differences
    // between the local version and the iCloud one.
    self.doc = notification.object;

    self.noteView.text = self.doc.noteContent;
}

@end
