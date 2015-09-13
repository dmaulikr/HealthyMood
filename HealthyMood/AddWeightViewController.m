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
    
    // Configure the navigation bar
}


- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    NSString *name = self.textField.text;
    

    
    if (name && name.length) {
        //Create Entity
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Weight" inManagedObjectContext:self.managedObjectContext];
        
        //Initialize Record
        NSManagedObject *record = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
        
        //Populate Recrod
        [record setValue:name forKey:@"weight"];
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
