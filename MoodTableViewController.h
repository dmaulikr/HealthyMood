//
//  MoodTableViewController.h
//  HealthyMood
//
//  Created by Nadine Khattak on 12/3/15.
//  Copyright © 2015 Ensach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface MoodTableViewController : UITableViewController <UITableViewDataSource,UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *happiest;
@property (weak, nonatomic) IBOutlet UITableViewCell *happy;
@property (weak, nonatomic) IBOutlet UITableViewCell *okay;
@property (weak, nonatomic) IBOutlet UITableViewCell *sad;
@property (weak, nonatomic) IBOutlet UITableViewCell *saddest;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
