//
//  SelectWeightSourceOptionTableViewController.m
//  HealthyMood
//
//  Created by Nadine Khattak on 12/12/15.
//  Copyright © 2015 Ensach. All rights reserved.
//

#import "SelectWeightSourceOptionTableViewController.h"

@interface SelectWeightSourceOptionTableViewController ()

@end

@implementation SelectWeightSourceOptionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.chooseWeightSource.textLabel.text =@"Choose Weight Source";
    self.viewWeightFirst.textLabel.text =@"View Weight Data";
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

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 2;
}

/*
-(IBAction)weightVCType:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Test Message"
                                                    message:@"This is a test"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];

    if ([[defaults objectForKey:@"weightEntryType"]  isEqual: @"autoWithings"]) {
        [self performSegueWithIdentifier:@"withingsView" sender:self];
    }
    else if ([[defaults objectForKey:@"weightEntryType"]  isEqual: @"manualWeightEntry"]) {
        [self performSegueWithIdentifier:@"withingsView" sender:self];
    }
    else if ([defaults objectForKey:@"weightEntryType"]  == nil) {
        [alert show];
    }

    
    
    
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{


    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Test Message"
                                                    message:@"This is a test"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if([cell.reuseIdentifier isEqualToString:@"viewWeightID"])
    {
        if ([[defaults objectForKey:@"weightEntryType"]  isEqual: @"autoWithings"])
        {
            [self performSegueWithIdentifier:@"withingsView" sender:self];
        }
        else if ([[defaults objectForKey:@"weightEntryType"]  isEqual: @"manualWeightEntry"])
        {
            [self performSegueWithIdentifier:@"manualWeightView" sender:self];
        }
        else if ([defaults objectForKey:@"weightEntryType"]  == nil) {
            [alert show];
        }


    }
    
    
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSIndexPath *myIP = [NSIndexPath indexPathForRow:0 inSection:0];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chooseWeightID" forIndexPath:myIP];
    
    // Configure the cell...
    
    return cell;
}

*/
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    
    if ([[defaults objectForKey:@"weightEntryType"]  isEqual: @"autoWithings"]) {
        
 
}
*/

@end
