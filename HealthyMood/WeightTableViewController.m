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
#import "AppDelegate.h"





@interface WeightTableViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSIndexPath *selection;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property BOOL completed;

@end

@implementation WeightTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = delegate.managedObjectContext;

    
    // Initialize Fetch Request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Weight"];
    // For debugging
    //[fetchRequest setReturnsObjectsAsFaults:NO];
    // Add Sort Descriptors
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"weightDate" ascending:NO]]];
    
    // Initialize Fetched Results Controller
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    // Configure Fetched Results Controller
    NSLog(@"Before fetch fetchRequests %@", self.fetchedResultsController.fetchedObjects);
    [self.fetchedResultsController setDelegate:self];
    
    
    // Perform Fetch
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    NSLog(@"After fetch fetchRequests %@", self.fetchedResultsController.fetchedObjects);
    
    
    
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




- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
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
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    NSInteger count = [sectionInfo numberOfObjects];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WeightTableViewCell *cell = (WeightTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"WeightListPrototypeCell" forIndexPath:indexPath];
    
    // Configure Table View Cell
    if (indexPath.row%2 == 0) {
        UIColor *altCellColor = [UIColor colorWithWhite:0.7 alpha:0.1];
        cell.backgroundColor = altCellColor;
    }
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
        
        cell.textLabel.text = [NSString stringWithFormat:@"%.01f", weightRecordKgDisplay];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"%.01f", weightRecordDouble];

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
    [dateFormatter setDateFormat:@"dd"];
    
    NSDateFormatter *dateTimeFormatter = [[NSDateFormatter alloc] init];
    [dateTimeFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];

    
    [dateTimeFormatter setDateFormat:@"yyyy-MM-dd 'at' hh:mm a"];
    
    //[cell.nameLabel setText:[f stringFromNumber:[record valueForKey:@"weight"]]];
    cell.detailTextLabel.text = [dateTimeFormatter stringFromDate:date];
   // cell.timeLabel.text = [dateTimeFormatter stringFromDate:dateTime];
    
    
}
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> theSection = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSLog (@"theSection, %@", theSection);
 
    // Section information derives from an event's sectionIdentifier, which is a string representing the number (year * 1000) + month.
    // To display the section title, convert the year and month components to a string representation.
 
    static NSDateFormatter *formatter = nil;
    
    if (!formatter)
    {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setCalendar:[NSCalendar currentCalendar]];
        
        NSString *formatTemplate = [NSDateFormatter dateFormatFromTemplate:@"MMMM YYYY" options:0 locale:[NSLocale currentLocale]];
        [formatter setDateFormat:formatTemplate];
    }
    
    NSInteger numericSection = [[theSection name] integerValue];
    NSLog (@"theSection names, %@", [theSection name]);
    NSInteger year = numericSection / 1000;
    NSLog (@"year, %li", (long)year);
    NSInteger month = numericSection - (year * 1000);
    NSLog (@"month, %li", (long)month);
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = year;
    dateComponents.month = month;
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    
    NSString *titleString = [formatter stringFromDate:date];
    
    return titleString;
}

*/

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.managedObjectContext deleteObject:record];
        [self.managedObjectContext save:nil];
        
    }
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Store Selection
    [self setSelection:indexPath];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(20, 8, 320, 20);
    myLabel.font = [UIFont boldSystemFontOfSize:18];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    
    return headerView;
}



@end


