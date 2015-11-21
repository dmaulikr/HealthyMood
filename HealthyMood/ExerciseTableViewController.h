//
//  ExerciseTableViewController.h
//  HealthyMood
//
//  Created by Nadine Khattak on 11/17/15.
//  Copyright © 2015 Ensach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExerciseTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITableViewCell *viewData;

@property (weak, nonatomic) IBOutlet UITableViewCell *viewGraph;

+ (ExerciseTableViewController *)sharedManager;

- (void)requestAuthorization;

- (void)readSteps;

@end
