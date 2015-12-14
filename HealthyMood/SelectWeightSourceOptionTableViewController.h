//
//  SelectWeightSourceOptionTableViewController.h
//  HealthyMood
//
//  Created by Nadine Khattak on 12/12/15.
//  Copyright © 2015 Ensach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectWeightSourceOptionTableViewController : UITableViewController <UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableViewCell *chooseWeightSource;
@property (weak, nonatomic) IBOutlet UITableViewCell *viewWeightFirst;

-(IBAction)weightVCType:(id)sender;

@end
