//
//  Weight.m
//  HealthyMood
//
//  Created by Nadine Khattak on 9/16/15.
//  Copyright (c) 2015 Ensach. All rights reserved.
//

#import "Weight.h"

@interface Weight ()
    @property (nonatomic) NSDate *primitiveTimeStamp;
    @property (nonatomic) NSString *primitiveSectionIdentifier;



@end

@implementation Weight

@dynamic weight;
@dynamic weightDate;
@dynamic sectionIdentifier;
@dynamic primitiveSectionIdentifier;
@dynamic primitiveTimeStamp;

#pragma mark - Transient properties

- (NSString *)sectionIdentifier
{
    // Create and cache the section identifier on demand.
    
    [self willAccessValueForKey:@"sectionIdentifier"];
    NSString *tmp = [self primitiveSectionIdentifier];
    [self didAccessValueForKey:@"sectionIdentifier"];
    
    if (!tmp)
    {
        /*
         Sections are organized by month and year. Create the section identifier as a string representing the number (year * 1000) + month; this way they will be correctly ordered chronologically regardless of the actual name of the month.
         */
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:[self weightDate]];
        tmp = [NSString stringWithFormat:@"%ld", ([components year] * 1000) + [components month]];
        [self setPrimitiveSectionIdentifier:tmp];
    }
    return tmp;
}

/*

- (void)setWeightDate:(NSDate *)newDate
{
    // If the time stamp changes, the section identifier become invalid.
    [self willChangeValueForKey:@"weightDate"];
    [self setPrimitiveTimeStamp:newDate];
    [self didChangeValueForKey:@"weightDate"];
    
    [self setPrimitiveSectionIdentifier:nil];
}

*/

#pragma mark - Key path dependencies

+ (NSSet *)keyPathsForValuesAffectingSectionIdentifier
{
    // If the value of timeStamp changes, the section identifier may change as well.
    return [NSSet setWithObject:@"weightDate"];
}

@end
