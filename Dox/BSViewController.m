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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.noteView.text = self.doc.noteContent;
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

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    self.doc.noteContent = textView.text;

    // Notify iCloud about every change (i.e. each time a character is added or deleted).
    // For efficiency, it would be better to just tell iCloud every so often, or when the user has finished a batch of edits.
    [self.doc updateChangeCount:UIDocumentChangeDone];
}

@end
