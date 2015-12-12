//
//  MoodGraphViewController.h
//  HealthyMood
//
//  Created by Nadine Khattak on 12/6/15.
//  Copyright © 2015 Ensach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"


@interface MoodGraphViewController : UIViewController <CPTPlotDataSource> {
    UISegmentedControl *segmentControl;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;





-(IBAction)segmentedControlIndexChanged;


@end
