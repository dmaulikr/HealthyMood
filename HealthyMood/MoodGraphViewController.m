//
//  MoodGraphViewController.m
//  HealthyMood
//
//  Created by Nadine Khattak on 12/6/15.
//  Copyright © 2015 Ensach. All rights reserved.
//

#import "MoodGraphViewController.h"
#import "AppDelegate.h"
#import "CorePlot-CocoaTouch.h"
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "Mood.h"



@interface MoodGraphViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, readwrite, strong) CPTXYGraph *graph;
@property (nonatomic, readwrite, strong) NSDate *refDate;
@property (nonatomic, readwrite, strong) NSDate *refDateMonth;
@property (nonatomic, readwrite, strong) NSDate *refDateYear;
@property (nonatomic, readwrite, strong) NSDate *refDateWeek;

@property (nonatomic, readwrite, strong) IBOutlet CPTGraphHostingView *hostView;


@end

@implementation MoodGraphViewController

@synthesize segmentedControl;

@synthesize hostView;




- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = delegate.managedObjectContext;
    
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Mood"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"moodDate" ascending:YES]]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSLog(@"Before fetch fetchRequests %@", self.fetchedResultsController.fetchedObjects);
    // Perform Fetch
    [self.fetchedResultsController performFetch:&error];
    NSLog(@"After fetch fetchRequests %@", self.fetchedResultsController.fetchedObjects);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd"];
    

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDate *today = [calendar dateBySettingHour:10 minute:0 second:0 ofDate:[NSDate date] options:0];
    //   NSDate *refDate            = today;
    NSTimeInterval oneDay      = 24 * 60 * 60;
    
    self.refDate            =     [NSDate dateWithTimeIntervalSinceReferenceDate:today.timeIntervalSinceReferenceDate - (6 * 24 * 60 * 60) ];
    
    self.view.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:0.0/255.0 blue:87.0/255.0 alpha:1.0f];
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    
    [[UISegmentedControl appearance] setTintColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]];
    
    self.graph = newGraph;
    
    self.hostView.hostedGraph = newGraph;
    
    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    NSTimeInterval xLow       = 0.0;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xLow) length:CPTDecimalFromDouble(oneDay * 6.0 + (oneDay * 0.3))];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0)
                                                    length:CPTDecimalFromFloat(7.0)];
    
    
    
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    [textStyle setFontSize:8.0f];
    [textStyle setColor:[CPTColor colorWithComponentRed: 255.0f/255.0f green:250.0f/255.0f blue:250.0f/255.0f alpha:1.0f]];
    
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)newGraph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    
    x.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    x.majorIntervalLength         = CPTDecimalFromDouble(oneDay);
    
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
    x.minorTicksPerInterval       = 0;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"MM/dd"];
    
    
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = self.refDate;
    x.labelFormatter            = timeFormatter;
    
    
    [x setLabelTextStyle:textStyle];
    
    CPTXYAxis *y = axisSet.yAxis;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:0];
    
    
    y.labelFormatter = numberFormatter;
    
    y.majorIntervalLength         = CPTDecimalFromDouble(1);
    y.minorTicksPerInterval       = 0;
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
    y.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    
    [y setLabelTextStyle:textStyle];
    
    // Create a plot that uses the data source method
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = @"Date Plot";
    
    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 1.0;
    lineStyle.lineColor              = [CPTColor whiteColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 0.5;
    axisLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:0.5];
    
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineWidth = 0.2;
    tickLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:1.0];
    
    y.majorTickLineStyle = tickLineStyle;
    x.majorTickLineStyle = tickLineStyle;
    
    y.axisLineStyle = axisLineStyle;
    x.axisLineStyle = axisLineStyle;
    
    
    dataSourceLinePlot.dataSource = self;
    [newGraph addPlot:dataSourceLinePlot];
    
    NSInteger countRecords = [self.fetchedResultsController.fetchedObjects count]; // Our sample graph contains 9 'points'
    
    NSLog (@"countRecords %ld", (long)countRecords);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) segmentedControlIndexChanged {
    
    NSTimeInterval oneDay = 24 * 60 * 60;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    
    NSTimeInterval xLow = 0.0f;
    
    CPTXYAxisSet *axisSet = (id)self.graph.axisSet;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDate *today = [calendar dateBySettingHour:10 minute:0 second:0 ofDate:[NSDate date] options:0];
    
    self.refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:today.timeIntervalSinceReferenceDate - (3 * 24 * 60 * 60) ];
    
    NSRange rangeMonth = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[NSDate date]];
    NSUInteger numberOfDaysInMonth = rangeMonth.length;
    
    NSDate *beginningofYear;
    NSTimeInterval lengthofYear;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    
    //NSInteger dayOfWeek = [comps weekday];
    
    NSLog (@"comps weekday, %ld", (long)[comps weekday]);
    
    [gregorian rangeOfUnit:NSCalendarUnitYear
                 startDate:&beginningofYear
                  interval:&lengthofYear
                   forDate:[NSDate date]];
    
    NSDate *nextYear = [beginningofYear dateByAddingTimeInterval:lengthofYear];
    NSInteger startDay = [gregorian ordinalityOfUnit:NSCalendarUnitDay
                                              inUnit:NSCalendarUnitEra
                                             forDate:beginningofYear];
    NSInteger endDay = [gregorian ordinalityOfUnit:NSCalendarUnitDay
                                            inUnit:NSCalendarUnitEra
                                           forDate:nextYear];
    NSInteger daysInYear = endDay - startDay;
    
    //NSUInteger dayOfYear =
    [gregorian ordinalityOfUnit:NSCalendarUnitDay
                         inUnit:NSCalendarUnitYear forDate:[NSDate date]];
    NSLog(@"gregorian %@", gregorian);
    
    NSLog(@"days in month %lu", (unsigned long)numberOfDaysInMonth);
    NSLog(@"days in year %li", (long)daysInYear);
    
    
    NSLog(@"number of days in month %lu",(unsigned long)numberOfDaysInMonth);
    
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            self.refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:today.timeIntervalSinceReferenceDate - (6 * 24 * 60 * 60) ];
            
            
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xLow) length:CPTDecimalFromDouble(oneDay * 6.0 + (oneDay * 0.3))];
            //   plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble([self getMinWeight]) length:CPTDecimalFromDouble([self getMaxWeight] + 20.0)];
            [dateFormatter setDateFormat:@"MM/d"];
            
            axisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay );
            timeFormatter.referenceDate = self.refDate;
            axisSet.xAxis.labelFormatter = timeFormatter;
            
            //x.title = @"Week";
            
            
            [self.graph reloadData];
            
            break;
        case 1:
            self.refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:today.timeIntervalSinceReferenceDate - (oneDay * (numberOfDaysInMonth-1))];
            
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xLow)
                                                            length:CPTDecimalFromFloat(oneDay * (numberOfDaysInMonth - 1) + (oneDay * .99) )];
            
            [dateFormatter setDateFormat:@"MMM d"];
            axisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay * 7);
            timeFormatter.referenceDate = self.refDate;
            axisSet.xAxis.labelFormatter = timeFormatter;
            // x.title = @"Day of Month";
            
            [self.graph reloadData];
            
            break;
        case 2:
            
            self.refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:today.timeIntervalSinceReferenceDate - (((daysInYear - numberOfDaysInMonth)) * 24 * 60 * 60) ];
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xLow)
                                                            length:CPTDecimalFromFloat((oneDay * (daysInYear-30) + (oneDay * 12)) )];
            [dateFormatter setDateFormat:@"MMM"];
            axisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay * numberOfDaysInMonth);
            
            timeFormatter.referenceDate = self.refDate;
            axisSet.xAxis.labelFormatter = timeFormatter;
            
            //x.title = @"Year";
            
            [self.graph reloadData];
            
            break;
            
        default:
            self.refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:today.timeIntervalSinceReferenceDate - (3 * 24 * 60 * 60) ];
            
            
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xLow) length:CPTDecimalFromDouble(oneDay * 6.0)];
            plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromDouble(6.0)];
            
            
            axisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay * 3 );
            //timeFormatter.referenceDate = self.refDate;
            //axisSet.xAxis.labelFormatter = timeFormatter;
            //   x.title = @"Week";
            
            [self.graph reloadData];
            
            break;
    }
}

- (CPTPlotSymbol *)symbolForScatterPlot:(CPTScatterPlot *)aPlot recordIndex:(NSUInteger)index
{
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    [plotSymbol setSize:CGSizeMake(6, 6)];
    [plotSymbol setFill:[CPTFill fillWithColor:[CPTColor colorWithComponentRed: 255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.5f]]];
    [plotSymbol setLineStyle:nil];
    [aPlot setPlotSymbol:plotSymbol];
    
    return plotSymbol;
}

-(void)viewDidLayoutSubviews {
    
    //CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 95, self.view.frame.size.width, self.view.frame.size.height) ];
    
    float y = self.segmentedControl.frame.origin.y;
    
    NSLog (@"%f", y);
    
    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, self.segmentedControl.frame.size.height + 70, self.view.frame.size.width, self.view.frame.size.height - (self.segmentedControl.frame.size.height + 70) )];
    
    [self.view addSubview:hostingView];
    
    hostingView.hostedGraph = self.graph;
    
    if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) ||
        ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)) {
        self.graph.paddingLeft = 40.0;
        self.graph.paddingTop = 0.0;
        self.graph.paddingRight = 40.0;
        self.graph.paddingBottom = 25.0;
        
        self.graph.plotAreaFrame.paddingBottom = 50.0;
        self.graph.plotAreaFrame.paddingLeft = 30.0;
        self.graph.plotAreaFrame.paddingTop = 5.0;
        self.graph.plotAreaFrame.paddingRight = 5.0;
        
        
    }
    
    else {
        self.graph.paddingLeft = 35.0;
        self.graph.paddingTop = 35.0;
        self.graph.paddingRight = 35.0;
        self.graph.paddingBottom = 25.0;
        
        self.graph.plotAreaFrame.paddingBottom = 50.0;
        self.graph.plotAreaFrame.paddingLeft = 30.0;
        self.graph.plotAreaFrame.paddingTop = 5.0;
        self.graph.plotAreaFrame.paddingRight = 30.0;
        
    }
    
    
    for (CPTPlot *p in self.graph.allPlots)
    {
        [p reloadData];
    }
    
    [self.graph reloadData];
    
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if ( UIInterfaceOrientationIsPortrait(fromInterfaceOrientation) )
    {
        self.graph.paddingLeft = 40.0;
        self.graph.paddingTop = 0.0;
        self.graph.paddingRight = 40.0;
        self.graph.paddingBottom = 25.0;
        
        self.graph.plotAreaFrame.paddingBottom = 50.0;
        self.graph.plotAreaFrame.paddingLeft = 30.0;
        self.graph.plotAreaFrame.paddingTop = 5.0;
        self.graph.plotAreaFrame.paddingRight = 5.0;
    }
    
    for (CPTPlot *p in self.graph.allPlots)
    {
        [p reloadData];
    }
    
    [self.graph reloadData];
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plotnumberOfRecords {
    
    return [self.fetchedResultsController.fetchedObjects count]; // Our sample
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    // return self.plotData[index][@(fieldEnum)];
    
    NSNumber * result = [[NSNumber alloc] init];
    // This method returns x and y values.  Check which is being requested here.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (fieldEnum == CPTScatterPlotFieldX)
    {
        
        NSDate * dateResult = ((Mood*)[self.fetchedResultsController.fetchedObjects objectAtIndex:index]).moodDate;
        
        NSLog(@"dateResult, %@", dateResult);
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:dateResult];
        
        [components setHour: 10];
        
        NSDate *newDate = [[NSCalendar currentCalendar] dateFromComponents:components];
        
        double intervalInSecondsFirst  = ([newDate timeIntervalSinceDate:self.refDate]);
        result = [NSNumber numberWithDouble:intervalInSecondsFirst];
        
        if (self.segmentedControl.selectedSegmentIndex == 0)
        {
            double intervalInSecondsFirst = ([newDate timeIntervalSinceDate:self.refDate]); // get difference
            
            NSLog (@"intervalinsecondsfirst %f", intervalInSecondsFirst);
            
            
            return [NSNumber numberWithDouble:intervalInSecondsFirst]; // return difference
            
        }
        else if (self.segmentedControl.selectedSegmentIndex ==1)
        {
            double intervalInSecondsFirst = [dateResult timeIntervalSinceDate:self.refDate]; // get difference
            // get difference
            
            return [NSNumber numberWithDouble:intervalInSecondsFirst]; // return difference
            
        }
        else if (self.segmentedControl.selectedSegmentIndex ==2){
            double intervalInSeconds = [dateResult timeIntervalSinceDate:self.refDate]; // get difference
            return [NSNumber numberWithDouble:intervalInSeconds]; // return difference
            
        }
        
        
        
    }
    
    else
    {
        // Return y value, for this example we'll be plotting y = x * x
        if ([self.fetchedResultsController.fetchedObjects count] > index) {
                NSString *initResult = ((Mood*)[self.fetchedResultsController.fetchedObjects objectAtIndex:index]).mood;
                if ([initResult  isEqual: @"Very Happy"])
                {
                    result = @(5.0);
                }
                else if ([initResult  isEqual: @"Happy"])
                {
                    result = @(4.0);
                }
                else if ([initResult  isEqual: @"Okay"])
                {
                    result = @(3.0);
                }
                else if ([initResult  isEqual: @"Sad"])
                {
                    result = @(2.0);
                }
                else if ([initResult  isEqual: @"Very Sad"])
                {
                    result = @(1.0);
                }


                return result;
            }
        
            
         else {
            return nil;
        }
        
    }
    return result;
    
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
