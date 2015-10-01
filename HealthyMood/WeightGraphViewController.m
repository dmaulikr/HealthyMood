//
//  WeightGraphViewController.m
//  HealthyMood
//
//  Created by Nadine Khattak on 9/26/15.
//  Copyright © 2015 Ensach. All rights reserved.
//

#import "WeightGraphViewController.h"
#import "AppDelegate.h"
#import "CorePlot-CocoaTouch.h"
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>




@interface WeightGraphViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, readwrite, strong) CPTGraph *aGraph;

@end

@implementation WeightGraphViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = delegate.managedObjectContext;

    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Weight" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    
    
    // We need a hostview, you can create one in IB (and create an outlet) or just do this:
    CPTGraphHostingView* hostView = [[CPTGraphHostingView alloc] initWithFrame:self.view.frame];
    [self.view addSubview: hostView];
    
    // Create a CPTGraph object and add to hostView
    CPTGraph* graph = [[CPTXYGraph alloc] initWithFrame:hostView.bounds];
    hostView.hostedGraph = graph;
    
    // Get the (default) plotspace from the graph so we can set its x/y ranges
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    // Note that these CPTPlotRange are defined by START and LENGTH (not START and END) !!
    [plotSpace setYRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( 0 ) length:CPTDecimalFromFloat( [self getMaxWeight] )]];
    [plotSpace setXRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( -4 ) length:CPTDecimalFromFloat( 8 )]];
    
    // Create the plot (we do not define actual x/y values yet, these will be supplied by the datasource...)
    CPTScatterPlot* plot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    
    // Let's keep it simple and let this class act as datasource (therefore we implemtn <CPTPlotDataSource>)
    plot.dataSource = self;
    
    // Finally, add the created plot to the default plot space of the CPTGraph object we created before
    [graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];
    
    
    
}




- (float)getTotalWeightEntries
{

    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Weight" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    return [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
}

- (float)getMaxWeight
    {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Weight" inManagedObjectContext:self.managedObjectContext];
        [request setEntity:entity];
        
        // Specify that the request should return dictionaries.
        [request setResultType:NSDictionaryResultType];
        
        // Create an expression for the key path.
        NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"weight"];
        
        // Create an expression to represent the maximum value at the key path 'creationDate'
        NSExpression *maxExpression = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:keyPathExpression]];
        
        // Create an expression description using the maxExpression and returning a date.
        NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
        
        // The name is the key that will be used in the dictionary for the return value.
        [expressionDescription setName:@"maxDate"];
        [expressionDescription setExpression:maxExpression];
        [expressionDescription setExpressionResultType:NSFloatAttributeType];
        
        // Set the request's properties to fetch just the property represented by the expressions.
        [request setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
        
        // Execute the fetch.
        NSError *error = nil;
        NSArray *objects = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        NSString *theObject = [[objects objectAtIndex:0] valueForKey:@"maxDate"];
        
        float maxWeight = [theObject floatValue];
        
        NSLog(@"Maximum date: %@", theObject);
        NSLog(@"Maximum date float: %f", maxWeight);
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if([[defaults objectForKey:@"unit"] isEqual:@"kg"]) {
            
            maxWeight = ([theObject floatValue] * 0.453592);
        } else {
            maxWeight = [theObject floatValue];
        }
        

        if (objects == nil) {
            NSLog (@"no info");

        }
        
        else if (objects > 0)
        {
            return maxWeight;
        }

        
        
        return maxWeight;
        


        
        
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// This method is here because this class also functions as datasource for our graph
// Therefore this class implements the CPTPlotDataSource protocol
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plotnumberOfRecords {
    return 9; // Our sample graph contains 9 'points'
}

// This method is here because this class also functions as datasource for our graph
// Therefore this class implements the CPTPlotDataSource protocol
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    // We need to provide an X or Y (this method will be called for each) value for every index
    int x = index - 4;
    
    // This method is actually called twice per point in the plot, one for the X and one for the Y value
    if(fieldEnum == CPTScatterPlotFieldX)
    {
        // Return x value, which will, depending on index, be between -4 to 4
        return [NSNumber numberWithInt: x];
    } else {
        // Return y value, for this example we'll be plotting y = x * x
        return [NSNumber numberWithInt: x * x];
    }
}
@end
