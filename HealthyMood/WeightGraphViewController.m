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
@property (nonatomic, readwrite, strong) NSDate *refDateMonth;
@property (nonatomic, readwrite, strong) NSDate *refDateYear;
@property (nonatomic, readwrite, strong) NSDate *refDateWeek;

@end

@implementation WeightGraphViewController
@synthesize segmentedControl;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    
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

    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    
    [dateComponents setDay: 1];

    NSDateComponents *dateComponentsYear = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    
    [dateComponentsYear setMonth: 1];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];

    NSDateComponents *dateComponentsWeek = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    NSInteger weekday = [dateComponentsWeek weekday];
    NSDate *lastSunday = [[NSDate date] dateByAddingTimeInterval:-3600*24*(weekday-1)];
    
    
    NSTimeInterval oneDay = 24 * 60 * 60;

    self.refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[NSDate date].timeIntervalSinceReferenceDate - (3 * 24 * 60 * 60) ];
    self.refDateMonth = [gregorian dateFromComponents:dateComponents];
    
    self.refDateYear = [gregorian dateFromComponents:dateComponentsYear];
    
    self.refDateWeek = lastSunday;
    
    self.graph = [[CPTXYGraph alloc] init];
    

    
    CPTColor *backgroundColor = [CPTColor colorWithComponentRed:255.0f/255.0f green:255.0f/255.0f blue:240.0f/255.0f alpha:1.0f];

    CPTColor *backgroundColorFrame = [CPTColor colorWithComponentRed:200.0f/255.0f green:255.0f/255.0f blue:240.0f/255.0f alpha:1.0f];

    
        self.graph.plotAreaFrame.cornerRadius = 6.0;
        self.graph.plotAreaFrame.shadowRadius = 6.0;
    
    //self.graph.fill = [CPTFill fillWithColor:backgroundColor];
    
    self.graph.plotAreaFrame.fill = [CPTFill fillWithColor:backgroundColorFrame];
    
    // setup a plot space for the plot to live in
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    // sets the range of x values
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0)
                                                    length:CPTDecimalFromFloat((oneDay * 6 + (oneDay/4)) * 1.02)];
    // sets the range of y values
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat([self getMinWeight] / 1.02f)
                                                    length:CPTDecimalFromFloat((([self getMaxWeight] *1.04)- [self getMinWeight]))];
    
    
    // plotting style is set to line plots
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor blueColor];
    lineStyle.lineWidth = 1.0f;
    lineStyle.lineCap   = kCGLineCapRound;
    
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    [textStyle setFontSize:6.0f];
    
    
    // X-axis parameters setting
    CPTXYAxisSet *axisSet = (id)self.graph.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    axisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay * 3);
    axisSet.xAxis.minorTicksPerInterval = 0;
    axisSet.xAxis.orthogonalCoordinateDecimal = CPTDecimalFromFloat([self getMinWeight] / 1.02); //added for date, adjust x line
    axisSet.xAxis.majorTickLineStyle = lineStyle;
    axisSet.xAxis.minorTickLineStyle = lineStyle;
    axisSet.xAxis.axisLineStyle = lineStyle;
    axisSet.xAxis.minorTickLength = 5.0f;
    axisSet.xAxis.majorTickLength = 2.0f;
    [x setLabelTextStyle:textStyle];
    x.labelRotation = M_PI/3;
    x.tickLabelDirection = CPTSignNegative;
    
    
    // added for date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd"];
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter] ;
    timeFormatter.referenceDate = self.refDateWeek;
    axisSet.xAxis.labelFormatter = timeFormatter;
    
    // Y-axis parameters setting
    CPTXYAxis *y = axisSet.yAxis;
    
    y.titleTextStyle = textStyle;
    
    
    y.title = [self titleForYAxis];
    y.titleOffset = 20.0;
    
    /*
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([[defaults objectForKey:@"unit"] isEqual:@"lb"]) {
        y.title = @"Weight (kg)";
    } else {
        y.title = @"Weight (lb)";
    }
     */
    


    axisSet.yAxis.majorIntervalLength = CPTDecimalFromFloat(5);
    axisSet.yAxis.minorTicksPerInterval = 0;
    axisSet.yAxis.orthogonalCoordinateDecimal = CPTDecimalFromFloat([self getMinWeight] * 1.02); // added for date, adjusts y line
    axisSet.yAxis.majorTickLineStyle = lineStyle;
    axisSet.yAxis.axisLineStyle = lineStyle;
    axisSet.yAxis.majorTickLength = 2.0f;
    [y setLabelTextStyle:textStyle];

    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:0];
    
    y.labelFormatter = formatter;
    
    // This actually performs the plotting
    CPTScatterPlot *xSquaredPlot = [[CPTScatterPlot alloc] init] ;
    
    CPTMutableLineStyle *dataLineStyle = [CPTMutableLineStyle lineStyle];
    //xSquaredPlot.identifier = @"X Squared Plot";
    
    dataLineStyle.lineWidth = 1.0f;
    dataLineStyle.lineColor = [CPTColor greenColor];
    xSquaredPlot.dataLineStyle = dataLineStyle;
    xSquaredPlot.dataSource = self;
    
    CPTColor *areaColor = [CPTColor blueColor];
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
    [areaGradient setAngle:-90.0f];
    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
    [xSquaredPlot setAreaFill:areaGradientFill];
    [xSquaredPlot setAreaBaseValue:CPTDecimalFromInt(0)];
    
    areaColor = [CPTColor colorWithComponentRed:255.0f/255.0f green:228.0f/255.0f blue:225.0f/255.0f alpha:1.0f];
    areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
    [areaGradient setAngle:-90.0f];
    areaGradientFill = [CPTFill fillWithGradient:areaGradient];
    [xSquaredPlot setAreaFill:areaGradientFill];
    [xSquaredPlot setAreaBaseValue:CPTDecimalFromInt(0)];
  
    // add plot to graph
     [self.graph addPlot:xSquaredPlot];
}


- (NSString *)titleForYAxis {
    
    NSString *yAxisTitle;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([[defaults objectForKey:@"unit"] isEqual:@"lb"]) {
       yAxisTitle = @"Weight (lb)";
    } else {
        yAxisTitle = @"Weight (kg)";
    }
    
    return yAxisTitle;
}

-(IBAction) segmentedControlIndexChanged {

    NSTimeInterval oneDay = 24 * 60 * 60;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    NSTimeInterval xLow = 0.0f;
    
    CPTXYAxisSet *axisSet = (id)self.graph.axisSet;

    

    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd"];
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[NSDate date]];
    NSUInteger numberOfDaysInMonth = range.length;
    

    
    
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xLow)
                                                            length:CPTDecimalFromFloat(oneDay * 6)];
            [dateFormatter setDateFormat:@"MM/dd"];
            
            axisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay * 3 );
            timeFormatter.referenceDate = self.refDateWeek;
            axisSet.xAxis.labelFormatter = timeFormatter;
            
           
         //   x.title = @"Week";

            
            [self.graph reloadData];
            
            break;
        case 1:
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xLow)
                                                            length:CPTDecimalFromFloat(oneDay * numberOfDaysInMonth)];
            [dateFormatter setDateFormat:@"MM/dd"];

            axisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay * 7);
            timeFormatter.referenceDate = self.refDateMonth;
            axisSet.xAxis.labelFormatter = timeFormatter;
           // x.title = @"Day of Month";
            
            [self.graph reloadData];
            
            break;
        case 2:
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xLow)
                                                            length:CPTDecimalFromFloat(oneDay * 335.5)];
            [dateFormatter setDateFormat:@"MMM"];
            axisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay * 30);
            
            timeFormatter.referenceDate = self.refDateYear;
            axisSet.xAxis.labelFormatter = timeFormatter;
            
            //x.title = @"Year";

            [self.graph reloadData];
            
            break;
            
        default:
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0)
                                                            length:CPTDecimalFromFloat(oneDay)];
            [dateFormatter setDateFormat:@"MM/dd"];
            axisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay * 2);
    }
    
}

- (CPTPlotSymbol *)symbolForScatterPlot:(CPTScatterPlot *)aPlot recordIndex:(NSUInteger)index
{
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    [plotSymbol setSize:CGSizeMake(4, 4)];
    [plotSymbol setFill:[CPTFill fillWithColor:[CPTColor yellowColor]]];
    [plotSymbol setLineStyle:nil];
    [aPlot setPlotSymbol:plotSymbol];
    
    return plotSymbol;
}

-(void)viewDidLayoutSubviews {

    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, self.segmentedControl.frame.size.height + self.segmentedControl.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height-85 )];
    
    [self.view addSubview:hostingView];
    
    hostingView.hostedGraph = self.graph;
    
    self.graph.paddingLeft = 25.0;
    self.graph.paddingTop = 10.0;
    self.graph.paddingRight = 15.0;
    self.graph.paddingBottom = 35.0;
    
    self.graph.plotAreaFrame.paddingBottom = 50.0;
    self.graph.plotAreaFrame.paddingLeft = 30.0;
    self.graph.plotAreaFrame.paddingTop = 10.0;
        self.graph.plotAreaFrame.paddingRight = 0.0;
    

}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, self.segmentedControl.frame.size.height + self.segmentedControl.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height-85 )];
    
    [self.view addSubview:hostingView];
    
    hostingView.hostedGraph = self.graph;
    
    self.graph.paddingLeft = 25.0;
    self.graph.paddingTop = 10.0;
    self.graph.paddingRight = 15.0;
    self.graph.paddingBottom = 35.0;
    
    self.graph.plotAreaFrame.paddingBottom = 50.0;
    self.graph.plotAreaFrame.paddingLeft = 30.0;
    self.graph.plotAreaFrame.paddingTop = 10.0;
    self.graph.plotAreaFrame.paddingRight = 0.0;

    
    for (CPTPlot *p in self.graph.allPlots)
    {
        [p reloadData];
    }
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
            maxWeight = 50.0;

        }
        
        else if (maxWeight == 0) {
            maxWeight = 50.0;
            
        }
        
        
        else if (objects > 0)
        {
            return maxWeight;
        }
      
        [self.graph reloadData];
        
        return maxWeight;
        
        
        
    }

- (float)getMinWeight
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Weight" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    // Specify that the request should return dictionaries.
    [request setResultType:NSDictionaryResultType];
    
    // Create an expression for the key path.
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"weight"];
    
    // Create an expression to represent the maximum value at the key path 'creationDate'
    NSExpression *maxExpression = [NSExpression expressionForFunction:@"min:" arguments:[NSArray arrayWithObject:keyPathExpression]];
    
    // Create an expression description using the maxExpression and returning a date.
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    
    // The name is the key that will be used in the dictionary for the return value.
    [expressionDescription setName:@"minWeight"];
    [expressionDescription setExpression:maxExpression];
    [expressionDescription setExpressionResultType:NSFloatAttributeType];
    
    // Set the request's properties to fetch just the property represented by the expressions.
    [request setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    
    // Execute the fetch.
    NSError *error = nil;
    NSArray *objects = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    NSString *theObject = [[objects objectAtIndex:0] valueForKey:@"minWeight"];
    
    float minWeight = [theObject floatValue];
    
    NSLog(@"Maximum date: %@", theObject);
    NSLog(@"Maximum date float: %f", minWeight);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([[defaults objectForKey:@"unit"] isEqual:@"kg"]) {
        
        minWeight = ([theObject floatValue] * 0.453592);
    } else {
        minWeight = [theObject floatValue];
    }
    
    if (objects == nil) {
            return 50.0;
    }
    
    else if (objects == 0)
    {
        NSLog (@"no values");
        minWeight = 50.0;

    }
    
    [self.graph reloadData];
    
    NSLog(@"minWeight %f", minWeight);
    return minWeight;
    
    
    
}

- (float)getAverageWeight
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Weight" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    // Specify that the request should return dictionaries.
    [request setResultType:NSDictionaryResultType];
    
    // Create an expression for the key path.
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"weight"];
    
    // Create an expression to represent the maximum value at the key path 'creationDate'
    NSExpression *avgExpression = [NSExpression expressionForFunction:@"average:" arguments:[NSArray arrayWithObject:keyPathExpression]];
    
    // Create an expression description using the maxExpression and returning a date.
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    
    // The name is the key that will be used in the dictionary for the return value.
    [expressionDescription setName:@"averageWeight"];
    [expressionDescription setExpression:avgExpression];
    [expressionDescription setExpressionResultType:NSFloatAttributeType];
    
    // Set the request's properties to fetch just the property represented by the expressions.
    [request setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    
    // Execute the fetch.
    NSError *error = nil;
    NSArray *objects = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    NSString *theObject = [[objects objectAtIndex:0] valueForKey:@"averageWeight"];
    
    float avgWeight = [theObject floatValue];
    
    NSLog(@"Maximum weight: %@", theObject);
    NSLog(@"Maximum date float: %f", avgWeight);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([[defaults objectForKey:@"unit"] isEqual:@"kg"]) {
        
        avgWeight = ([theObject floatValue] * 0.453592);
    } else {
        avgWeight = [theObject floatValue];
    }
    
    if (objects == nil) {
        NSLog (@"no info");
        
    }
    
    [self.graph reloadData];
    
    NSLog(@"avg weight, %f", avgWeight);
    
    return avgWeight;
    
    
    
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
        
        if (self.segmentedControl.selectedSegmentIndex == 0)
        {
            double intervalInSeconds = [date timeIntervalSinceDate:self.refDate]; // get difference
            return [NSNumber numberWithDouble:intervalInSeconds]; // return difference
            
        }
        else if (self.segmentedControl.selectedSegmentIndex ==1)
        {
            double intervalInSeconds = [date timeIntervalSinceDate:self.refDateMonth]; // get difference
            return [NSNumber numberWithDouble:intervalInSeconds]; // return difference
            
        }
        else {
            double intervalInSeconds = [date timeIntervalSinceDate:self.refDate]; // get difference
            return [NSNumber numberWithDouble:intervalInSeconds]; // return difference

        }
        
        

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

}




@end
