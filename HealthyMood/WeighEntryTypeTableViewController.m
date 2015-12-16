//
//  WeighEntryTypeTableViewController.m
//  HealthyMood
//
//  Created by Nadine Khattak on 11/9/15.
//  Copyright © 2015 Ensach. All rights reserved.
//

#import "WeighEntryTypeTableViewController.h"
#import "OAuth1Controller.h"
#import "LoginWebViewController.h"
#import "WithingsWeightTableViewController.h"

@interface WeighEntryTypeTableViewController ()

@property (nonatomic, strong) OAuth1Controller *oauth1Controller;
@property (nonatomic, strong) NSString *oauthToken;
@property (nonatomic, strong) NSString *oauthTokenSecret;
@end

@implementation WeighEntryTypeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *authSettings = [NSUserDefaults standardUserDefaults];
     if([authSettings boolForKey:@"authSwitchStatus"])
     {
         [self.authSwitch isOn];
     }
    self.autoWeightEntrySelection.textLabel.text = @"Use Withings Scale Weight";
    self.manualWeightCell.textLabel.text = @"Enter My Own Weight";

    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    

    /*
    
     

    if ([[defaults objectForKey:@"weightEntryType"]  isEqual: @"autoWithings"])
    {
        self.autoWeightEntrySelection.accessoryType = UITableViewCellAccessoryCheckmark;
        self.manualWeightEntrySelection.accessoryType = UITableViewCellAccessoryNone;
        
    }
    else if ([[defaults objectForKey:@"weightEntryType"]  isEqual: @"manualWeightEntry"] )
    {
        self.manualWeightEntrySelection.accessoryType = UITableViewCellAccessoryCheckmark;
        self.autoWeightEntrySelection.accessoryType = UITableViewCellAccessoryNone;
    }
*/

    self.autoWeightEntrySelection.accessoryType = UITableViewCellAccessoryNone;
    self.manualWeightCell.accessoryType = UITableViewCellAccessoryCheckmark;
    NSLog(@"default weight type,%@", [defaults objectForKey:@"weightEntryType"]);

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 2;


}


- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.autoWeightEntrySelection.accessoryType = UITableViewCellAccessoryNone;
    self.manualWeightCell.accessoryType = UITableViewCellAccessoryNone;

    
    if (cell.accessoryType == UITableViewCellAccessoryNone)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (self.autoWeightEntrySelection.accessoryType == UITableViewCellAccessoryCheckmark) {
        [defaults setObject:@"autoWithings" forKey:@"weightEntryType"];
    } else if (self.manualWeightCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        [defaults setObject:@"manualWeightEntry" forKey:@"weightEntryType"];
    }
    
   
    
}


/*

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.autoWeightEntrySelection.accessoryType = UITableViewCellAccessoryNone;
    self.manualWeightEntrySelection = UITableViewCellAccessoryNone;

    
    if (cell.accessoryType == UITableViewCellAccessoryNone)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (self.autoWeightEntrySelection.accessoryType == UITableViewCellAccessoryCheckmark) {
        [defaults setObject:@"autoWithings" forKey:@"weightEntryType"];
    } else if (self.manualWeightEntrySelection.accessoryType == UITableViewCellAccessoryCheckmark) {
        [defaults setObject:@"manualWeightEntry" forKey:@"weightEntryType"];
    }
    
    
}

 
 */

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

    UITableViewCell *autoWeight = self.autoWeightEntrySelection;
    UITableViewCell *manualWeight = self.manualWeightCell;

                                 
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                 
    if ([[defaults objectForKey:@"weightEntryType"]  isEqual: @"autoWithings"]) {
        autoWeight.accessoryType = UITableViewCellAccessoryCheckmark;
        manualWeight.accessoryType = UITableViewCellAccessoryNone;
    }
    else if ([[defaults objectForKey:@"weightEntryType"]  isEqual: @"manualWeightEntry"]) {
        manualWeight.accessoryType = UITableViewCellAccessoryCheckmark;
        autoWeight.accessoryType = UITableViewCellAccessoryNone;
    }
}
                             
                             

- (IBAction)buttonTapped {
    LoginWebViewController *loginWebViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginWebViewController"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    
    
    [self presentViewController:loginWebViewController
                       animated:YES
                     completion:^{
                         
                         [self.oauth1Controller loginWithWebView:loginWebViewController.webView completion:^(NSDictionary *oauthTokens, NSError *error) {
                             
                             if (!error) {
                                 
                                 // Store your tokens for authenticating your later requests, consider storing the tokens in the Keychain
                                 NSLog(@"self.oauthToken=%@,self.oauthTokenSecret",oauthTokens);
                                 
                                 
                                 
                                 [defaults setObject:oauthTokens[@"oauth_token"] forKey:@"oauthToken"];
                                 [defaults setObject:oauthTokens[@"oauth_token_secret"] forKey:@"oauthTokenSecret"   ];
                                 [defaults setObject:oauthTokens[@"userid"] forKey:@"userid"]   ;
                                 
                                 
                                 
                                 self.accessTokenLabel.text = self.oauthToken;
                                 self.accessTokenSecretLabel.text = self.oauthTokenSecret;
                                 
                                 
                             }
                             else
                             {
                                 NSLog(@"Error authenticating: %@", error.localizedDescription);
                             }
                             [self dismissViewControllerAnimated:YES completion: ^{
                                 self.oauth1Controller = nil;
                             }];
                         }];
                     }];


}

- (IBAction)logoutTapped
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *oauthTokens;
    // Clear cookies so no session cookies can be used for the UIWebview
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        if (cookie.isSecure) {
            [storage deleteCookie:cookie];
        }
    }
    
    // Clear tokens from instance variables
    self.oauthToken = nil;
    self.oauthTokenSecret = nil;
    
    // Clear textfields
    self.accessTokenLabel.text = self.oauthToken;
    self.accessTokenSecretLabel.text = self.oauthTokenSecret;
    self.responseTextView.text = nil;
    
    [defaults setObject:oauthTokens[@"oauth_token"] forKey:@"oauthToken"];
    [defaults setObject:oauthTokens[@"oauth_token_secret"] forKey:@"oauthTokenSecret"   ];
    NSLog(@"logout tapped");
}

/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.


}

 */
- (OAuth1Controller *)oauth1Controller
{
    if (_oauth1Controller == nil) {
        _oauth1Controller = [[OAuth1Controller alloc] init];
    }
    return _oauth1Controller;
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation



@end
