//
//  BSViewController.h
//  Dox
//
//  Created by Steve Baker on 3/22/14.
//  Copyright (c) 2014 Beepscore LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSNote.h"

@interface BSViewController : UIViewController <UITextViewDelegate>

@property (strong) BSNote *doc;
@property (weak) IBOutlet UITextView *noteView;

@end
