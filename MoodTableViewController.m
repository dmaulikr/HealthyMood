//
//  MoodTableViewController.m
//  HealthyMood
//
//  Created by Nadine Khattak on 12/3/15.
//  Copyright © 2015 Ensach. All rights reserved.
//

#import "MoodTableViewController.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "Mood.h"

@interface MoodTableViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;


@end

@implementation MoodTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = delegate.managedObjectContext;
    
   /* NSManagedObject *moodInfo = [NSEntityDescription
                                       insertNewObjectForEntityForName:@"Mood"
                                       inManagedObjectContext:self.managedObjectContext];
    [moodInfo setValue:@"Test" forKey:@"mood"];
    NSManagedObject *moodDate = [NSEntityDescription
                                          insertNewObjectForEntityForName:@"Mood"
                                          inManagedObjectContext:self.managedObjectContext];
    [moodDate setValue:[NSDate date] forKey:@"moodDate"];
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Mood" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
   // [record setValue:@"Very Happy" forKey:@"mood"];
    
            NSLog(@"Mood: %@", [fetchedObjects valueForKey:@"mood"]);
            NSLog(@"Mood: %@", [fetchedObjects valueForKey:@"moodDate"]);
    
/*    for (NSManagedObject *info in fetchedObjects) {
        NSLog(@"Mood: %@", [info valueForKey:@"mood"]);
        //NSManagedObject *moodDate = [info valueForKey:@"moodDate"];
        //NSLog(@"Date: %@", [moodDate valueForKey:@"moodDate"]);
    }*/
    
    
   /* NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Mood"];

    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"moodDate" ascending:NO]]];

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
*/

    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(saveMood)];
    self.navigationItem.rightBarButtonItem = barButton;

    
    
    self.happiest.textLabel.text = @"Very happy";
    self.happy.textLabel.text = @"Happy";
    self.okay.textLabel.text = @"Okay";
    self.sad.textLabel.text = @"Sad";
    self.saddest.textLabel.text = @"Very Sad";
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 5;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    self.happiest.accessoryType = UITableViewCellAccessoryNone;
    self.happy.accessoryType = UITableViewCellAccessoryNone;
	self.okay.accessoryType = UITableViewCellAccessoryNone;
	self.sad.accessoryType = UITableViewCellAccessoryNone;
    self.saddest.accessoryType = UITableViewCellAccessoryNone;
    
    if (cell.accessoryType == UITableViewCellAccessoryNone)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
    
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Fetch Record
  //  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Mood" inManagedObjectContext:self.managedObjectContext];
    
//    NSManagedObject *record = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];

    
    UITableViewCell *happiestSel = self.happiest;
    UITableViewCell *happySel = self.happy;
    UITableViewCell *okaySel = self.okay;
    UITableViewCell *sadSel = self.sad;
    UITableViewCell *saddestSel = self.saddest;
    
    if (happiestSel.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        happySel.accessoryType = UITableViewCellAccessoryNone;
        okaySel.accessoryType = UITableViewCellAccessoryNone;
        sadSel.accessoryType = UITableViewCellAccessoryNone;
        saddestSel.accessoryType = UITableViewCellAccessoryNone;
    //    [record setValue:@"Very Happy" forKey:@"mood"];
    }
    else if (happySel.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        happiestSel.accessoryType = UITableViewCellAccessoryNone;
        okaySel.accessoryType = UITableViewCellAccessoryNone;
        sadSel.accessoryType = UITableViewCellAccessoryNone;
        saddestSel.accessoryType = UITableViewCellAccessoryNone;

    }
    else if (okaySel.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        happiestSel.accessoryType = UITableViewCellAccessoryNone;
        happySel.accessoryType = UITableViewCellAccessoryNone;
        sadSel.accessoryType = UITableViewCellAccessoryNone;
        saddestSel.accessoryType = UITableViewCellAccessoryNone;
    }
    else if (sadSel.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        happiestSel.accessoryType = UITableViewCellAccessoryNone;
        happySel.accessoryType = UITableViewCellAccessoryNone;
        okaySel.accessoryType = UITableViewCellAccessoryNone;
        saddestSel.accessoryType = UITableViewCellAccessoryNone;
    }
    else if (saddestSel.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        happiestSel.accessoryType = UITableViewCellAccessoryNone;
        happySel.accessoryType = UITableViewCellAccessoryNone;
        okaySel.accessoryType = UITableViewCellAccessoryNone;
        sadSel.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    /*
    if ([[defaults objectForKey:@"unit"]  isEqual: @"kg"]) {
        kg.accessoryType = UITableViewCellAccessoryCheckmark;
        lb.accessoryType = UITableViewCellAccessoryNone;
        st.accessoryType = UITableViewCellAccessoryNone;
    }
    else if ([[defaults objectForKey:@"unit"]  isEqual: @"st"]) {
        st.accessoryType = UITableViewCellAccessoryCheckmark;
        kg.accessoryType = UITableViewCellAccessoryNone;
        lb.accessoryType = UITableViewCellAccessoryNone;
    }
    else if ([[defaults objectForKey:@"unit"]  isEqual: @"lb"])  {
        lb.accessoryType = UITableViewCellAccessoryCheckmark;
        kg.accessoryType = UITableViewCellAccessoryNone;
        st.accessoryType = UITableViewCellAccessoryNone;
    }
     */
}


-(void)saveMood {
    NSLog(@"save mood entry");
    
    //Create Entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Mood" inManagedObjectContext:self.managedObjectContext];

    NSManagedObject *record = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    
/*    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity]; */
    
        NSError *error;
    
   // NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    
    if (self.happiest.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        [record setValue:@"Very Happy" forKey:@"mood"];
        [record setValue:[NSDate date] forKey:@"moodDate"];
     
    }
    else if (self.happy.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        [record setValue:@"Happy" forKey:@"mood"];
        [record setValue:[NSDate date] forKey:@"moodDate"];
     
        
    }
    else if (self.okay.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        [record setValue:@"Okay" forKey:@"mood"];
        [record setValue:[NSDate date] forKey:@"moodDate"];

    }
    else if (self.sad.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        [record setValue:@"Sad" forKey:@"mood"];
        [record setValue:[NSDate date] forKey:@"moodDate"];

    }
    else if (self.saddest.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        [record setValue:@"Very Sad" forKey:@"mood"];
        [record setValue:[NSDate date] forKey:@"moodDate"];

        
    }
    
    
    if ([self.managedObjectContext save:&error]) {
        // Dismiss View Controller
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        if (error) {
            NSLog(@"Unable to save record.");
            NSLog(@"%@, %@", error, error.localizedDescription);
        }
        
        // Show Alert View
        [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Your to-do could not be saved." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
}








/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do n    ot want the specified item to be editable.
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
