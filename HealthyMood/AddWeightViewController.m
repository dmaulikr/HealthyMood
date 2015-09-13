//
//  AddWeightViewController.m
//  HealthyMood
//
//  Created by Nadine Khattak on 9/5/15.
//  Copyright (c) 2015 Ensach. All rights reserved.
//

#import "AddWeightViewController.h"
#import "Weight.h"

@interface AddWeightViewController () 


@end

@implementation AddWeightViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([[defaults objectForKey:@"unit"] isEqual:@"lb"]) {
        self.unitLabel.text = @"lb";
    } else if([[defaults objectForKey:@"unit"] isEqual:@"kg"]) {
        self.unitLabel.text = @"kg";
    } else if([[defaults objectForKey:@"unit"] isEqual:@"st"]) {
        self.unitLabel.text = @"st";
    }
    // Configure the navigation bar
}


- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    NSString *weightText = self.textField.text;
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *weightNumber = [f numberFromString:weightText];

    
    if (weightText && weightText.length) {
        //Create Entity
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Weight" inManagedObjectContext:self.managedObjectContext];
        
        //Initialize Record
        NSManagedObject *record = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
        
        //Populate Recrod
        [record setValue:weightNumber forKey:@"weight"];
        [record setValue:[NSDate date] forKey:@"weightDate"];

        
        //Save Record
        NSError *error = nil;
        
        if ([self.managedObjectContext save:&error]) {
            //Dismiss View Controller
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            if (error) {
                NSLog(@"Unable to save record");
                NSLog(@"%@, %@", error, error.localizedDescription);
            }
            
            //Show Alert View
            [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Your to-do could not be saved." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
    } else {
        // Show Alert View
        [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Your to-do needs a name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


@end
