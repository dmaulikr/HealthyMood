//
//  StepsTableViewController.m
//  HealthyMood
//
//  Created by Nadine Khattak on 11/19/15.
//  Copyright © 2015 Ensach. All rights reserved.
//

#import "StepsTableViewController.h"


@interface StepsTableViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *samplesArray;
@property (nonatomic, strong) NSMutableArray *samplesDateArray;
@property (nonatomic, strong) NSArray *sortedArray;
@property (nonatomic, retain) HKHealthStore *healthStore;
@property (nonatomic, strong) NSString *stepsDate;

@end

@implementation StepsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HKHealthStore *healthStore = [[HKHealthStore alloc] init];
    self.samplesArray = [[NSMutableArray alloc] init];
    self.samplesDateArray = [[NSMutableArray alloc] init];
   
    
    // Read date of birth, biological sex and step count
    /*NSSet *readObjectTypes  = [NSSet setWithObjects:
                               [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth],
                               [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex],
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                               nil]; */
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSLog(@"calendar, %@", calendar);
    NSDateComponents *interval = [[NSDateComponents alloc] init];
        NSLog(@"interval, %@", interval);
    interval.day = 1;
    
    
    NSDateComponents *anchorComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday fromDate:[NSDate date]];
    
    NSLog(@"anchorComponents, %@", anchorComponents);
    
    
    NSInteger offset = (7 + anchorComponents.weekday - 2) % 7;
        NSLog(@"anchorComponents.weekday, %ld", (long)anchorComponents.weekday);
    NSLog(@"offset, %li", (long)offset);
    anchorComponents.day -= offset;
    anchorComponents.hour = 0;
    
    NSDate *anchorDate = [calendar dateFromComponents:anchorComponents];
    
    HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    
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
            abort();
        }
        
        NSDate *endDate = [NSDate date];
        NSDate *startDate = [calendar
                             dateByAddingUnit:NSCalendarUnitMonth
                             value:-3
                             toDate:endDate
                             options:0];
        
       
        
        [results enumerateStatisticsFromDate:startDate toDate:endDate withBlock:^(HKStatistics *result, BOOL *stop) {
            HKQuantity *quantity = result.sumQuantity;
            
            if (quantity) {
                
                NSDate *date = result.startDate;
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                

                
                self.stepsDate = [dateFormatter stringFromDate:date];
                
                NSLog(@"sample date, %@", self.stepsDate);
                
                
                double value = [quantity doubleValueForUnit:[HKUnit countUnit]];
                
                NSLog(@"double value %f", value);
                
                NSString *samplesString = [NSString stringWithFormat:@"%@", quantity];

                [self.samplesArray addObject:samplesString];
                
                [self.samplesDateArray addObject:self.stepsDate];
                
               
                
                NSLog(@"sample date, %@", self.samplesDateArray);
                          }
            
            
            [self.tableView reloadData];
        
         
        }];
        
        
    };
    
    
    
    query.statisticsUpdateHandler = ^(HKStatisticsCollectionQuery *query, HKStatistics *result, HKStatisticsCollection *results, NSError *error) {
        if (error) {
            // Perform proper error handling here
            NSLog(@"*** An error occurred while calculating the statistics: %@ ***",
                  error.localizedDescription);
            abort();
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
        
    };
    
    
    
    [healthStore executeQuery:query];
 
    };



    
    
    
/*    NSDate *startDate, *endDate;
    
    // Use the sample type for step count
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
    
    // Create a sort descriptor for sorting by start date
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:YES];
    
    
    HKSampleQuery *sampleQuery = [[HKSampleQuery alloc] initWithSampleType:sampleType
                                                                 predicate:predicate
                                                                     limit:HKObjectQueryNoLimit
                                                           sortDescriptors:@[sortDescriptor]
                                                            resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
                                                                
                                                                if(!error && results)
                                                                {
                                                                    for(HKQuantitySample *samples in results)
                                                                    {
                                                                        HKQuantity *stepsDouble = samples.quantity;
                                                                        NSDate *startDateInit = samples.startDate;
                                                                        
                                                                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                                                        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                                                                        
                                                                        self.weightDate = [dateFormatter stringFromDate:startDateInit];

                                                                        NSLog(@"sample date, %@", self.weightDate);
                                                                        
                                                                        double value = [stepsDouble doubleValueForUnit:[HKUnit countUnit]];
                                                                        
                                                                        NSLog(@"double value %f", value);
                                                                        
                                                                        NSString *samplesString = [NSString stringWithFormat:@"%@", stepsDouble];

                                                                        [self.samplesArray addObject:samplesString];
                                                                        
                                                                        [self.samplesDateArray addObject:self.weightDate];
                                                                        
                                                                        NSLog(@"sample date, %@", self.samplesDateArray);
                                                                    
                                                                    }
                                                                    [self.tableView reloadData];                                                                    
                                                                }

                                                                
                                                            }];
    
    // Execute the query
    [healthStore executeQuery:sampleQuery];
*/



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    NSLog(@"samples count,%lu", (unsigned long)[self.samplesArray count]);

    return [self.samplesArray count];


}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *reversedArray = [[self.samplesArray reverseObjectEnumerator] allObjects];
    NSArray *reversedArrayDate = [[self.samplesDateArray reverseObjectEnumerator] allObjects];
    
       UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Steps Data" forIndexPath:indexPath];

    
    cell.textLabel.text = [reversedArray objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [reversedArrayDate objectAtIndex:indexPath.row];

    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
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
