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
#import "Weight.h"



@interface WeightGraphViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, readwrite, strong) CPTGraph *aGraph;
@property (nonatomic, readwrite, strong) CPTXYGraph *graph;
@property (nonatomic, readwrite, strong) NSDate *refDate;

@end

@implementation WeightGraphViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = delegate.managedObjectContext;

    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Weight"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"weightDate" ascending:YES]]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"sectionIdentifier" cacheName:nil];
 
    NSLog(@"Before fetch fetchRequests %@", self.fetchedResultsController.fetchedObjects);
    // Perform Fetch
    [self.fetchedResultsController performFetch:&error];
    NSLog(@"After fetch fetchRequests %@", self.fetchedResultsController.fetchedObjects);

    
    NSTimeInterval oneDay = 24 * 60 * 60;
    int numDays = 3;
    self.refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[NSDate date].timeIntervalSinceReferenceDate - (3 * 24 * 60 * 60)];
    NSDateComponents *components = [[NSDateComponents alloc] init] ;

    self.graph = [[CPTXYGraph alloc] initWithFrame: self.view.bounds];
    
    // assign theme to graph
    //CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    //[self.graph applyTheme:theme];
    
    // Setting the graph as our hosting layer
    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:hostingView];
    
   
//    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostingView.bounds];
    
    hostingView.hostedGraph = self.graph;
    
    self.graph.paddingLeft = 25.0;
    self.graph.paddingTop = 40.0;
    self.graph.paddingRight = 25.0;
    self.graph.paddingBottom = 125.0;
    
    self.graph.plotAreaFrame.paddingBottom = 30.0;
    self.graph.plotAreaFrame.paddingLeft = 35.0;
    self.graph.plotAreaFrame.paddingTop = 60.0;
    

    
    // setup a plot space for the plot to live in
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    NSTimeInterval xLow = 0.0f;
    // sets the range of x values
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xLow)
                                                    length:CPTDecimalFromFloat(oneDay * 7)];
    // sets the range of y values
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0)
                                                    length:CPTDecimalFromFloat([self getMaxWeight])];
    
    // plotting style is set to line plots
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor blackColor];
    lineStyle.lineWidth = 2.0f;
    
    // X-axis parameters setting
    CPTXYAxisSet *axisSet = (id)self.graph.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    axisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay * 2);
    axisSet.xAxis.minorTicksPerInterval = 0;
    axisSet.xAxis.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0"); //added for date, adjust x line
    axisSet.xAxis.majorTickLineStyle = lineStyle;
    axisSet.xAxis.minorTickLineStyle = lineStyle;
    axisSet.xAxis.axisLineStyle = lineStyle;
    axisSet.xAxis.minorTickLength = 5.0f;
    axisSet.xAxis.majorTickLength = 9.0f;
   // axisSet.xAxis.labelOffset = 100.0f;





    
    // added for date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter] ;
    timeFormatter.referenceDate = self.refDate;
    axisSet.xAxis.labelFormatter = timeFormatter;
    
    // Y-axis parameters setting
    CPTXYAxis *y = axisSet.yAxis;
    axisSet.yAxis.majorIntervalLength = CPTDecimalFromFloat(2);
    axisSet.yAxis.minorTicksPerInterval = 2;
    axisSet.yAxis.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0"); // added for date, adjusts y line
    axisSet.yAxis.majorTickLineStyle = lineStyle;
    axisSet.yAxis.minorTickLineStyle = lineStyle;
    axisSet.yAxis.axisLineStyle = lineStyle;
    axisSet.yAxis.minorTickLength = 5.0f;
    axisSet.yAxis.majorTickLength = 7.0f;
   // y.tickDirection = CPTSignPositive;
    
    

    
    
    // This actually performs the plotting
    CPTScatterPlot *xSquaredPlot = [[CPTScatterPlot alloc] init] ;
    
    CPTMutableLineStyle *dataLineStyle = [CPTMutableLineStyle lineStyle];
    //xSquaredPlot.identifier = @"X Squared Plot";
    xSquaredPlot.identifier = @"Date Plot";
    
    dataLineStyle.lineWidth = 1.0f;
    dataLineStyle.lineColor = [CPTColor redColor];
    xSquaredPlot.dataLineStyle = dataLineStyle;
    xSquaredPlot.dataSource = self;
    
    CPTPlotSymbol *greenCirclePlotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    greenCirclePlotSymbol.fill = [CPTFill fillWithColor:[CPTColor greenColor]];
    greenCirclePlotSymbol.size = CGSizeMake(2.0, 2.0);
    xSquaredPlot.plotSymbol = greenCirclePlotSymbol;
    
    // add plot to graph
     [self.graph addPlot:xSquaredPlot];


    
/*
    NSDate *refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:31556926 * 10];
    NSTimeInterval oneDay = 24 * 60 * 60;

    //Create graph
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] init];
    
    // We need a hostview, you can create one in IB (and create an outlet) or just do this:
    CPTGraphHostingView* hostView = [[CPTGraphHostingView alloc] initWithFrame:self.view.frame];
    [self.view addSubview: hostView];
    
    // Create a CPTGraph object and add to hostView
    CPTGraph* graph = [[CPTXYGraph alloc] initWithFrame:hostView.bounds];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [graph applyTheme:theme];

    
    hostView.hostedGraph = graph;
    
    // Get the (default) plotspace from the graph so we can set its x/y ranges
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
     NSTimeInterval xLow = 0.0f;
    // Note that these CPTPlotRange are defined by START and LENGTH (not START and END) !!
    [plotSpace setYRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( 0 ) length:CPTDecimalFromFloat( [self getMaxWeight] )]];
    [plotSpace setXRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( 20 ) length:CPTDecimalFromFloat( 25 )]];
    
    
    //Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)newGraph.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    x.majorIntervalLength = CPTDecimalFromDouble(oneDay);
    NSLog(@"majorintervallength %d", x.majorIntervalLength);
    x.orthogonalCoordinateDecimal =    CPTDecimalFromDouble(2.0);

    x.minorTicksPerInterval = 0;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = refDate;
    x.labelFormatter = timeFormatter;

    
    // Create the plot (we do not define actual x/y values yet, these will be supplied by the datasource...)
    CPTScatterPlot* plot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    plot.identifier = @"Date Plot";
    
    CPTMutableLineStyle *lineStyle = [plot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 3.0;
    lineStyle.lineColor              = [CPTColor greenColor];
    plot.dataLineStyle = lineStyle;
    
    graph.plotAreaFrame.paddingBottom=40;

    // Let's keep it simple and let this class act as datasource (therefore we implemtn <CPTPlotDataSource>)
    plot.dataSource = self;
    
    // Finally, add the created plot to the default plot space of the CPTGraph object we created before
    [graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];

    
    // Initialize Fetch Request
    
    
    // Initialize Fetched Results Controller
 

    
    NSDate *refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[NSDate date].timeIntervalSinceReferenceDate - (3 * 24 * 60 * 60)];
    NSTimeInterval oneDay = 24 * 60 * 60;
    
    // Invert graph view to compensate for iOS coordinates
  
    
    // allocate the graph within the current view bounds
    self.graph = [[CPTXYGraph alloc] initWithFrame: self.view.bounds];
    
    // assign theme to graph
    CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [self.graph applyTheme:theme];
    
    // Setting the graph as our hosting layer
    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:hostingView];
    
    hostingView.hostedGraph = self.graph;
    
    self.graph.paddingLeft = 20.0;
    self.graph.paddingTop = 20.0;
    self.graph.paddingRight = 20.0;
    self.graph.paddingBottom = 150.0;
    
    // setup a plot space for the plot to live in
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    NSTimeInterval xLow = 0.0f;
    // sets the range of x values
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xLow)
                                                    length:CPTDecimalFromFloat(oneDay * 5)];
    // sets the range of y values
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0)
                                                    length:CPTDecimalFromFloat([self getMaxWeight])];
    
    // plotting style is set to line plots
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor blackColor];
    lineStyle.lineWidth = 2.0f;
    
    // X-axis parameters setting
    CPTXYAxisSet *axisSet = (id)self.graph.axisSet;
    axisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay);
    axisSet.xAxis.minorTicksPerInterval = 0;
    axisSet.xAxis.orthogonalCoordinateDecimal = CPTDecimalFromString(@"1"); //added for date, adjust x line
    axisSet.xAxis.majorTickLineStyle = lineStyle;
    axisSet.xAxis.minorTickLineStyle = lineStyle;
    axisSet.xAxis.axisLineStyle = lineStyle;
    axisSet.xAxis.minorTickLength = 5.0f;
    axisSet.xAxis.majorTickLength = 9.0f;
    axisSet.xAxis.labelOffset = 3.0f;
    
    // added for date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter] ;
    timeFormatter.referenceDate = refDate;
    axisSet.xAxis.labelFormatter = timeFormatter;
    
    // Y-axis parameters setting
    axisSet.yAxis.majorIntervalLength = CPTDecimalFromString(@"1");
    axisSet.yAxis.minorTicksPerInterval = 2;
    axisSet.yAxis.orthogonalCoordinateDecimal = CPTDecimalFromFloat(oneDay); // added for date, adjusts y line
    axisSet.yAxis.majorTickLineStyle = lineStyle;
    axisSet.yAxis.minorTickLineStyle = lineStyle;
    axisSet.yAxis.axisLineStyle = lineStyle;
    axisSet.yAxis.minorTickLength = 5.0f;
    axisSet.yAxis.majorTickLength = 7.0f;
    axisSet.yAxis.labelOffset = 3.0f;
    
    
    // This actually performs the plotting
    CPTScatterPlot *xSquaredPlot = [[CPTScatterPlot alloc] init] ;
    
    CPTMutableLineStyle *dataLineStyle = [CPTMutableLineStyle lineStyle];
    //xSquaredPlot.identifier = @"X Squared Plot";
    xSquaredPlot.identifier = @"Date Plot";
    
    dataLineStyle.lineWidth = 1.0f;
    dataLineStyle.lineColor = [CPTColor redColor];
    xSquaredPlot.dataLineStyle = dataLineStyle;
    xSquaredPlot.dataSource = self;
    
    CPTPlotSymbol *greenCirclePlotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    greenCirclePlotSymbol.fill = [CPTFill fillWithColor:[CPTColor greenColor]];
    greenCirclePlotSymbol.size = CGSizeMake(2.0, 2.0);
    xSquaredPlot.plotSymbol = greenCirclePlotSymbol;
    
    // add plot to graph
   // [self.graph addPlot:xSquaredPlot];
 
 */
    
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
      
        [self.graph reloadData];
        
        return maxWeight;
        
        
        
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// This method is here because this class also functions as datasource for our graph
// Therefore this class implements the CPTPlotDataSource protocol
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plotnumberOfRecords {
    return [self.fetchedResultsController.fetchedObjects count]; // Our sample graph contains 9 'points'
}

// This method is here because this class also functions as datasource for our graph
// Therefore this class implements the CPTPlotDataSource protocol
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
 
    NSNumber * result = [[NSNumber alloc] init];
    // This method returns x and y values.  Check which is being requested here.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (fieldEnum == CPTScatterPlotFieldX)
    {
        
        NSDate * dateResult = ((Weight*)[self.fetchedResultsController.fetchedObjects objectAtIndex:index]).weightDate;
        
        NSTimeInterval interval = [dateResult timeIntervalSince1970];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval]; // convert to NSDate
        double intervalInSeconds = [date timeIntervalSinceDate:self.refDate]; // get difference
        return [NSNumber numberWithDouble:intervalInSeconds]; // return difference
    }

    else
    {
        // Return y value, for this example we'll be plotting y = x * x
        if ([self.fetchedResultsController.fetchedObjects count] > index) {
            if([[defaults objectForKey:@"unit"] isEqual:@"kg"]) {
                NSNumber *initResult = ((Weight*)[self.fetchedResultsController.fetchedObjects objectAtIndex:index]).weight;
                float floatResult = [initResult floatValue] * 0.453592;
                result = @(floatResult);
                NSLog(@"x %@", result);
                return result;
            }
            else {
                NSNumber *result = ((Weight*)[self.fetchedResultsController.fetchedObjects objectAtIndex:index]).weight;
                NSLog(@"y %@", result);
                return  result;
            }
            

        } else {
            return nil;
        }

    }
    return result;
    
    /*// We need to provide an X or Y (this method will be called for each) value for every index
    int x = index;
    
    NSLog (@"x %i", x);
   // [self.fetchedResultsController setDelegate:self];
    
    
    // This method is actually called twice per point in the plot, one for the X and one for the Y value
    if(fieldEnum == CPTScatterPlotFieldX)
    {
        // Return x value, which will, depending on index, be between -4 to 4
        
        

        return [NSNumber numberWithInt: x];
    } else {
        // Return y value, for this example we'll be plotting y = x * x
        if ([self.fetchedResultsController.fetchedObjects count] > x) {
            NSNumber *a = ((Weight*)[self.fetchedResultsController.fetchedObjects objectAtIndex:x]).weight;
            return  a;
        } else {
            return nil;
        }
    }
    
    return @(-1);
     
     */
}




@end
