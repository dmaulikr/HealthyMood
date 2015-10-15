//
//  WeightGraphViewController.h
//  HealthyMood
//
//  Created by Nadine Khattak on 9/26/15.
//  Copyright © 2015 Ensach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"

@interface WeightGraphViewController : UIViewController <CPTPlotDataSource> {
    UISegmentedControl *segmentControl;
}


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) float stringObject;

@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;





-(IBAction)segmentedControlIndexChanged;

@end
