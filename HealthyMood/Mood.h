//
//  Mood.h
//  HealthyMood
//
//  Created by Nadine Khattak on 12/3/15.
//  Copyright © 2015 Ensach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>



@interface Mood : NSManagedObject

@property (nonatomic, retain) NSString *mood;
@property (nonatomic, retain) NSDate *moodDate;


@end

