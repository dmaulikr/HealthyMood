//
//  PrivacyStatmentViewController.m
//  HealthyMood
//
//  Created by Nadine Khattak on 12/24/15.
//  Copyright © 2015 Ensach. All rights reserved.
//

#import "PrivacyStatmentViewController.h"

@interface PrivacyStatmentViewController ()

@end

@implementation PrivacyStatmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *urlString = @"http://khasachi.com/healthyZen";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:urlRequest];

    self.webView.scalesPageToFit = YES;
    self.webView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
