//
//  WeightDataSource.h
//  HealthyMood
//
//  Created by Nadine Khattak on 9/28/15.
//  Copyright © 2015 Ensach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"

@interface WeightDataSource : NSObject <CPTPlotDataSource>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (id)initWithManagedObjectcontext:(NSManagedObjectContext *)aManagedObjectContext;

- (float)getTotalWeightEntries;
- (float)getMaxWeight;
//- (NSArray *)getTimeEnteredAsArray;

@end
