//
//  WithingsWeightGraphViewController.h
//  HealthyMood
//
//  Created by Nadine Khattak on 11/12/15.
//  Copyright © 2015 Ensach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WithingsWeightGraphViewController : UIViewController {
    NSString *userId;
    NSString *date;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *withingsSegment;

-(IBAction)segmentedControlIndexChanged;
@property (weak, nonatomic) IBOutlet UISegmentedControl *timeFrameSegment;

//-(void)loadData;

@end
