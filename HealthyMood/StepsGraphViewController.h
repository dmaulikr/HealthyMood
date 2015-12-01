//
//  StepsGraphViewController.h
//  HealthyMood
//
//  Created by Nadine Khattak on 11/20/15.
//  Copyright © 2015 Ensach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HealthKit/HealthKit.h>

@interface StepsGraphViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *timeFrameSegment;
-(IBAction)segmentChange;
@end
