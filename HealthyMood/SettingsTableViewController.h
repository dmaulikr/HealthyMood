//
//  SettingsTableViewController.h
//  HealthyMood
//
//  Created by Nadine Khattak on 9/10/15.
//  Copyright (c) 2015 Ensach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Weight.h"

@interface SettingsTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *kgCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *lbCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *stCell;

@property (nonatomic, retain) NSIndexPath *selectedIndexPath;


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
