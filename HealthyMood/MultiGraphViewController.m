//
//  MultiGraphViewController.m
//  HealthyMood
//
//  Created by Nadine Khattak on 11/29/15.
//  Copyright © 2015 Ensach. All rights reserved.
//

#import "MultiGraphViewController.h"
#import "AppDelegate.h"
#import "CorePlot-CocoaTouch.h"
#import "WithingsWeightGraphViewController.h"
#import "OAuth1Controller.h"
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Mood.h"
#import "Weight.h"

@interface MultiGraphViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *manualWeightFetchedResultsController;


@property (nonatomic, strong) OAuth1Controller *oauth1Controller;
@property (nonatomic, strong) NSString *oauthToken;
@property (nonatomic, strong) NSString *oauthTokenSecret;
@property (nonatomic, strong) NSString *withingsWeightMeas;
@property (nonatomic, strong) NSDate *withingsWeightDate;
@property (nonatomic, strong) NSMutableArray *withingsWeightVals;
@property (nonatomic, strong) NSMutableArray *withingsDateVals;

@property (nonatomic, strong) NSMutableArray *samplesArray;
@property (nonatomic, strong) NSMutableArray *samplesDateArray;
@property (nonatomic, retain) HKHealthStore *healthStore;
@property (nonatomic, strong) NSDate *stepsDate;

@property (nonatomic, readwrite, strong) CPTGraph *aGraph;
@property (nonatomic, readwrite, strong) CPTXYGraph *stepsGraph;
@property (nonatomic, readwrite, strong) CPTXYGraph *withingsWeightGraph;
@property (nonatomic, readwrite, strong) CPTXYGraph *manualWeightGraph;

;
@property (nonatomic, readwrite, strong) CPTXYGraph *moodGraph;

@property (nonatomic, readwrite, strong) NSDate *refDate;
@property (nonatomic, readwrite, strong) NSDate *refDateMonth;
@property (nonatomic, readwrite, strong) NSDate *refDateYear;
@property (nonatomic, readwrite, strong) NSDate *refDateWeek;

@property (nonatomic, readwrite, strong) IBOutlet CPTGraphHostingView *hostView;
@property (nonatomic, readwrite, strong) NSArray *plotData;
@property (nonatomic) float minSteps;
@property (nonatomic) float maxSteps;

@property (nonatomic, readwrite,strong) CPTScatterPlot *stepsPlot;
@property (nonatomic, readwrite,strong) CPTScatterPlot *withingsWeightPlot;
@property (nonatomic, readwrite,strong) CPTScatterPlot *manualWeightPlot;




@end

@implementation MultiGraphViewController

float minWeight;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    [self setupStepsGraph];
    
    [self setupMoodGraph];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([[defaults objectForKey:@"weightEntryType"] isEqual:@"autoWithings"]) {
        
         [self setupsWithingWeightGraph];
    }
    
    else if ([[defaults objectForKey:@"weightEntryType"]  isEqual: @"manualWeightEntry"])
    {
        [self setupManualWeightGraph];
    }
    
    else if ([[defaults objectForKey:@"weightEntryType"]  isEqual:nil])
    {
        [self setupManualWeightGraph];
    }
  //  [self makeWithingsWeightGraph];
    
    // Do any additional setup after loading the view.
    
    
    
}

-(void)setupMoodGraph {
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
    

        [self makeMoodGraph];
    

    
    

}


-(void)setupsWithingWeightGraph {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *oauthToken = [ defaults objectForKey:@"oauthToken"];
    NSString *oauthTokenSecret = [ defaults objectForKey:@"oauthTokenSecret"];
    NSString *userid = [defaults objectForKey:@"userid"];
    
    NSLog(@"userid, %@", userid);
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSError *error;
    
    if (error){
        //[self makeWithingsWeightGraph];
    }
    
    self.withingsWeightVals = [[NSMutableArray alloc] init];
    self.withingsWeightMeas = [[NSString alloc] init];
    
    self.withingsDateVals = [[NSMutableArray alloc] init];
    self.withingsWeightDate   = [[NSDate alloc] init];
    
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
    
    if (error) {
        [self makeWithingsWeightGraph];
    }
    
    if (data.length > 0 && error == nil)
    {
        NSDictionary *greeting = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:0
                                                                   error:NULL];
        
        NSDictionary *body = greeting[@"body"];
        NSDictionary *measureGroups = body[@"measuregrps"];
        
        NSLog(@"greeting %@", greeting);
        NSLog(@"measuregroups %@", measureGroups);
        
        if (!measureGroups)
        {
            NSError *error = [NSError errorWithDomain:@"com.nadine.healthymood"
                                                 code:-1
                                             userInfo:@{NSLocalizedDescriptionKey:@"Unexpected response, no measurement groups"}];
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
                        
                        self.withingsWeightDate = epochNSDate;
                        
                        
                        
                        NSUInteger rawMeas = [measureWeights[@"value"] unsignedIntegerValue];
                        
                        short unit = [measureWeights[@"unit"] shortValue];
                        
                        NSDecimalNumber *measureNum = [NSDecimalNumber decimalNumberWithMantissa: rawMeas
                                                                                        exponent:unit
                                                                                      isNegative:NO];
                        
                        double measureNumDouble = [measureNum doubleValue];
                        
                        double measureNumPounds = measureNumDouble * 2.2046;
                        
                        NSNumber *measureNumPoundsNumber = [NSNumber numberWithDouble:measureNumPounds];
                        
                        self.withingsWeightMeas = [measureNumPoundsNumber stringValue];
                        
                        [self.withingsWeightVals addObject:self.withingsWeightMeas];
                        
                        [self.withingsDateVals addObject:self.withingsWeightDate];
                        
                        // [self.weightMeas addObject:[measureWeights objectForKey:@"value"]];
                        NSLog(@"weight asdf, %@, %@", self.withingsWeightMeas, self.withingsWeightVals);
                        
                        NSLog(@"weight date, %@, %@", self.withingsWeightDate, self.withingsDateVals);
                        
                    }
                    
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self.withingsWeightGraph reloadData];

        });
    };
    
    [self makeWithingsWeightGraph];
}


-(void)setupStepsGraph {
    HKHealthStore *healthStore = [[HKHealthStore alloc] init];
    self.samplesArray = [[NSMutableArray alloc] init];
    self.samplesDateArray = [[NSMutableArray alloc] init];
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    
    interval.day = 1;
    
    NSDateComponents *anchorComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday fromDate:[NSDate date]];
    
    NSInteger offset = (7 + anchorComponents.weekday - 2) % 7;
    anchorComponents.day -= offset;
    anchorComponents.hour = 0;
    
    NSDate *anchorDate = [calendar dateFromComponents:anchorComponents];
    
    HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType
                                                                           quantitySamplePredicate:nil
                                                                                           options:HKStatisticsOptionCumulativeSum
                                                                                        anchorDate:anchorDate
                                                                                intervalComponents:interval];
    
    query.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {
        if (error) {
            // Perform proper error handling here
            NSLog(@"*** An error occurred while calculating the statistics: %@ ***",
                  error.localizedDescription);
            self.stepsDate = [NSDate date];
            
            NSString *samplesString = [NSString stringWithFormat:@"%@", @"0"];
            
            [self.samplesArray addObject:self.stepsDate];
            [self.samplesArray addObject:samplesString];
            
            [self makeStepsGraph];
        }
        
        NSDate *endDate = [NSDate date];
        NSDate *startDate = [calendar
                             dateByAddingUnit:NSCalendarUnitMonth
                             value:-12
                             toDate:endDate
                             options:0];
        
        [results enumerateStatisticsFromDate:startDate toDate:endDate withBlock:^(HKStatistics *result, BOOL *stop) {
            HKQuantity *quantity = result.sumQuantity;
            
            if (quantity) {
                NSDate *date = result.startDate;
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                
                //self.weightDate = [dateFormatter stringFromDate:date];
                self.stepsDate = date;
                
                NSLog(@"sample date, %@", self.stepsDate);
                
                
                double value = [quantity doubleValueForUnit:[HKUnit countUnit]];
                
                NSLog(@"double value %f", value);
                
                NSString *samplesString = [NSString stringWithFormat:@"%@", quantity];
                
                [self.samplesArray addObject:samplesString];
                
                [self.samplesDateArray addObject:self.stepsDate];
                
                NSLog(@"sample date, %@", self.samplesArray);
                
                
            }
            
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                NSLog(@"[STEP] %@", self.samplesArray);
                [self getMinSteps];
                [self getMaxSteps];
                [self.stepsGraph reloadData];
                [self makeStepsGraph];
                
            }
        });
        
        
    };
    
    query.statisticsUpdateHandler = ^(HKStatisticsCollectionQuery *query, HKStatistics *result, HKStatisticsCollection *results, NSError *error) {
        if (error) {
            // Perform proper error handling here
            NSLog(@"*** An error occurred while calculating the statistics: %@ ***",
                  error.localizedDescription);
            [self makeStepsGraph];
        }
        
        NSDate *endDate = [NSDate date];
        NSDate *startDate = [calendar
                             dateByAddingUnit:NSCalendarUnitMonth
                             value:-12
                             toDate:endDate
                             options:0];
        
        [results enumerateStatisticsFromDate:startDate toDate:endDate withBlock:^(HKStatistics *result, BOOL *stop) {
            HKQuantity *quantity = result.sumQuantity;
            
            if (quantity) {
                NSDate *date = result.startDate;
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                
                //self.weightDate = [dateFormatter stringFromDate:date];
                self.stepsDate = date;
                
                NSLog(@"sample date, %@", self.stepsDate);
                
                
                double value = [quantity doubleValueForUnit:[HKUnit countUnit]];
                
                NSLog(@"double value %f", value);
                
                NSString *samplesString = [NSString stringWithFormat:@"%@", quantity];
                
                [self.samplesArray addObject:samplesString];
                
                [self.samplesDateArray addObject:self.stepsDate];
                
                NSLog(@"sample date, %@", self.samplesArray);
                
                
            }
            
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                NSLog(@"[STEP] %@", self.samplesArray);
                [self getMinSteps];
                [self getMaxSteps];
                [self.stepsGraph reloadData];
                [self makeStepsGraph];
                
            }
        });
        
        
    };
    
    
    
    
    [healthStore executeQuery:query];
    
    [[UISegmentedControl appearance] setTintColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]];
    
    [self.stepsGraph reloadData];
    
    
    
}


- (void)setupManualWeightGraph {
    AppDelegate *newDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = newDelegate.managedObjectContext;
    
    NSError *error = nil;
    NSFetchRequest *manualWeightFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Weight"];
    [manualWeightFetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"weightDate" ascending:YES]]];
    self.manualWeightFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:manualWeightFetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSLog(@"Before fetch fetchRequests manual weight, %@", self.manualWeightFetchedResultsController.fetchedObjects);
    // Perform Fetch
    [self.manualWeightFetchedResultsController performFetch:&error];
    NSLog(@"After fetch fetchRequests manual weight, %@", self.manualWeightFetchedResultsController.fetchedObjects);
    if ((error) || [self.manualWeightFetchedResultsController.fetchedObjects count] == 0)
    {
        [self makeEmptyManualWeightGraph];
    }
    else {
        [self makeManualWeightGraph];
    }

}


-(void)makeStepsGraph {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd"];
    
    
    
    // NSDate *today = [[NSDate alloc] initWithTimeIntervalSinceNow: 0];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    
    NSDate *today = [calendar dateBySettingHour:0 minute:0 second:0 ofDate:[NSDate date] options:0];
    //   NSDate *refDate            = today;
    NSTimeInterval oneDay      = 24 * 60 * 60;
    
    self.refDate            =     [NSDate dateWithTimeIntervalSinceReferenceDate:today.timeIntervalSinceReferenceDate - (6 * 24 * 60 * 60) ];
    
    self.view.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:0.0/255.0 blue:87.0/255.0 alpha:1.0f];
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    
    [[UISegmentedControl appearance] setTintColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]];
    
    //CPTTheme *theme      = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    //[newGraph applyTheme:theme];
    self.stepsGraph = newGraph;
    

    
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 10.0f;
    

    self.stepsGraph.title = @"Steps";
    self.stepsGraph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    self.stepsGraph.titleDisplacement = CGPointMake(0.0f, 16.0f);
    
    self.stepsGraph.titleTextStyle = titleStyle;
    
    
    self.hostView.hostedGraph = newGraph;
    
    
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    [textStyle setFontSize:8.0f];
    [textStyle setColor:[CPTColor colorWithComponentRed: 255.0f/255.0f green:250.0f/255.0f blue:250.0f/255.0f alpha:1.0f]];
    
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)newGraph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    
    x.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    x.majorIntervalLength         = CPTDecimalFromDouble(oneDay);
    
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(self.minSteps - 1000.0);
    x.minorTicksPerInterval       = 0;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"MM/dd"];
    
    
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = self.refDate;
    x.labelFormatter            = timeFormatter;
    
    
    [x setLabelTextStyle:textStyle];
    
    CPTXYAxis *y = axisSet.yAxis;
    //y.title=@"Steps";
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:0];
    
    
    y.labelFormatter = numberFormatter;
    
    y.majorIntervalLength         = CPTDecimalFromDouble(5000);
    y.minorTicksPerInterval       = 0;
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(self.minSteps - 1000.0);
    y.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    
    [y setLabelTextStyle:textStyle];
    
    // Create a plot that uses the data source method
    self.stepsPlot = [[CPTScatterPlot alloc] init];
    self.stepsPlot.identifier = @"Steps Plot";
    
    CPTMutableLineStyle *lineStyle = [self.stepsPlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 1.0;
    lineStyle.lineColor              = [CPTColor whiteColor];
    self.stepsPlot.dataLineStyle = lineStyle;
    
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 1.0;
    axisLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:0.8];
    
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineWidth = 0.2;
    tickLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:1.0];
    
    y.majorTickLineStyle = tickLineStyle;
    x.majorTickLineStyle = tickLineStyle;
    
    y.axisLineStyle = axisLineStyle;
    x.axisLineStyle = axisLineStyle;
    
    
    self.stepsPlot.dataSource = self;
    [newGraph addPlot:self.stepsPlot];
    
    NSInteger countRecords = [self.samplesArray count]; // Our sample graph contains 9 'points'
    
    NSLog (@"countRecords %ld", (long)countRecords);
    
    
    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    NSTimeInterval xLow       = 0.0;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xLow) length:CPTDecimalFromDouble(oneDay * 6.0 + (oneDay * 0.3))];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(self.minSteps-1000.0)
                                                    length:CPTDecimalFromFloat((self.maxSteps- self.minSteps) + 4000.0)];
    
    
   // float timeFrameSize = self.timeFrameSegment.frame.origin.y;
    

    
    if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) ||
        ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)) {
        
        CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.1,
                                                                                                 self.timeFrameSegment.frame.size.height + (self.timeFrameSegment.frame.size.height * 1.9),
                                                                                                 (self.view.frame.size.width * 0.83),
                                                                                                 (self.view.frame.size.height *0.45) - (self.timeFrameSegment.frame.size.height) )];
        
        
        [self.view addSubview:hostingView];
        
        hostingView.hostedGraph = self.stepsGraph;
        
        
        self.stepsGraph.paddingLeft = 35.0;
        self.stepsGraph.paddingTop = 5.0;
        self.stepsGraph.paddingRight = 35.0;
        self.stepsGraph.paddingBottom = 25.0;
        
        self.stepsGraph.plotAreaFrame.paddingBottom = 50.0;
        self.stepsGraph.plotAreaFrame.paddingLeft = 40.0;
        self.stepsGraph.plotAreaFrame.paddingTop = 5.0;
        self.stepsGraph.plotAreaFrame.paddingRight = 30.0;
        
        
    }
    
    else {
       
        CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0,
                                                                                                 self.timeFrameSegment.frame.size.height + (self.timeFrameSegment.frame.size.height + 30),
                                                                                                 (self.view.frame.size.width),
                                                                                                 (self.view.frame.size.height *0.5) - (self.timeFrameSegment.frame.size.height + 20) )];
        
        
        [self.view addSubview:hostingView];
        
        hostingView.hostedGraph = self.stepsGraph;
        
        self.stepsGraph.paddingLeft = 35.0;
        self.stepsGraph.paddingTop = 35.0;
        self.stepsGraph.paddingRight = 35.0;
        self.stepsGraph.paddingBottom = 25.0;
        
        self.stepsGraph.plotAreaFrame.paddingBottom = 50.0;
        self.stepsGraph.plotAreaFrame.paddingLeft = 40.0;
        self.stepsGraph.plotAreaFrame.paddingTop = 5.0;
        self.stepsGraph.plotAreaFrame.paddingRight = 30.0;
        
    }
    
    
    for (CPTPlot *p in self.stepsGraph.allPlots)
    {
        [p reloadData];
    }

    
    [self.stepsGraph reloadData];
    
}


-(void)makeWithingsWeightGraph {
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd"];
    
    
    
    // NSDate *today = [[NSDate alloc] initWithTimeIntervalSinceNow: 0];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDate *today = [calendar dateBySettingHour:0 minute:0 second:0 ofDate:[NSDate date] options:0];
    //   NSDate *refDate            = today;
    NSTimeInterval oneDay      = 24 * 60 * 60;
    
    self.refDate            =     [NSDate dateWithTimeIntervalSinceReferenceDate:today.timeIntervalSinceReferenceDate - (6 * 24 * 60 * 60) ];
    
    self.view.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:0.0/255.0 blue:87.0/255.0 alpha:1.0f];
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    
    [[UISegmentedControl appearance] setTintColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]];
    
    //CPTTheme *theme      = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    //[newGraph applyTheme:theme];
    self.withingsWeightGraph = newGraph;
    
    self.hostView.hostedGraph = newGraph;
    
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 10.0f;
    
    
    self.withingsWeightGraph.title = @"Weight (Withings)";
    self.withingsWeightGraph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    self.withingsWeightGraph.titleDisplacement = CGPointMake(0.0f, 16.0f);
    
    self.withingsWeightGraph.titleTextStyle = titleStyle;

    
    
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    [textStyle setFontSize:8.0f];
    [textStyle setColor:[CPTColor colorWithComponentRed: 255.0f/255.0f green:250.0f/255.0f blue:250.0f/255.0f alpha:1.0f]];
    
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)newGraph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    
    x.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    x.majorIntervalLength         = CPTDecimalFromDouble(oneDay);
    
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble([self getMinWeight] - 10.0);
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
    
    y.majorIntervalLength         = CPTDecimalFromDouble(10);
    y.minorTicksPerInterval       = 0;
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble([self getMinWeight] - 10.0);
    y.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    
    [y setLabelTextStyle:textStyle];
    
    // Create a plot that uses the data source method
    self.withingsWeightPlot= [[CPTScatterPlot alloc] init];
    self.withingsWeightPlot.identifier = @"Withings Weight Plot";
    
    CPTMutableLineStyle *lineStyle = [self.withingsWeightPlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 1.0;
    lineStyle.lineColor              = [CPTColor whiteColor];
    self.withingsWeightPlot.dataLineStyle = lineStyle;
    
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 1.0;
    axisLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:0.5];
    
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineWidth = 0.2;
    tickLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:1.0];
    
    y.majorTickLineStyle = tickLineStyle;
    x.majorTickLineStyle = tickLineStyle;
    
    y.axisLineStyle = axisLineStyle;
    x.axisLineStyle = axisLineStyle;
    
    
    self.withingsWeightPlot.dataSource = self;
    [newGraph addPlot:self.withingsWeightPlot];
    
    NSInteger countRecords = [self.withingsWeightVals count]; // Our sample graph contains 9 'points'
    
    NSLog (@"countRecords %ld", (long)countRecords);
    
    
    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    NSTimeInterval xLow       = 0.0;
    

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xLow) length:CPTDecimalFromDouble(oneDay * 6.0 + (oneDay * 0.3))];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat([self getMinWeight]-10.0)
                                                    length:CPTDecimalFromFloat(([self getMaxWeight]- [self getMinWeight]) + 20.0)];
    
    
    
    if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) ||
        ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)) {
        
        
        CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.1,
                                                                                                 (self.timeFrameSegment.frame.size.height + (self.timeFrameSegment.frame.size.height ) + (self.view.frame.size.height *0.45) - (self.timeFrameSegment.frame.size.height)),
                                                                                                 (self.view.frame.size.width * 0.83),
                                                                                                 (self.view.frame.size.height *0.45) - (self.timeFrameSegment.frame.size.height))];
        
        
        [self.view addSubview:hostingView];
        
        hostingView.hostedGraph = self.withingsWeightGraph;
        
        self.withingsWeightGraph.paddingLeft = 35.0;
        self.withingsWeightGraph.paddingTop = 5.0;
        self.withingsWeightGraph.paddingRight = 35.0;
        self.withingsWeightGraph.paddingBottom = 25.0;
        
        self.withingsWeightGraph.plotAreaFrame.paddingBottom = 50.0;
        self.withingsWeightGraph.plotAreaFrame.paddingLeft = 40.0;
        self.withingsWeightGraph.plotAreaFrame.paddingTop = 5.0;
        self.withingsWeightGraph.plotAreaFrame.paddingRight = 30.0;
        
        
    }
    
    else {
        
        CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, self.timeFrameSegment.frame.size.height + (self.view.frame.size.height *0.5) - (self.timeFrameSegment.frame.size.height + 30), (self.view.frame.size.width), (self.view.frame.size.height *0.5) - (self.timeFrameSegment.frame.size.height + 30) )];
        
        
    
        
        [self.view addSubview:hostingView];
        
        hostingView.hostedGraph = self.withingsWeightGraph;

        
        self.withingsWeightGraph.paddingLeft = 35.0;
        self.withingsWeightGraph.paddingTop = 35.0;
        self.withingsWeightGraph.paddingRight = 35.0;
        self.withingsWeightGraph.paddingBottom = 25.0;
        
        self.withingsWeightGraph.plotAreaFrame.paddingBottom = 50.0;
        self.withingsWeightGraph.plotAreaFrame.paddingLeft = 40.0;
        self.withingsWeightGraph.plotAreaFrame.paddingTop = 5.0;
        self.withingsWeightGraph.plotAreaFrame.paddingRight = 30.0;
        
    }
    
    
    for (CPTPlot *p in self.withingsWeightGraph.allPlots)
    {
        [p reloadData];
    }

    

}

-(void)makeMoodGraph {
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
    
    self.moodGraph = newGraph;
    
    self.hostView.hostedGraph = newGraph;
    
    
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 10.0f;
    
    
    self.moodGraph.title = @"Mood";
    self.moodGraph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    self.moodGraph.titleDisplacement = CGPointMake(0.0f, 16.0f);
    
    self.moodGraph.titleTextStyle = titleStyle;

    
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
    dataSourceLinePlot.identifier = @"Mood Plot";
    
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
    
 //   CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, self.timeFrameSegment.frame.size.height + ((self.view.frame.size.height *0.5) - (self.timeFrameSegment.frame.size.height - 60)*2), (self.view.frame.size.width), (self.view.frame.size.height *0.5) - (self.timeFrameSegment.frame.size.height + 30) )];
    
//    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, self.timeFrameSegment.frame.size.height + 70, (self.view.frame.size.width), (self.view.frame.size.height *0.5) - (self.timeFrameSegment.frame.size.height + 20) )];

    
    
    
    
    
   if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) ||
        ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)) {
       
       CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.1,
                                                                                                (self.timeFrameSegment.frame.size.height + (self.timeFrameSegment.frame.size.height ) + (self.view.frame.size.height *0.3) - (self.timeFrameSegment.frame.size.height) + (self.view.frame.size.height *0.45) - (self.timeFrameSegment.frame.size.height)),
                                                                                                (self.view.frame.size.width * 0.83),
                                                                                                (self.view.frame.size.height *0.45) - (self.timeFrameSegment.frame.size.height))];
       
       
       /*CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.1,
                                                                                                (self.timeFrameSegment.frame.size.height + (self.timeFrameSegment.frame.size.height ) + (self.view.frame.size.height *0.4) - (self.timeFrameSegment.frame.size.height)),
                                                                                                (self.view.frame.size.width * 0.83),
                                                                                                (self.view.frame.size.height *0.45) - (self.timeFrameSegment.frame.size.height))];
       */
       
       [self.view addSubview:hostingView];
       
       hostingView.hostedGraph = self.moodGraph;

        self.moodGraph.paddingLeft = 35.0;
        self.moodGraph.paddingTop = 5.0;
        self.moodGraph.paddingRight = 35.0;
        self.moodGraph.paddingBottom = 25.0;
        
        self.moodGraph.plotAreaFrame.paddingBottom = 50.0;
        self.moodGraph.plotAreaFrame.paddingLeft = 40.0;
        self.moodGraph.plotAreaFrame.paddingTop = 5.0;
        self.moodGraph.plotAreaFrame.paddingRight = 35.0;
        
        
    }
    
    else {
        
        CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, self.timeFrameSegment.frame.size.height + ((self.view.frame.size.height *0.5) - (self.timeFrameSegment.frame.size.height - 60)*2), (self.view.frame.size.width), (self.view.frame.size.height *0.5) - (self.timeFrameSegment.frame.size.height + 30) )];

        
        
        [self.view addSubview:hostingView];
        
        hostingView.hostedGraph = self.moodGraph;
        
        self.moodGraph.paddingLeft = 35.0;
        self.moodGraph.paddingTop = 35.0;
        self.moodGraph.paddingRight = 35.0;
        self.moodGraph.paddingBottom = 25.0;
        
        self.moodGraph.plotAreaFrame.paddingBottom = 50.0;
        self.moodGraph.plotAreaFrame.paddingLeft = 40.0;
        self.moodGraph.plotAreaFrame.paddingTop = 5.0;
        self.moodGraph.plotAreaFrame.paddingRight = 30.0;
        
    }
    
    
    for (CPTPlot *p in self.moodGraph.allPlots)
    {
        [p reloadData];
    }
 
    
    [self.moodGraph reloadData];
    
}

- (void)makeEmptyManualWeightGraph {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd"];
    
    self.manualWeightPlot = [[CPTScatterPlot alloc] init];
    self.manualWeightPlot.identifier = @"Manual Weight Plot";
    
    
    
    // NSDate *today = [[NSDate alloc] initWithTimeIntervalSinceNow: 0];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDate *today = [calendar dateBySettingHour:0 minute:0 second:0 ofDate:[NSDate date] options:0];
    //   NSDate *refDate            = today;
    NSTimeInterval oneDay      = 24 * 60 * 60;
    
    self.refDate            =     [NSDate dateWithTimeIntervalSinceReferenceDate:today.timeIntervalSinceReferenceDate - (6 * 24 * 60 * 60) ];
    
    self.view.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:0.0/255.0 blue:87.0/255.0 alpha:1.0f];
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    
    [[UISegmentedControl appearance] setTintColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]];
    
    //CPTTheme *theme      = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    //[newGraph applyTheme:theme];
    self.manualWeightGraph = newGraph;
    
    self.hostView.hostedGraph = newGraph;
    
    
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 10.0f;
    
    
    self.manualWeightGraph.title = @"Weight (Manual)";
    self.manualWeightGraph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    self.manualWeightGraph.titleDisplacement = CGPointMake(0.0f, 16.0f);
    
    self.manualWeightGraph.titleTextStyle = titleStyle;
    
    
    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    NSTimeInterval xLow       = 0.0;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xLow) length:CPTDecimalFromDouble(oneDay * 6.0 + (oneDay * 0.3))];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0)
                                                    length:CPTDecimalFromFloat(50)];
    
    
    
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    [textStyle setFontSize:8.0f];
    [textStyle setColor:[CPTColor colorWithComponentRed: 255.0f/255.0f green:250.0f/255.0f blue:250.0f/255.0f alpha:1.0f]];
    
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)newGraph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    
    x.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    x.majorIntervalLength         = CPTDecimalFromDouble(oneDay);
    
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0);
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
    
    y.majorIntervalLength         = CPTDecimalFromDouble(10);
    y.minorTicksPerInterval       = 0;
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble([self getMinManualWeight] - 10.0);
    y.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    
    [y setLabelTextStyle:textStyle];
    
    // Create a plot that uses the data source method
    CPTMutableLineStyle *lineStyle = [self.manualWeightPlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 1.0;
    lineStyle.lineColor              = [CPTColor whiteColor];
    self.manualWeightPlot.dataLineStyle = lineStyle;
    
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
    
    
    self.manualWeightPlot.dataSource = self;
    [newGraph addPlot:self.manualWeightPlot];
    
    NSInteger countRecords = [self.manualWeightFetchedResultsController.fetchedObjects count]; // Our sample graph contains 9 'points'
    
    NSLog (@"countRecords %ld", (long)countRecords);
    
    
    if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) ||
        ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)) {
        
        
        CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.1,
                                                                                                 (self.timeFrameSegment.frame.size.height + (self.timeFrameSegment.frame.size.height ) + (self.view.frame.size.height *0.4) - (self.timeFrameSegment.frame.size.height)),
                                                                                                 (self.view.frame.size.width * 0.83),
                                                                                                 (self.view.frame.size.height *0.45) - (self.timeFrameSegment.frame.size.height))];
        
        
        [self.view addSubview:hostingView];
        
        hostingView.hostedGraph = self.manualWeightGraph;
        
        self.manualWeightGraph.paddingLeft = 35.0;
        self.manualWeightGraph.paddingTop = 5.0;
        self.manualWeightGraph.paddingRight = 35.0;
        self.manualWeightGraph.paddingBottom = 25.0;
        
        self.manualWeightGraph.plotAreaFrame.paddingBottom = 50.0;
        self.manualWeightGraph.plotAreaFrame.paddingLeft = 40.0;
        self.manualWeightGraph.plotAreaFrame.paddingTop = 5.0;
        self.manualWeightGraph.plotAreaFrame.paddingRight = 30.0;
        
        
    }
    
    else {
        
        CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, self.timeFrameSegment.frame.size.height + (self.view.frame.size.height *0.5) - (self.timeFrameSegment.frame.size.height + 30), (self.view.frame.size.width), (self.view.frame.size.height *0.5) - (self.timeFrameSegment.frame.size.height + 30) )];
        
        
        
        
        [self.view addSubview:hostingView];
        
        hostingView.hostedGraph = self.manualWeightGraph;
        
        
        self.manualWeightGraph.paddingLeft = 35.0;
        self.manualWeightGraph.paddingTop = 35.0;
        self.manualWeightGraph.paddingRight = 35.0;
        self.manualWeightGraph.paddingBottom = 25.0;
        
        self.manualWeightGraph.plotAreaFrame.paddingBottom = 50.0;
        self.manualWeightGraph.plotAreaFrame.paddingLeft = 40.0;
        self.manualWeightGraph.plotAreaFrame.paddingTop = 5.0;
        self.manualWeightGraph.plotAreaFrame.paddingRight = 30.0;
        
    }
    
    
    
    for (CPTPlot *p in self.manualWeightGraph.allPlots)
    {
        [p reloadData];
    }
    
    
    [self.manualWeightGraph reloadData];
    
    
    
    
}
- (void)makeManualWeightGraph {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd"];
    
    self.manualWeightPlot = [[CPTScatterPlot alloc] init];
    self.manualWeightPlot.identifier = @"Manual Weight Plot";
    

    
    // NSDate *today = [[NSDate alloc] initWithTimeIntervalSinceNow: 0];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDate *today = [calendar dateBySettingHour:0 minute:0 second:0 ofDate:[NSDate date] options:0];
    //   NSDate *refDate            = today;
    NSTimeInterval oneDay      = 24 * 60 * 60;
    
    self.refDate            =     [NSDate dateWithTimeIntervalSinceReferenceDate:today.timeIntervalSinceReferenceDate - (6 * 24 * 60 * 60) ];
    
    self.view.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:0.0/255.0 blue:87.0/255.0 alpha:1.0f];
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    
    [[UISegmentedControl appearance] setTintColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]];
    
    //CPTTheme *theme      = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    //[newGraph applyTheme:theme];
    self.manualWeightGraph = newGraph;
    
    self.hostView.hostedGraph = newGraph;
    
    
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 10.0f;
    
    
    self.manualWeightGraph.title = @"Weight (Manual)";
    self.manualWeightGraph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    self.manualWeightGraph.titleDisplacement = CGPointMake(0.0f, 16.0f);
    
    self.manualWeightGraph.titleTextStyle = titleStyle;

    
    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    NSTimeInterval xLow       = 0.0;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xLow) length:CPTDecimalFromDouble(oneDay * 6.0 + (oneDay * 0.3))];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat([self getMinManualWeight]-10.0)
                                                    length:CPTDecimalFromFloat((([self getMaxManualWeight])- [self getMinManualWeight]) + 20.0)];
    
    
    
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    [textStyle setFontSize:8.0f];
    [textStyle setColor:[CPTColor colorWithComponentRed: 255.0f/255.0f green:250.0f/255.0f blue:250.0f/255.0f alpha:1.0f]];
    
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)newGraph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    
    x.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    x.majorIntervalLength         = CPTDecimalFromDouble(oneDay);
    
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble([self getMinManualWeight] - 10.0);
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
    
    y.majorIntervalLength         = CPTDecimalFromDouble(10);
    y.minorTicksPerInterval       = 0;
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble([self getMinManualWeight] - 10.0);
    y.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    
    [y setLabelTextStyle:textStyle];
    
    // Create a plot that uses the data source method
    CPTMutableLineStyle *lineStyle = [self.manualWeightPlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 1.0;
    lineStyle.lineColor              = [CPTColor whiteColor];
    self.manualWeightPlot.dataLineStyle = lineStyle;
    
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
    
    
    self.manualWeightPlot.dataSource = self;
    [newGraph addPlot:self.manualWeightPlot];
    
    NSInteger countRecords = [self.manualWeightFetchedResultsController.fetchedObjects count]; // Our sample graph contains 9 'points'
    
    NSLog (@"countRecords %ld", (long)countRecords);
    
    
    if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) ||
        ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)) {
        
        
        CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.1,
                                                                                                 (self.timeFrameSegment.frame.size.height + (self.timeFrameSegment.frame.size.height ) + (self.view.frame.size.height *0.4) - (self.timeFrameSegment.frame.size.height)),
                                                                                                 (self.view.frame.size.width * 0.83),
                                                                                                 (self.view.frame.size.height *0.45) - (self.timeFrameSegment.frame.size.height))];
        
        
        [self.view addSubview:hostingView];
        
        hostingView.hostedGraph = self.manualWeightGraph;
        
        self.manualWeightGraph.paddingLeft = 35.0;
        self.manualWeightGraph.paddingTop = 5.0;
        self.manualWeightGraph.paddingRight = 35.0;
        self.manualWeightGraph.paddingBottom = 25.0;
        
        self.manualWeightGraph.plotAreaFrame.paddingBottom = 50.0;
        self.manualWeightGraph.plotAreaFrame.paddingLeft = 40.0;
        self.manualWeightGraph.plotAreaFrame.paddingTop = 5.0;
        self.manualWeightGraph.plotAreaFrame.paddingRight = 30.0;
        
        
    }
    
    else {
        
        CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, self.timeFrameSegment.frame.size.height + (self.view.frame.size.height *0.5) - (self.timeFrameSegment.frame.size.height + 30), (self.view.frame.size.width), (self.view.frame.size.height *0.5) - (self.timeFrameSegment.frame.size.height + 30) )];
        
        
        
        
        [self.view addSubview:hostingView];
        
        hostingView.hostedGraph = self.manualWeightGraph;
        
        
        self.manualWeightGraph.paddingLeft = 35.0;
        self.manualWeightGraph.paddingTop = 35.0;
        self.manualWeightGraph.paddingRight = 35.0;
        self.manualWeightGraph.paddingBottom = 25.0;
        
        self.manualWeightGraph.plotAreaFrame.paddingBottom = 50.0;
        self.manualWeightGraph.plotAreaFrame.paddingLeft = 40.0;
        self.manualWeightGraph.plotAreaFrame.paddingTop = 5.0;
        self.manualWeightGraph.plotAreaFrame.paddingRight = 30.0;
        
    }
    

    
    for (CPTPlot *p in self.manualWeightGraph.allPlots)
    {
        [p reloadData];
    }
    
    
    [self.manualWeightGraph reloadData];

    
    

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)segmentChange {
    NSTimeInterval oneDay = 24 * 60 * 60;
    CPTXYPlotSpace *stepsPlotSpace = (CPTXYPlotSpace *)self.stepsGraph.defaultPlotSpace;

    CPTXYPlotSpace *weightPlotSpace = (CPTXYPlotSpace *)self.withingsWeightGraph.defaultPlotSpace;

    
    CPTXYPlotSpace *moodPlotSpace = (CPTXYPlotSpace *)self.moodGraph.defaultPlotSpace;
    
    CPTXYPlotSpace *manualWeightPlotSpace = (CPTXYPlotSpace *)self.manualWeightGraph.defaultPlotSpace;

    
    
    NSTimeInterval xLow = 0.0f;
    
    CPTXYAxisSet *stepsAxisSet = (id)self.stepsGraph.axisSet;
    CPTXYAxisSet *weightAxisSet = (id)self.withingsWeightGraph.axisSet;
    CPTXYAxisSet *moodAxisSet = (id)self.moodGraph.axisSet;
    CPTXYAxisSet *manualWeightAxisSet = (id)self.manualWeightGraph.axisSet;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDate *today = [calendar dateBySettingHour:0 minute:0 second:0 ofDate:[NSDate date] options:0];
    
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
    
    switch (self.timeFrameSegment.selectedSegmentIndex) {
        case 0:
            self.refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:today.timeIntervalSinceReferenceDate - (6 * 24 * 60 * 60) ];
            
            
            stepsPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xLow) length:CPTDecimalFromDouble(oneDay * 6.0 + (oneDay * 0.3))];
            
            weightPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xLow) length:CPTDecimalFromDouble(oneDay * 6.0 + (oneDay * 0.3))];

            moodPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xLow) length:CPTDecimalFromDouble(oneDay * 6.0 + (oneDay * 0.3))];

            manualWeightPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xLow) length:CPTDecimalFromDouble(oneDay * 6.0 + (oneDay * 0.3))];
            
            
            
            [dateFormatter setDateFormat:@"MM/d"];
            
            stepsAxisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay );

            weightAxisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay );

            
            moodAxisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay );
            
            manualWeightAxisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay );

            timeFormatter.referenceDate = self.refDate;
            
            stepsAxisSet.xAxis.labelFormatter = timeFormatter;
            weightAxisSet.xAxis.labelFormatter = timeFormatter;
            moodAxisSet.xAxis.labelFormatter = timeFormatter;
            manualWeightAxisSet.xAxis.labelFormatter = timeFormatter;
            
            //x.title = @"Week";
            
            
            [self.stepsGraph reloadData];
            [self.withingsWeightGraph reloadData];
            [self.moodGraph reloadData];
            [self.manualWeightGraph reloadData];
            
            
            break;
        case 1:
            self.refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:today.timeIntervalSinceReferenceDate - (oneDay * (numberOfDaysInMonth-1))];
            
            stepsPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xLow)
                                                            length:CPTDecimalFromFloat(oneDay * (numberOfDaysInMonth - 1) + (oneDay * .99) )];
            
            weightPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xLow)
                                                                 length:CPTDecimalFromFloat(oneDay * (numberOfDaysInMonth - 1) + (oneDay * .99) )];

            moodPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xLow)
                                                                  length:CPTDecimalFromFloat(oneDay * (numberOfDaysInMonth - 1) + (oneDay * .99) )];

            manualWeightPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xLow)
                                                                length:CPTDecimalFromFloat(oneDay * (numberOfDaysInMonth - 1) + (oneDay * .99) )];
            
            
            [dateFormatter setDateFormat:@"MMM d"];
            stepsAxisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay * 7);

            weightAxisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay * 7);

            moodAxisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay * 7);
            
            manualWeightAxisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay * 7);

            
            timeFormatter.referenceDate = self.refDate;

            stepsAxisSet.xAxis.labelFormatter = timeFormatter;
            weightAxisSet.xAxis.labelFormatter = timeFormatter;
            moodAxisSet.xAxis.labelFormatter = timeFormatter;
            manualWeightAxisSet.xAxis.labelFormatter = timeFormatter;
            // x.title = @"Day of Month";
            
            [self.stepsGraph reloadData];
            [self.withingsWeightGraph reloadData];
            [self.moodGraph reloadData];
            [self.manualWeightGraph reloadData];
            
            break;
        case 2:
            
            self.refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:today.timeIntervalSinceReferenceDate - (((daysInYear - numberOfDaysInMonth)) * 24 * 60 * 60) ];
            stepsPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xLow)
                                                            length:CPTDecimalFromFloat((oneDay * (daysInYear-30) + (oneDay * 12)) )];
            weightPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xLow)
                                                                 length:CPTDecimalFromFloat((oneDay * (daysInYear-30) + (oneDay * 12)) )];

            moodPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xLow)
                                                                  length:CPTDecimalFromFloat((oneDay * (daysInYear-30) + (oneDay * 12)) )];

            manualWeightPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xLow)
                                                                length:CPTDecimalFromFloat((oneDay * (daysInYear-30) + (oneDay * 12)) )];

            
            
            
            [dateFormatter setDateFormat:@"MMM"];
            stepsAxisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay * numberOfDaysInMonth);
            weightAxisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay * numberOfDaysInMonth);

            moodAxisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay * numberOfDaysInMonth);
            manualWeightAxisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay * numberOfDaysInMonth);

            
            
            timeFormatter.referenceDate = self.refDate;
            
            stepsAxisSet.xAxis.labelFormatter = timeFormatter;
            weightAxisSet.xAxis.labelFormatter = timeFormatter;
            moodAxisSet.xAxis.labelFormatter = timeFormatter;
            manualWeightAxisSet.xAxis.labelFormatter = timeFormatter;
            
            //x.title = @"Year";
            
            [self.stepsGraph reloadData];
            [self.withingsWeightGraph reloadData];
            [self.moodGraph reloadData];
            [self.manualWeightGraph reloadData];
            
            break;
            
        default:
            self.refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:today.timeIntervalSinceReferenceDate - (3 * 24 * 60 * 60) ];
            
            
            stepsPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xLow) length:CPTDecimalFromDouble(oneDay * 6.0)];
            stepsPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble([self getMinSteps]) length:CPTDecimalFromDouble([self getMaxSteps] + 20.0)];
            
            weightPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xLow) length:CPTDecimalFromDouble(oneDay * 6.0)];
            weightPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble([self getMinSteps]) length:CPTDecimalFromDouble([self getMaxSteps] + 20.0)];

            moodPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xLow) length:CPTDecimalFromDouble(oneDay * 6.0)];
            moodPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble([self getMinSteps]) length:CPTDecimalFromDouble([self getMaxSteps] + 20.0)];

            manualWeightPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xLow) length:CPTDecimalFromDouble(oneDay * 6.0)];
            manualWeightPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble([self getMinSteps]) length:CPTDecimalFromDouble([self getMaxSteps] + 20.0)];

            
            
            
            
            
            stepsAxisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay * 3 );
            weightAxisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay * 3 );
            moodAxisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay * 3 );
            manualWeightAxisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay * 3 );

            
            
            
            //timeFormatter.referenceDate = self.refDate;
            //axisSet.xAxis.labelFormatter = timeFormatter;
            //   x.title = @"Week";
            
            [self.stepsGraph reloadData];
            [self.withingsWeightGraph reloadData];
            [self.moodGraph reloadData];
            [self.manualWeightGraph reloadData];
            
            
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

/*
-(void)viewDidLayoutSubviews {
    
    
    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 70, (self.view.frame.size.width), (self.view.frame.size.height *0.5) - (70) )];
    
    
    
    [self.view addSubview:hostingView];
    
    hostingView.hostedGraph = self.stepsGraph;
    
    if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) ||
        ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)) {
        self.stepsGraph.paddingLeft = 40.0;
        self.stepsGraph.paddingTop = 0.0;
        self.stepsGraph.paddingRight = 40.0;
        self.stepsGraph.paddingBottom = 25.0;
        
        self.stepsGraph.plotAreaFrame.paddingBottom = 50.0;
        self.stepsGraph.plotAreaFrame.paddingLeft = 30.0;
        self.stepsGraph.plotAreaFrame.paddingTop = 5.0;
        self.stepsGraph.plotAreaFrame.paddingRight = 5.0;
        
        
    }
    
    else {
        self.stepsGraph.paddingLeft = 35.0;
        self.stepsGraph.paddingTop = 35.0;
        self.stepsGraph.paddingRight = 35.0;
        self.stepsGraph.paddingBottom = 25.0;
        
        self.stepsGraph.plotAreaFrame.paddingBottom = 50.0;
        self.stepsGraph.plotAreaFrame.paddingLeft = 30.0;
        self.stepsGraph.plotAreaFrame.paddingTop = 5.0;
        self.stepsGraph.plotAreaFrame.paddingRight = 30.0;
        
    }
    
    
    for (CPTPlot *p in self.stepsGraph.allPlots)
    {
        [p reloadData];
    }
    
    [self.stepsGraph reloadData];
    
}

*/
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if ( UIInterfaceOrientationIsPortrait(fromInterfaceOrientation) )
    {
        self.stepsGraph.paddingLeft = 40.0;
        self.stepsGraph.paddingTop = 0.0;
        self.stepsGraph.paddingRight = 40.0;
        self.stepsGraph.paddingBottom = 25.0;
        
        self.stepsGraph.plotAreaFrame.paddingBottom = 50.0;
        self.stepsGraph.plotAreaFrame.paddingLeft = 30.0;
        self.stepsGraph.plotAreaFrame.paddingTop = 5.0;
        self.stepsGraph.plotAreaFrame.paddingRight = 5.0;
    }
    
    for (CPTPlot *p in self.stepsGraph.allPlots)
    {
        [p reloadData];
    }
    
    [self.stepsGraph reloadData];
}

- (float)getTotalStepsEntries
{
    
    NSError *error = nil;
    
    return [self.samplesArray count];
}

- (float)getMaxSteps
{
    //NSLog(@"minWeightNumber", minWeightNumber);
    NSNumber *maxStepsNumber = [[NSNumber alloc] init];
    maxStepsNumber = [self.samplesArray valueForKeyPath:@"@max.intValue"];
    //   NSLog(@"minWeightNumber, %@", minStepsNumber);
    
    self.maxSteps = [maxStepsNumber doubleValue];
    
    
    
    //  double minWeight = [self.vals indexOfObject:min];
    
    /*
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
     if([[defaults objectForKey:@"unit"] isEqual:@"kg"]) {
     
     minWeight = ([minWeightNumber floatValue] * 0.453592);
     } else {
     minWeight = [minWeightNumber floatValue];
     }
     */
    
    if (maxStepsNumber == nil) {
        //  [self.graph reloadData];
        return 10000.0;
    }
    
    else if (maxStepsNumber == 0)
    {
        NSLog (@"no values");
        self.maxSteps = 50.0;
        
    }
    
    
    
    NSLog(@"maxSteps %f", self.maxSteps);
    
    [self.stepsGraph reloadData];
    return self.maxSteps;
}

- (float)getMinSteps
{
    
    //NSLog(@"minWeightNumber", minWeightNumber);
    NSNumber *minStepsNumber = [[NSNumber alloc] init];
    minStepsNumber = [self.samplesArray valueForKeyPath:@"@min.intValue"];
    //   NSLog(@"minWeightNumber, %@", minStepsNumber);
    
    self.minSteps = [minStepsNumber doubleValue];
    
    
    
    //  double minWeight = [self.vals indexOfObject:min];
    
    /*
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
     if([[defaults objectForKey:@"unit"] isEqual:@"kg"]) {
     
     minWeight = ([minWeightNumber floatValue] * 0.453592);
     } else {
     minWeight = [minWeightNumber floatValue];
     }
     */
    
    if (minStepsNumber == nil) {
        //  [self.graph reloadData];
        return 50.0;
    }
    
    else if (minStepsNumber == 0)
    {
        NSLog (@"no values");
        self.minSteps = 50.0;
        
    }
    
    NSLog(@"minStpes %f", self.minSteps);
    
    [self.stepsGraph reloadData];
    return self.minSteps;
    
}

- (float)getMaxWeight
{
    //NSLog(@"minWeightNumber", minWeightNumber);
    NSNumber *maxWeightNumber = [self.withingsWeightVals valueForKeyPath:@"@max.intValue"];
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
    
    [self.withingsWeightGraph reloadData];
    
    NSLog(@"minWeight %f", maxWeight);
    return maxWeight;
}

- (float)getMinWeight
{
  
    //NSLog(@"minWeightNumber", minWeightNumber);
    NSNumber *minWeightNumber = [self.withingsWeightVals valueForKeyPath:@"@min.intValue"];
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
    
    
    [self.withingsWeightGraph reloadData];
    
    NSLog(@"minWeight %f", minWeight);
    return minWeight;
    
}


- (float)getMaxManualWeight
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
    
    [self.manualWeightGraph reloadData];
    
    return maxWeight;
}

- (float)getMinManualWeight
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
    
    [self.manualWeightGraph reloadData];
    
    NSLog(@"minWeight %f", minWeight);
    return minWeight;
    
}
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plotnumberOfRecords {
    
    
    int recordNumber;
    //  return self.plotData.count;
    if ([plotnumberOfRecords.identifier isEqual:@"Steps Plot"])
    {
        return [self.samplesArray count]; // Our sample graph contains 9 'points'
    }
    
    else if ([plotnumberOfRecords.identifier isEqual:@"Withings Weight Plot"])
    {
        return [self.withingsWeightVals count]; // Our sample graph contains 9 'points'
    }
    
    else if ([plotnumberOfRecords.identifier isEqual:@"Mood Plot"])
    {
        return [self.fetchedResultsController.fetchedObjects count]; // Our 
    }
    else if ([plotnumberOfRecords.identifier isEqual:@"Manual Weight Plot"])
    {
        return [self.manualWeightFetchedResultsController.fetchedObjects count];
    }

    
    
    
    NSLog(@"plot identifier, %@", plotnumberOfRecords.identifier);
    return recordNumber;

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
        if ([plot.identifier isEqual:@"Steps Plot"])
                {
                    
                    NSDate * dateResult = [self.samplesDateArray objectAtIndex:index];
                    
                    NSLog(@"dateResult, %@", dateResult);
                    NSLog(@"index, %lu", (unsigned long)index);
                    
                    NSLog(@"withings dateResult, %@", dateResult);
                    
                    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:dateResult];
                    
                    [components setHour: 0];
                    
                    NSDate *newDate = [[NSCalendar currentCalendar] dateFromComponents:components];
                    
                    double intervalInSecondsFirst  = ([newDate timeIntervalSinceDate:self.refDate]);
                    
                    result = [NSNumber numberWithDouble:intervalInSecondsFirst];
                    
                    NSLog (@"intervalinsecondsfirst %f", intervalInSecondsFirst);
                    
                    NSLog(@"x results, %@", [NSNumber numberWithDouble:intervalInSecondsFirst]);
                    return [NSNumber numberWithDouble:intervalInSecondsFirst];
                    
                }

        else if ([plot.identifier isEqual:@"Withings Weight Plot"])
        {
            
            NSDate * dateResult = [self.withingsDateVals objectAtIndex:index];
            
            NSLog(@"dateResult, %@", dateResult);
            NSLog(@"index, %lu", (unsigned long)index);
            
            NSLog(@"withings dateResult, %@", dateResult);
            
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:dateResult];
            
            [components setHour: 0];
            
            NSDate *newDate = [[NSCalendar currentCalendar] dateFromComponents:components];
            
            double intervalInSecondsFirst  = ([newDate timeIntervalSinceDate:self.refDate]);
            
            result = [NSNumber numberWithDouble:intervalInSecondsFirst];
            
            NSLog (@"intervalinsecondsfirst %f", intervalInSecondsFirst);
            
            NSLog(@"x results, %@", [NSNumber numberWithDouble:intervalInSecondsFirst]);
            return [NSNumber numberWithDouble:intervalInSecondsFirst];
            
            
        }
        
        else if ([plot.identifier isEqual:@"Mood Plot"])
        {
            
            
            NSDate * moodDateResult = ((Mood*)[self.fetchedResultsController.fetchedObjects objectAtIndex:index]).moodDate;
            
            NSLog(@"moodDateResult, %@", moodDateResult);
            
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:moodDateResult];
            
            [components setHour: 0];
            
            NSDate *newDate = [[NSCalendar currentCalendar] dateFromComponents:components];
            
            double intervalInSecondsFirst  = ([newDate timeIntervalSinceDate:self.refDate]);
            result = [NSNumber numberWithDouble:intervalInSecondsFirst];
            
            
        }
        
        else if ([plot.identifier isEqual:@"Manual Weight Plot"])
        {
            NSDate * manualWeightDateResult = ((Weight*)[self.manualWeightFetchedResultsController.fetchedObjects objectAtIndex:index]).weightDate;
            
            NSLog(@"dateResult, %@", manualWeightDateResult);
            
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:manualWeightDateResult];
            
            [components setHour: 0];
            
            NSDate *manualWeightNewDate = [[NSCalendar currentCalendar] dateFromComponents:components];
            
            double intervalInSecondsFirst  = ([manualWeightNewDate timeIntervalSinceDate:self.refDate]);
            result = [NSNumber numberWithDouble:intervalInSecondsFirst];

        }
        
                /*
        if (self.timeFrameSegment.selectedSegmentIndex == 0)
        {
            double intervalInSecondsFirst = ([newDate timeIntervalSinceDate:self.refDate]); // get difference
            
            NSLog (@"intervalinsecondsfirst %f", intervalInSecondsFirst);
            
            
            return [NSNumber numberWithDouble:intervalInSecondsFirst]; // return difference
            
        }
        else if (self.timeFrameSegment.selectedSegmentIndex ==1)
        {
            double intervalInSecondsFirst = [dateResult timeIntervalSinceDate:self.refDate]; // get difference
            // get difference
            
            return [NSNumber numberWithDouble:intervalInSecondsFirst]; // return difference
            
        }
        else if (self.timeFrameSegment.selectedSegmentIndex ==2){
            double intervalInSeconds = [dateResult timeIntervalSinceDate:self.refDate]; // get difference
            return [NSNumber numberWithDouble:intervalInSeconds]; // return difference
            
        }
        
        */
        
    }
    
    else
    {
        //Return y value, for this example we'll be plotting y = x * x
        //        if ([self.fetchedResultsController.fetchedObjects count] > index) {
        
        if ([plot.identifier isEqual:@"Steps Plot"])
        {
            NSNumber *result = [self.samplesArray objectAtIndex:index];
            NSLog(@"y %@", result);
            return  result;
            
        }
        
        /*            }
         
         
         } else {
         return nil;
         }*/
        
        else if ([plot.identifier isEqual:@"Withings Weight Plot"])
        {
            if([[defaults objectForKey:@"unit"] isEqual:@"kg"]) {
                NSNumber *initResult = [self.withingsWeightVals objectAtIndex:index];
                float floatResult = [initResult floatValue] * 0.453592;
                result = @(floatResult);
                NSLog(@"x %@", result);
                return result;
            }
            else {
                NSNumber *result = [self.withingsWeightVals objectAtIndex:index];
                NSLog(@"y %@", result);
                return  result;
            
            }
            
            /*            }
             
             
             } else {
             return nil;
             }*/
            
        }
        else if ([plot.identifier isEqual:@"Mood Plot"])
        {
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

        else if ([plot.identifier isEqual:@"Manual Weight Plot"])
        {
            if ([self.manualWeightFetchedResultsController.fetchedObjects count] > index) {
                if([[defaults objectForKey:@"unit"] isEqual:@"kg"]) {
                    NSNumber *initResult = ((Weight*)[self.manualWeightFetchedResultsController.fetchedObjects objectAtIndex:index]).weight;
                    float floatResult = [initResult floatValue] * 0.453592;
                    result = @(floatResult);
                    NSLog(@"x %@", result);
                    return result;
                }
                else {
                    NSNumber *result = ((Weight*)[self.manualWeightFetchedResultsController.fetchedObjects objectAtIndex:index]).weight;
                    NSLog(@"y %@", result);
                    return  result;
                }
                
                
            } else {
                return nil;
            }
            
        }
        
        
        
    }
    return result;
    
}


@end
