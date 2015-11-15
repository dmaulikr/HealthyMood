//
//  WithingsSelectionTableViewController.h
//  HealthyMood
//
//  Created by Nadine Khattak on 11/12/15.
//  Copyright © 2015 Ensach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WithingsWeightTableViewController.h"

@interface WithingsSelectionTableViewController : UITableViewController



@property (weak, nonatomic) IBOutlet UITableViewCell *withingsViewDataSelCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *withingsViewGraphSelCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *withingsViewSettingsSelCell;

@end
