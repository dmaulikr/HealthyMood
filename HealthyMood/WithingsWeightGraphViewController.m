//
//  WithingsWeightGraphViewController.m
//  HealthyMood
//
//  Created by Nadine Khattak on 11/12/15.
//  Copyright © 2015 Ensach. All rights reserved.
//

#import "WithingsWeightGraphViewController.h"
#import "OAuth1Controller.h"
#import "CorePlot-CocoaTouch.h"
#import <UIKit/UIKit.h>


@interface WithingsWeightGraphViewController ()

@property (nonatomic, strong) OAuth1Controller *oauth1Controller;
@property (nonatomic, strong) NSString *oauthToken;
@property (nonatomic, strong) NSString *oauthTokenSecret;
@property (nonatomic, strong) NSString *weightMeas;
@property (nonatomic, strong) NSDate *weightDate;
@property (nonatomic, strong) NSMutableArray *vals;
@property (nonatomic, strong) NSMutableArray *dateVals;


@property (nonatomic, readwrite, strong) CPTGraph *aGraph;
@property (nonatomic, readwrite, strong) CPTXYGraph *graph;
@property (nonatomic, readwrite, strong) NSDate *refDate;
@property (nonatomic, readwrite, strong) NSDate *refDateMonth;
@property (nonatomic, readwrite, strong) NSDate *refDateYear;
@property (nonatomic, readwrite, strong) NSDate *refDateWeek;

@property (nonatomic, readwrite, strong) IBOutlet CPTGraphHostingView *hostView;
@property (nonatomic, readwrite, strong) NSArray *plotData;



@end



@implementation WithingsWeightGraphViewController


@synthesize withingsSegment;
@synthesize hostView;
@synthesize plotData;

- (void)viewDidLoad {
    [super viewDidLoad];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([[defaults objectForKey:@"unit"] isEqual:@"lb"]) {
        self.title = @"Weight Graph (lb)";
    }
    else if ([[defaults objectForKey:@"unit"] isEqual:@"kg"]) {
        self.title = @"Weight Graph (kg)";
    }
    

    // Do any additional setup after loading the view.
    
    
 
    
    NSString *oauthToken = [ defaults objectForKey:@"oauthToken"];
    NSString *oauthTokenSecret = [ defaults objectForKey:@"oauthTokenSecret"];
    NSString *userid = [defaults objectForKey:@"userid"];
    
    NSLog(@"userid, %@", userid);
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSError *error;
    
    self.vals = [[NSMutableArray alloc] init];
    self.weightMeas = [[NSString alloc] init];
    
    self.dateVals = [[NSMutableArray alloc] init];
    self.weightDate   = [[NSDate alloc] init];
    
    [dict setObject:@"getmeas" forKey:@"action"];
    
    [dict setObject:@"1" forKey:@"category"];
    
    NSURLRequest *request =
    [OAuth1Controller preparedRequestForPath:@"measure"
                                  parameters:dict
                                  HTTPmethod:@"GET"
                                  oauthToken:oauthToken
                                 oauthSecret:oauthTokenSecret];
    
    
    
    NSLog(@"RRRRR %@",request.URL);
    
    NSURLResponse *response;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error ];
    
    
         if (data.length > 0 && error == nil)
         {
             NSDictionary *greeting = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:NULL];
             
             NSDictionary *body = greeting[@"body"];
             NSDictionary *measureGroups = body[@"measuregrps"];
             
             NSLog(@"greeting %@", greeting);
             NSLog(@"measuregroups %@", measureGroups);
             
             if (!measureGroups || measureGroups == NULL)
             {
                 NSError *error = [NSError errorWithDomain:@"com.nadine.healthymood"
                                                      code:-1
                                                  userInfo:@{NSLocalizedDescriptionKey:@"Unexpected response, no measurement groups"}];
                 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"No Measurement Groups" preferredStyle:UIAlertControllerStyleAlert];
                 
                 UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                 [alertController addAction:ok];
                 
                 [self presentViewController:alertController animated:YES completion:nil];
                 
             }
             
             
             else
             {
                 for (NSDictionary *wMeasures in measureGroups) {
                     
                     NSDictionary *measures = wMeasures[@"measures"];
                     NSLog(@"measures, %@", measures);
                     
                     for (NSDictionary *measureWeights in measures)
                     {
                         if ([measureWeights[@"type"] integerValue] == 1)
                         {
                             
                             NSNumber *measureDateNumber = wMeasures[@"date"];
                             
                             NSString *epochTime = [measureDateNumber stringValue];
                             
                             NSTimeInterval seconds = [epochTime doubleValue];
                             
                             NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
                             
                             NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                             [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                             
                             self.weightDate = epochNSDate;
                             
                             
                             
                             NSUInteger rawMeas = [measureWeights[@"value"] unsignedIntegerValue];
                             
                             short unit = [measureWeights[@"unit"] shortValue];
                             
                             NSDecimalNumber *measureNum = [NSDecimalNumber decimalNumberWithMantissa: rawMeas
                                                                                             exponent:unit
                                                                                           isNegative:NO];
                             
                             double measureNumDouble = [measureNum doubleValue];
                             
                             double measureNumPounds = measureNumDouble * 2.2046;
                             
                             NSNumber *measureNumPoundsNumber = [NSNumber numberWithDouble:measureNumPounds];
                             
                             self.weightMeas = [measureNumPoundsNumber stringValue];
                             
                             [self.vals addObject:self.weightMeas];
                             
                             [self.dateVals addObject:self.weightDate];
                             
                             // [self.weightMeas addObject:[measureWeights objectForKey:@"value"]];
                             NSLog(@"weight asdf, %@, %@", self.weightMeas, self.vals);
                             
                             NSLog(@"weight date, %@, %@", self.weightDate, self.dateVals);
                             
                         }
                         
                     }
                 }
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                 [self.graph reloadData];
                 
                 
             });
             
             
         }
         else {
             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No Weight History" message:@"Check your internet connection" preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
             [alertController addAction:ok];
             
             [self presentViewController:alertController animated:YES completion:nil];

         }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd"];
    
    
    
    // NSDate *today = [[NSDate alloc] initWithTimeIntervalSinceNow: 0];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDate *today = [calendar dateBySettingHour:10 minute:0 second:0 ofDate:[NSDate date] options:0];
    //   NSDate *refDate            = today;
    NSTimeInterval oneDay      = 24 * 60 * 60;
    
    self.refDate            =     [NSDate dateWithTimeIntervalSinceReferenceDate:today.timeIntervalSinceReferenceDate - (6 * 24 * 60 * 60) ];
    
    self.view.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:158.0/255.0 blue:255.0/255.0 alpha:1.0f];
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    
    [[UISegmentedControl appearance] setTintColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]];
    
    //CPTTheme *theme      = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    //[newGraph applyTheme:theme];
    self.graph = newGraph;
    
    self.hostView.hostedGraph = newGraph;
    
    
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    [textStyle setFontSize:8.0f];
    [textStyle setColor:[CPTColor colorWithComponentRed: 255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];
    
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)newGraph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 7.0f;

    x.titleTextStyle = titleStyle;
    x.title = @"Date";
    
    x.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    x.majorIntervalLength         = CPTDecimalFromDouble(oneDay);
    
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble([self getMinWeight] - 1);
    x.minorTicksPerInterval       = 0;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"MM/dd"];
    
    
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = self.refDate;
    x.labelFormatter            = timeFormatter;
    
    
    [x setLabelTextStyle:textStyle];
    
    CPTXYAxis *y = axisSet.yAxis;
    
    y.title = @"Weight";
    y.titleOffset = 30;
    y.titleTextStyle = titleStyle;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:0];
    
    
    y.labelFormatter = numberFormatter;
    
    y.majorIntervalLength         = CPTDecimalFromDouble(1);
    y.minorTicksPerInterval       = 0;
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble([self getMinWeight] - 1);
    y.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    
    [y setLabelTextStyle:textStyle];
    
    // Create a plot that uses the data source method
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = @"Date Plot";
    
    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 4.0;
    lineStyle.lineColor              = [[CPTColor whiteColor] colorWithAlphaComponent:1.0];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 5.0;
    axisLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:0.8];
    
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineWidth = 0.2;
    tickLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:1.0];
    
    y.majorTickLineStyle = tickLineStyle;
    x.majorTickLineStyle = tickLineStyle;
    
    y.axisLineStyle = axisLineStyle;
    x.axisLineStyle = axisLineStyle;
    
    
    dataSourceLinePlot.dataSource = self;
    [newGraph addPlot:dataSourceLinePlot];
    
    NSInteger countRecords = [self.vals count]; // Our sample graph contains 9 'points'
    
    NSLog (@"countRecords %ld", (long)countRecords);
    
    
    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    NSTimeInterval xLow       = 0.0;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xLow) length:CPTDecimalFromDouble(oneDay * 6.0 + (oneDay * 0.3))];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat([self getMinWeight] - 1)
                                                    length:CPTDecimalFromFloat(([self getMaxWeight]- [self getMinWeight]) + 2.0)];
    
    


    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
//    NSInteger dayOfWeek = [comps weekday];
    
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
    
   // NSUInteger dayOfYear =
    [gregorian ordinalityOfUnit:NSCalendarUnitDay
                         inUnit:NSCalendarUnitYear forDate:[NSDate date]];
    NSLog(@"gregorian %@", gregorian);
    
    NSLog(@"days in month %lu", (unsigned long)numberOfDaysInMonth);
    NSLog(@"days in year %li", (long)daysInYear);
    
    
    NSLog(@"number of days in month %lu",(unsigned long)numberOfDaysInMonth);
    
    switch (self.withingsSegment.selectedSegmentIndex) {
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
            plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble([self getMinWeight]) length:CPTDecimalFromDouble([self getMaxWeight] + 20.0)];
            
            
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
    [plotSymbol setFill:[CPTFill fillWithColor:[CPTColor colorWithComponentRed: 191.0f/255.0f green:255.0f/255.0f blue:126.0f/255.0f alpha:0.5f]]];
    [plotSymbol setLineStyle:nil];
    [aPlot setPlotSymbol:plotSymbol];
    
    return plotSymbol;
}

-(void)viewDidLayoutSubviews {
    
    if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) ||
        ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)) {
        
        CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.15, self.view.frame.size.height * .35, self.view.frame.size.width * 0.7, self.view.frame.size.height * 0.6 )];
        
        [self.view addSubview:hostingView];
        
        hostingView.hostedGraph = self.graph;

        
        self.graph.paddingLeft = 40.0;
        self.graph.paddingTop = 0.0;
        self.graph.paddingRight = 40.0;
        self.graph.paddingBottom = 25.0;
        
        self.graph.plotAreaFrame.paddingBottom = 50.0;
        self.graph.plotAreaFrame.paddingLeft = 50.0;
        self.graph.plotAreaFrame.paddingTop = 5.0;
        self.graph.plotAreaFrame.paddingRight = 5.0;
        
        
    }
    
    else {
        
        CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height * .25, self.view.frame.size.width, self.view.frame.size.height * 0.6 )];
        
        [self.view addSubview:hostingView];
        
        hostingView.hostedGraph = self.graph;


        
        self.graph.paddingLeft = 30.0;
        self.graph.paddingTop = 35.0;
        self.graph.paddingRight = 35.0;
        self.graph.paddingBottom = 25.0;
        
        self.graph.plotAreaFrame.paddingBottom = 50.0;
        self.graph.plotAreaFrame.paddingLeft = 50.0;
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
        CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.15, self.view.frame.size.height * .35, self.view.frame.size.width * 0.7, self.view.frame.size.height * 0.6 )];
        
        [self.view addSubview:hostingView];
        
        hostingView.hostedGraph = self.graph;
        
        
        self.graph.paddingLeft = 40.0;
        self.graph.paddingTop = 0.0;
        self.graph.paddingRight = 40.0;
        self.graph.paddingBottom = 25.0;
        
        self.graph.plotAreaFrame.paddingBottom = 50.0;
        self.graph.plotAreaFrame.paddingLeft = 50.0;
        self.graph.plotAreaFrame.paddingTop = 5.0;
        self.graph.plotAreaFrame.paddingRight = 5.0;
    }
    
    else if ( UIInterfaceOrientationIsLandscape(fromInterfaceOrientation) )
    {
        CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height * .25, self.view.frame.size.width, self.view.frame.size.height * 0.6 )];
        
        [self.view addSubview:hostingView];
        
        hostingView.hostedGraph = self.graph;
        
        
        
        self.graph.paddingLeft = 30.0;
        self.graph.paddingTop = 35.0;
        self.graph.paddingRight = 35.0;
        self.graph.paddingBottom = 25.0;
        
        self.graph.plotAreaFrame.paddingBottom = 50.0;
        self.graph.plotAreaFrame.paddingLeft = 50.0;
        self.graph.plotAreaFrame.paddingTop = 5.0;
        self.graph.plotAreaFrame.paddingRight = 30.0;

    }
    
    for (CPTPlot *p in self.graph.allPlots)
    {
        [p reloadData];
    }
    
    [self.graph reloadData];
}


- (float)getTotalWeightEntries
{
    
    NSError *error = nil;
    
    return [self.vals count];
}

- (float)getMaxWeight
{
    //NSLog(@"minWeightNumber", minWeightNumber);
    NSNumber *maxWeightNumber = [self.vals valueForKeyPath:@"@max.intValue"];
    NSLog(@"maxWeightNumber, %@", maxWeightNumber);
    
    float maxWeight = [maxWeightNumber doubleValue];
    
    
    
    //  double minWeight = [self.vals indexOfObject:min];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([[defaults objectForKey:@"unit"] isEqual:@"kg"]) {
        
        maxWeight = ([maxWeightNumber floatValue] * 0.453592);
    } else {
        maxWeight = [maxWeightNumber floatValue];
    }
    
    if (maxWeightNumber == nil) {
        return 50.0;
    }
    
    else if (maxWeightNumber == 0)
    {
        NSLog (@"no values");
        maxWeight = 50.0;
        
    }
    
    [self.graph reloadData];
    
    NSLog(@"minWeight %f", maxWeight);
    return maxWeight;
}

- (float)getMinWeight
{

    //NSLog(@"minWeightNumber", minWeightNumber);
    NSNumber *minWeightNumber = [self.vals valueForKeyPath:@"@min.intValue"];
        NSLog(@"minWeightNumber, %@", minWeightNumber);
    
    float minWeight = [minWeightNumber doubleValue];
    
    
    
  //  double minWeight = [self.vals indexOfObject:min];

    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([[defaults objectForKey:@"unit"] isEqual:@"kg"]) {
        
        minWeight = ([minWeightNumber floatValue] * 0.453592);
    } else {
        minWeight = [minWeightNumber floatValue];
    }
    
    if (minWeightNumber == nil) {
        return 50.0;
    }
    
    else if (minWeightNumber == 0)
    {
        NSLog (@"no values");
        minWeight = 50.0;
        
    }
    
    [self.graph reloadData];
    
    NSLog(@"minWeight %f", minWeight);
    return minWeight;
    
}




// This method is here because this class also functions as datasource for our graph
// Therefore this class implements the CPTPlotDataSource protocol
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plotnumberOfRecords {
    
    //  return self.plotData.count;
    
    return [self.vals count]; // Our sample graph contains 9 'points'
}

// This method is here because this class also functions as datasource for our graph
// Therefore this class implements the CPTPlotDataSource protocol


-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    // return self.plotData[index][@(fieldEnum)];
    
    NSNumber * result = [[NSNumber alloc] init];
    // This method returns x and y values.  Check which is being requested here.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (fieldEnum == CPTScatterPlotFieldX)
    {
        
        NSDate * dateResult = [self.dateVals objectAtIndex:index];
        
        NSLog(@"withings dateResult, %@", dateResult);
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:dateResult];
        
        [components setHour: 10];
        
        NSDate *newDate = [[NSCalendar currentCalendar] dateFromComponents:components];
        
        double intervalInSecondsFirst  = ([newDate timeIntervalSinceDate:self.refDate]);
        result = [NSNumber numberWithDouble:intervalInSecondsFirst];
        
        if (self.withingsSegment.selectedSegmentIndex == 0)
        {
            double intervalInSecondsFirst = ([newDate timeIntervalSinceDate:self.refDate]); // get difference
            
            NSLog (@"intervalinsecondsfirst %f", intervalInSecondsFirst);
            
            
            return [NSNumber numberWithDouble:intervalInSecondsFirst]; // return difference
            
        }
        else if (self.withingsSegment.selectedSegmentIndex ==1)
        {
            double intervalInSecondsFirst = [dateResult timeIntervalSinceDate:self.refDate]; // get difference
            // get difference
            
            return [NSNumber numberWithDouble:intervalInSecondsFirst]; // return difference
            
        }
        else if (self.withingsSegment.selectedSegmentIndex ==2){
            double intervalInSeconds = [dateResult timeIntervalSinceDate:self.refDate]; // get difference
            return [NSNumber numberWithDouble:intervalInSeconds]; // return difference
            
        }
        
        
        
    }
    
    else
    {
        //Return y value, for this example we'll be plotting y = x * x
//        if ([self.fetchedResultsController.fetchedObjects count] > index) {
            if([[defaults objectForKey:@"unit"] isEqual:@"kg"]) {
                NSNumber *initResult = [self.vals objectAtIndex:index];
                float floatResult = [initResult floatValue] * 0.453592;
                result = @(floatResult);
                NSLog(@"x %@", result);
                return result;
            }
            else {
                NSNumber *result = [self.vals objectAtIndex:index];
                NSLog(@"y %@", result);
                return  result;
/*            }

            
        } else {
            return nil;
        }*/
        
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


