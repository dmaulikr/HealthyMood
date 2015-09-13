//
//  SettingsTableViewController.m
//  HealthyMood
//
//  Created by Nadine Khattak on 9/10/15.
//  Copyright (c) 2015 Ensach. All rights reserved.
//

#import "SettingsTableViewController.h"
#import <CoreData/CoreData.h>
#import "Weight.h"
#import "AppDelegate.h"


@interface SettingsTableViewController ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;



@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.kgCell.textLabel.text = @"kg";
    self.lbCell.textLabel.text = @"lb";
    self.stCell.textLabel.text = @"st";
    
    _selectedIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    
    //Initialize Fetch Request
    // Initialize Fetch Request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Weight"];
    
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"unit" ascending:NO]]];
    
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* context = appDelegate.managedObjectContext;


    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];

    // Configure Fetched Results Controller

    
    // Perform Fetch
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    
    if (error) {
        NSLog(@"Unable to perform fetch.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }


    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 3;
}
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    self.selectedIndexPath = indexPath;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                NSString *unit = cell.textLabel.text;
    

    if (cell.accessoryType == UITableViewCellAccessoryNone)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
            NSLog(@"text, %@", unit);
        
    } else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }


    

}



-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}


- (IBAction)save:(id)sender {
/*    if cell has accessory mark checkmark, set the unit attribute to the text of the cell
 */
    UITableViewCell *kg = self.kgCell;
    NSString *kgText = kg.textLabel.text;

    UITableViewCell *lb = self.lbCell;
    NSString *lbText = lb.textLabel.text;
   
    UITableViewCell *st = self.stCell;
    NSString *stText = st.textLabel.text;

    //Create Entity
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* context = appDelegate.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Weight" inManagedObjectContext:context];
    
    NSManagedObject *record = [[NSManagedObject alloc]initWithEntity:entity insertIntoManagedObjectContext:context];
    
    if (kg.accessoryType == UITableViewCellAccessoryCheckmark) {
        
        NSLog(@"hi kg");
        [record setValue:kgText forKey:@"unit"];
        NSLog(@"%@", record);
    }
    
    else if (lb.accessoryType == UITableViewCellAccessoryCheckmark) {
        NSLog(@"hi lb");
        [record setValue:lbText forKey:@"unit"];
        NSLog(@"%@", record);
        
    } else if (st.accessoryType == UITableViewCellAccessoryCheckmark) {
        NSLog(@"hi st");
        [record setValue:stText forKey:@"unit"];
        NSLog(@"%@", record);
        
    }

    //Save Record
    NSError *error = nil;
    
    if ([context save:&error]) {
        //Dismiss View Controller
        [self dismissViewControllerAnimated:YES completion:nil];
        NSLog (@"%@", self);
    } else {
        if (error) {
            NSLog(@"Unable to save record");
            NSLog(@"%@, %@", error, error.localizedDescription);
        }
        
        //Show Alert View
        [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Your to-do could not be saved." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }


}





/*
- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    



    NSLog (@"hi");

  
}
 */


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Fetch Record
    
    UITableViewCell *kg = self.kgCell;
    UITableViewCell *lb = self.lbCell;
    UITableViewCell *st = self.stCell;
    
    if ([[self.fetchedResultsController fetchedObjects] count] > 0 && [[self.fetchedResultsController fetchedObjects] count]  < 3) {
        NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        
        
        if ([[record valueForKey:@"unit"] isEqual: @"lb"])
        {
            lb.accessoryType = UITableViewCellAccessoryCheckmark;
            kg.accessoryType = UITableViewCellAccessoryNone;
            st.accessoryType = UITableViewCellAccessoryNone;
        }
        else if ([[record valueForKey:@"unit"] isEqual: @"kg"])
        {
            kg.accessoryType = UITableViewCellAccessoryCheckmark;
            lb.accessoryType = UITableViewCellAccessoryNone;
            st.accessoryType = UITableViewCellAccessoryNone;
        }
        else
        {
            st.accessoryType = UITableViewCellAccessoryCheckmark;
            lb.accessoryType = UITableViewCellAccessoryNone;
            kg.accessoryType = UITableViewCellAccessoryNone;
        }
        
    } else {
        lb.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
