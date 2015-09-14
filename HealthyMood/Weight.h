//
//  Weight.h
//  HealthyMood
//
//  Created by Nadine Khattak on 9/13/15.
//  Copyright (c) 2015 Ensach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Weight : NSManagedObject

@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSDate * weightDate;

@end
