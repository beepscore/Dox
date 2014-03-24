//
//  BSTableViewController.m
//  Dox
//
//  Created by Steve Baker on 3/23/14.
//  Copyright (c) 2014 Beepscore LLC. All rights reserved.
//

#import "BSTableViewController.h"

@interface BSTableViewController ()

@end

@implementation BSTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.notes = [[NSMutableArray alloc] init];
    self.title = @"Notes";
    UIBarButtonItem *addNoteItem = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Add"
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(addNote:)];
    self.navigationItem.rightBarButtonItem = addNoteItem;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadNotes)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.notes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
        cell.accessoryType =
        UITableViewCellAccessoryDisclosureIndicator;
    }
    
    BSNote *note = [self.notes objectAtIndex:indexPath.row];
    cell.textLabel.text = note.fileURL.lastPathComponent;
    
    return cell;
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowNote"])
    {
        BSViewController *destinationViewController = [segue destinationViewController];
        
        NSIndexPath *myIndexPath = [self.tableView
                                    indexPathForSelectedRow];
        
        BSNote *note = [self.notes objectAtIndex:myIndexPath.row];
        destinationViewController.doc = note;
    }
}

#pragma mark - notes

- (void)addNote:(id)sender
{
    NSURL *ubiq = [[NSFileManager defaultManager]
                   URLForUbiquityContainerIdentifier:nil];

    NSURL *ubiquitousPackage = [[ubiq URLByAppendingPathComponent:@"Documents"]
                                URLByAppendingPathComponent:[self filename]];
    
    BSNote *doc = [[BSNote alloc] initWithFileURL:ubiquitousPackage];
    
    [doc saveToURL:[doc fileURL]
  forSaveOperation:UIDocumentSaveForCreating
 completionHandler:^(BOOL success) {
     if (success) {
         [self.notes addObject:doc];
         [self.tableView reloadData];
     }
 }];
}

- (NSString *)filename
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd_hhmmss"];
    
    NSString *fileName = [NSString stringWithFormat:@"Note_%@",
                          [formatter stringFromDate:[NSDate date]]];
    return fileName;
}

- (void)loadNotes
{
    NSURL *ubiq = [[NSFileManager defaultManager]
                   URLForUbiquityContainerIdentifier:nil];

    if (ubiq) {

        self.query = [[NSMetadataQuery alloc] init];
        [self.query setSearchScopes:
         [NSArray arrayWithObject:
          NSMetadataQueryUbiquitousDocumentsScope]];
        NSPredicate *pred = [NSPredicate predicateWithFormat:
                             @"%K like 'Note_*'", NSMetadataItemFSNameKey];
        [self.query setPredicate:pred];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(queryDidFinishGathering:)
                                                     name:NSMetadataQueryDidFinishGatheringNotification
                                                   object:self.query];
        [self.query startQuery];

    } else {
        NSLog(@"No iCloud access");
    }
}

- (void)queryDidFinishGathering:(NSNotification *)notification {

    NSMetadataQuery *query = [notification object];
    [query disableUpdates];
    [query stopQuery];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSMetadataQueryDidFinishGatheringNotification
                                                  object:query];
    [self loadData:query];
    self.query = nil;
}

- (void)loadData:(NSMetadataQuery *)query
{
    [self.notes removeAllObjects];
    
    for (NSMetadataItem *item in [query results]) {
        
        NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
        BSNote *doc = [[BSNote alloc] initWithFileURL:url];
        
        [doc openWithCompletionHandler:^(BOOL success) {
            if (success) {
                
                [self.notes addObject:doc];
                [self.tableView reloadData];
                
            } else {
                NSLog(@"failed to open from iCloud");
            }
        }];
    }    
}

@end
