//
//  MoodSelectionTableViewController.m
//  HealthyMood
//
//  Created by Nadine Khattak on 12/3/15.
//  Copyright © 2015 Ensach. All rights reserved.
//

#import "MoodSelectionTableViewController.h"

@interface MoodSelectionTableViewController ()

@end

@implementation MoodSelectionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.enterMood.textLabel.text = @"Select Mood";
    self.viewMoods.textLabel.text = @"Mood History";
    self.viewMoodGraphs.textLabel.text = @"Mood Graph";
    
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

    return 3;
}



@end
