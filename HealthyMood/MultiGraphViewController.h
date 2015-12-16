//
//  MultiGraphViewController.h
//  HealthyMood
//
//  Created by Nadine Khattak on 11/29/15.
//  Copyright © 2015 Ensach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HealthKit/HealthKit.h>

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"

@interface MultiGraphViewController : UIViewController <CPTPlotDataSource> 

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;



@property (weak, nonatomic) IBOutlet UISegmentedControl *timeFrameSegment;
-(IBAction)segmentChange;

@end
