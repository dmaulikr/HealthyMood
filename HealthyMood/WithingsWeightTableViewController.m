//
//  WithingsWeightTableViewController.m
//  HealthyMood
//
//  Created by Nadine Khattak on 11/9/15.
//  Copyright © 2015 Ensach. All rights reserved.
//

#import "WithingsWeightTableViewController.h"

#import "OAuth1Controller.h"
#import "WeighEntryTypeTableViewController.h"
#import "WithingsWeightTableViewCell.h"

@interface WithingsWeightTableViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) OAuth1Controller *oauth1Controller;
@property (nonatomic, strong) NSString *oauthToken;
@property (nonatomic, strong) NSString *oauthTokenSecret;
@property (nonatomic, strong) NSString *weightMeas;
@property (nonatomic, strong) NSString *weightDate;
@property (nonatomic, strong) NSMutableArray *vals;
@property (nonatomic, strong) NSMutableArray *dateVals;



@end

@implementation WithingsWeightTableViewController

@synthesize vals;

- (void)viewDidLoad {
    NSLog(@"table view loaded");
    
    
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *oauthToken = [ defaults objectForKey:@"oauthToken"];
    NSString *oauthTokenSecret = [ defaults objectForKey:@"oauthTokenSecret"];
    NSString *userid = [defaults objectForKey:@"userid"];
    
    NSLog(@"userid, %@", userid);
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSError *error;
    
    self.vals = [[NSMutableArray alloc] init];
    self.weightMeas = [[NSString alloc] init];
    
    self.dateVals = [[NSMutableArray alloc] init];
    self.weightDate   = [[NSString alloc] init];
    
    [dict setObject:@"getmeas" forKey:@"action"];
    
    [dict setObject:@"1" forKey:@"category"];
    
    NSURLRequest *request =
    [OAuth1Controller preparedRequestForPath:@"measure"
                                  parameters:dict
                                  HTTPmethod:@"GET"
                                  oauthToken:oauthToken
                                 oauthSecret:oauthTokenSecret];
    
    
    
    NSLog(@"RRRRR %@",request.URL);
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil)
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
                             
                             self.weightDate = [dateFormatter stringFromDate:epochNSDate];
                             
                             
                             
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
                 [self.tableView reloadData];
                 
                 
             });
             
             
         }
     }];
    
}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *vals = [[NSMutableArray alloc] init];
    NSLog(@"vals count, %lu", (unsigned long)[self.vals count]);
    return [self.vals count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"Table Cell";
    WithingsWeightTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier forIndexPath:indexPath];
    
    int row = [indexPath row];
    if (cell == nil) {
        cell = [[WithingsWeightTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Table Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.weightDateLabel.text = [self.vals objectAtIndex:indexPath.row];
    cell.weightLabel.text = [self.dateVals objectAtIndex:indexPath.row];
    
        NSLog(@"asdfasdf,%@",[self.dateVals objectAtIndex:indexPath.row]);
    cell.textLabel.text = [self.vals objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [self.dateVals objectAtIndex:indexPath.row];
   
   // self.weightDateLabel.text =[self.dateVals objectAtIndex:row];
    
    NSLog(@"cell.detailTextLabel.text, %@", [self.dateVals objectAtIndex:indexPath.row]);

    
  //  NSLog(@"cell.detailTextLabel.text, %@", cell.detailTextLabel.text);
return cell;
}





@end
