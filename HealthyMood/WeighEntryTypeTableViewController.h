//
//  WeighEntryTypeTableViewController.h
//  HealthyMood
//
//  Created by Nadine Khattak on 11/9/15.
//  Copyright © 2015 Ensach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuth1Controller.h"


@interface WeighEntryTypeTableViewController : UITableViewController
{
    NSString *userId;
    NSString *date;

}
@property (weak, nonatomic) IBOutlet UITableViewCell *autoWeightEntrySelection;
@property (weak, nonatomic) IBOutlet UITableViewCell *manualWeightEntrySelection;

@property (weak, nonatomic) IBOutlet UILabel *accessTokenLabel;
@property (weak, nonatomic) IBOutlet UILabel *accessTokenSecretLabel;
@property (weak, nonatomic) IBOutlet UITextView *responseTextView;

@end
