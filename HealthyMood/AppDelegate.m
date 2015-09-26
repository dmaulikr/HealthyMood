//
//  AppDelegate.m
//  HealthyMood
//
//  Created by Nadine Khattak on 9/5/15.
//  Copyright (c) 2015 Ensach. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "WeightTableViewController.h"




@interface AppDelegate ()

@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
//@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
   /*
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    // Instantiate Root Navigation Controller
   UINavigationController *rootNavigationController = (UINavigationController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"rootNavigationController"];
    
    // Configure View Controller
    WeightTableViewController *viewController = (WeightTableViewController *)[rootNavigationController topViewController];
    
    if ([viewController isKindOfClass:[WeightTableViewController class]]) {
        [viewController setManagedObjectContext:self.managedObjectContext];
    }
    
    // Configure Window
    [self.window setRootViewController:rootNavigationController];
    */
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSError *error;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Weight"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];

    

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"unit" ] isEqual:nil])
    {
    [defaults setObject:@"lb" forKey:@"unit"];
    }

    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Save Managed Object Context
    [self saveManagedObjectContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Save Managed Object Context
    [self saveManagedObjectContext];
    
    /*
     NSError *error = nil;
     
     if (![self.managedObjectContext save:&error]) {
     if (error) {
     NSLog(@"Unable to save changes.");
     NSLog(@"%@, %@", error, error.localizedDescription);
     }
     }
     */
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}
/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

/**
 Returns the URL to the application's documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"Weight.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                            NSInferMappingModelAutomaticallyOption: @YES
                            };
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (void)saveManagedObjectContext {
    NSError *error = nil;
    
    if (![self.managedObjectContext save:&error]) {
        if (error) {
            NSLog(@"Unable to save changes.");
            NSLog(@"%@, %@", error, error.localizedDescription);
        }
    }
}


@end
