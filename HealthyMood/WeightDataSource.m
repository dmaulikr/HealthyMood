//
//  WeightDataSource.m
//  HealthyMood
//
//  Created by Nadine Khattak on 9/28/15.
//  Copyright © 2015 Ensach. All rights reserved.
//

#import "WeightDataSource.h"
#import <CoreData/CoreData.h>
#import "Weight.h"



@implementation WeightDataSource

@synthesize  managedObjectContext;

#pragma mark - Public Methods
- (id)initWithManagedObjectcontext:(NSManagedObjectContext *)aManagedObjectContext{
    self = [super init];
    if (self) {
        [self setManagedObjectContext:aManagedObjectContext];
    }
    
    return self;
}

- (float)getTotalWeightEntries {
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
     NSEntityDescription *entity = [NSEntityDescription entityForName:@"Weight" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    return [managedObjectContext countForFetchRequest:fetchRequest error:&error];
}

- (float)getMaxWeight {
    float maxWeightInitial = 0;

    NSError *error = nil;
    
    for (int i = 0; i < [self getTotalWeightEntries]; i++)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Weight" inManagedObjectContext: managedObjectContext];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"weight == %f", i];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        
        float weightMax = [managedObjectContext countForFetchRequest:fetchRequest error:&error];
        if (weightMax > maxWeightInitial) {
            maxWeightInitial = weightMax;
        }
    }
    
    return maxWeightInitial;
}

#pragma mark - CPTScatterPlotDataSource Methods
- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [self getTotalWeightEntries];
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    
    NSUInteger x = index;
    NSUInteger y = 0;
    
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Weight" inManagedObjectContext:managedObjectContext];
    
    NSPredicate *predicate = nil;
    
    [fetchRequest setEntity: entity];
    [fetchRequest setPredicate:predicate];
    
    
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            NSLog(@"GraphName: %@: x value for %lu is %lu", [plot identifier], (unsigned long)index, (unsigned long)x);
            return [NSNumber numberWithFloat:x];
            break;
        case CPTScatterPlotFieldY:
           // NSLog(@"GraphName: %@: y value for %lu is %y", [plot identifier], (unsigned long)index, y);
            return [NSNumber numberWithFloat:y];
            break;
        default:
            break;
    }
    
    return nil;
}


@end
