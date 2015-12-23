//
//  AddWeightViewController.m
//  HealthyMood
//
//  Created by Nadine Khattak on 9/5/15.
//  Copyright (c) 2015 Ensach. All rights reserved.
//

#import "AddWeightViewController.h"
#import "Weight.h"
#import "AppDelegate.h"


@interface AddWeightViewController () 


@end

@implementation AddWeightViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor =[UIColor colorWithRed:244.0/255.0 green:158.0/255.0 blue:255.0/255.0 alpha:1.0f];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([[defaults objectForKey:@"unit"] isEqual:@"lb"]) {
        self.title = @"Enter Weight (lb)";
    }
    else if ([[defaults objectForKey:@"unit"] isEqual:@"kg"]) {
        self.title = @"Enter Weight (kg)";
    }

    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = delegate.managedObjectContext;

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
    f.generatesDecimalNumbers = YES;
    f.maximumFractionDigits = 2;
    
    NSNumber *weightNumber = [f numberFromString:weightText];
    
    
    if (weightText && weightText.length) {
        //Create Entity
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Weight" inManagedObjectContext:self.managedObjectContext];
        
        //Initialize Record
        NSManagedObject *record = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
        
        //Populate Record
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        double weightEnteredDouble;
        double weightLbConvDouble =[weightNumber doubleValue];
        
        if ([[defaults objectForKey:@"unit"]  isEqual: @"kg"])  {
            weightEnteredDouble = weightLbConvDouble * 2.20;
            NSNumber *weightEnteredBlah = [NSNumber numberWithDouble:weightEnteredDouble];
            [record setValue:weightEnteredBlah forKey:@"weight"];
        } else {
            [record setValue:weightNumber forKey:@"weight"];
        }
        
        [record setValue:[NSDate date] forKey:@"weightDate"];
        
        //Save Record
        NSError *error = nil;
        
        if ([self.managedObjectContext save:&error]) {
            //Dismiss View Controller
           // [self dismissViewControllerAnimated:YES completion:nil];
            [self.navigationController popViewControllerAnimated:YES];
            
        } else {
            if (error) {
                NSLog(@"Unable to save record");
                NSLog(@"%@, %@", error, error.localizedDescription);
            }
            
            //Show Alert View
            [UIAlertController alertControllerWithTitle:@"Warning" message:@"Your weight entry could not be saved." preferredStyle:UIAlertControllerStyleAlert];
        }
        
    } else {
        // Show Alert View
        [UIAlertController alertControllerWithTitle:@"Warning" message:@"You didn't enter a weight to save to your records." preferredStyle:UIAlertControllerStyleAlert];
    }
    

}


@end
