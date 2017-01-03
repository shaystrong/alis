//
//  TableViewController.h
//  ALIS
//
//  Created by Strong, Shadrian B. on 10/2/14.
//  Copyright (c) 2014 ALIS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArchiveTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic)            NSString *timeObs;
@property (strong, nonatomic)            NSString *timeRaw;

@end

