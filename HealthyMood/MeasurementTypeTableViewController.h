//
//  MeasurementTypeTableViewController.h
//  HealthyMood
//
//  Created by Nadine Khattak on 11/17/15.
//  Copyright © 2015 Ensach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeasurementTypeTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITableViewCell *weight;
@property (weak, nonatomic) IBOutlet UITableViewCell *exercise;
@property (weak, nonatomic) IBOutlet UITableViewCell *mood;

@end
