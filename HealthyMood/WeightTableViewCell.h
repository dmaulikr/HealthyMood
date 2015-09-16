//
//  WeightTableViewCell.h
//  HealthyMood
//
//  Created by Nadine Khattak on 9/6/15.
//  Copyright (c) 2015 Ensach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Weight.h"

@interface WeightTableViewCell : UITableViewCell

@property (nonatomic, strong) Weight *weight;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
