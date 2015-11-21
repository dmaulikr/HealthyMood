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
    
    self.autoWeightEntrySelection.textLabel.text = @"Use Withings Scale Weight";
    self.manualWeightEntrySelection.textLabel.text = @"Enter My Own Weight";
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/
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
