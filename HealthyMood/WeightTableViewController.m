//
//  WeightTableViewController.m
//  HealthyMood
//
//  Created by Nadine Khattak on 9/5/15.
//  Copyright (c) 2015 Ensach. All rights reserved.
//

#import "WeightTableViewController.h"
#import <CoreData/CoreData.h>
#import "WeightTableViewCell.h"
#import "Weight.h"
#import "AddWeightViewController.h"
#import "SettingsTableViewController.h"


#import "Weight.h"

@interface WeightTableViewController ()



@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) NSIndexPath *selection;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property BOOL completed;

@end

@implementation WeightTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize Fetch Request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Weight"];
    
    // Add Sort Descriptors
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"weightDate" ascending:NO]]];
    
    // Initialize Fetched Results Controller
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    // Configure Fetched Results Controller
    [self.fetchedResultsController setDelegate:self];
    
    // Perform Fetch
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    
    if (error) {
        NSLog(@"Unable to perform fetch.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(handlePreferenceChange:) name:NSUserDefaultsDidChangeNotification object:nil];
    
   
}

- (void)handlePreferenceChange:(NSNotification *)note
{
    NSLog(@"received user defaults did change notification");

    [self.tableView reloadData];
    
    


}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addWeight"]) {
        // Obtain Reference to View Controller
        UINavigationController *nc = (UINavigationController *)[segue destinationViewController];
        AddWeightViewController *vc = (AddWeightViewController *)[nc topViewController];

        // Configure View Controller
        [vc setManagedObjectContext:self.managedObjectContext];
        

    }

 


}

#pragma mark Fetched Results Controller Delegate Methods
- (void)controllerWilLChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controllerDidChangeContent: (NSFetchedResultsController *) controller {
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self configureCell:(WeightTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

#pragma mark Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WeightTableViewCell *cell = (WeightTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"WeightListPrototypeCell" forIndexPath:indexPath];
    
    // Configure Table View Cell
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(WeightTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Fetch Record
    NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *weightRecord = [record valueForKey:@"weight"];
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    f.generatesDecimalNumbers = YES;
    f.maximumFractionDigits = 2;

    double weightRecordDouble = [weightRecord doubleValue];
    double weightRecordKgDisplay = weightRecordDouble * 0.453592;

    if([[defaults objectForKey:@"unit"] isEqual:@"kg"]) {
        
        [cell.nameLabel setText:[NSString stringWithFormat:@"%.01f", weightRecordKgDisplay]];
    } else {
        [cell.nameLabel setText:[f stringFromNumber:[record valueForKey:@"weight"]]];
    }
    
    
    
    //store:
    // if user chooses kg, change the record to be stored as pounds
    // set value of attribute to be kg entered times around 2s
    
    //display:
    //display the data as record value stored times kg conversion, around 0.2
    
    

    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSString *dateStr = [[record valueForKey:@"weightDate"] description];
    NSDate *date = [dateFormatter dateFromString:dateStr];
    [dateFormatter setDateFormat:@"dd/MM/yy"];

    NSDateFormatter *dateTimeFormatter = [[NSDateFormatter alloc] init];
    [dateTimeFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSString *dateTimeStr = [[record valueForKey:@"weightDate"] description];
    NSDate *dateTime = [dateTimeFormatter dateFromString:dateTimeStr];
    [dateTimeFormatter setDateFormat:@"HH:mm a"];

    // Update Cell
    
 //   [cell.nameLabel setText:[f stringFromNumber:[record valueForKey:@"weight"]]];
    cell.dateLabel.text = [dateFormatter stringFromDate:date];
    cell.timeLabel.text = [dateTimeFormatter stringFromDate:dateTime];

}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        if (record) {
            [self.fetchedResultsController.managedObjectContext deleteObject:record];
        }
    }
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Store Selection
    [self setSelection:indexPath];
    


}

@end


