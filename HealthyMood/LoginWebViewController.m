//
//  LoginWebViewController.m
//  Simple-OAuth1
//
//  Created by Christian Hansen on 02/12/12.
//  Copyright (c) 2012 Christian-Hansen. All rights reserved.
//

#import "LoginWebViewController.h"
#import "WithingsSelectionTableViewController.h"

@interface LoginWebViewController ()

@end

@implementation LoginWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    WithingsSelectionTableViewController *withingsSelection = [[WithingsSelectionTableViewController alloc] init];
   
        [self presentViewController:withingsSelection animated:YES completion:nil];
    
     }
 
 */

- (IBAction)cancelTapped:(id)sender
{

    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

