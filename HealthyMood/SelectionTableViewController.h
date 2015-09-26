//
//  SelectionTableViewController.h
//  HealthyMood
//
//  Created by Nadine Khattak on 9/26/15.
//  Copyright © 2015 Ensach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectionTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UITableViewCell *entrySelCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *ViewDataSelCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *viewGraphSelCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *viewSettingsSelCell;

@end
