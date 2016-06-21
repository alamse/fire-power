//
//  HealthkitManager.m
//  Fire Power
//
//  Created by Sense on 6/20/16.
//  Copyright © 2016 Sense. All rights reserved.
//

#import "HealthkitManager.h"
#import <HealthKit/HealthKit.h>

@interface HealthkitManager()

@property (nonatomic, retain) HKHealthStore *healthStore;

@end

@implementation HealthkitManager

+ (HealthkitManager*) sharedInstance {
    static HealthkitManager *instance = nil;
    instance = [[HealthkitManager alloc] init];
    instance.healthStore = [[HKHealthStore alloc] init];
    return instance;
}

- (void) requestAuthorizeHealthKit:(void (^)(BOOL success, NSError *error)) onCompleted{
    NSArray *healthKitTypeToRead = @[
                                     [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                                     [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning],
                                     [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate],
                                     [HKObjectType activitySummaryType],
                                     [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis],
                                     [HKObjectType workoutType]
                                     ];
    NSArray *healthKitTypeToWrite = @[
                                      [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                                      [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis],
                                      [HKQuantityType workoutType]
                                      ];
    
    
    
    if ([HKHealthStore isHealthDataAvailable] == NO) {
        NSError *err = [NSError errorWithDomain:@"com.demo.fire" code:2 userInfo:@{NSLocalizedDescriptionKey : @"Healthkit not available in this device"}];
        if (onCompleted != nil) {
            onCompleted(false, err);
        }
    }
    
    [_healthStore requestAuthorizationToShareTypes:[NSSet setWithArray:healthKitTypeToWrite] readTypes:[NSSet setWithArray:healthKitTypeToRead] completion:^(BOOL success, NSError *error) {
        if (onCompleted != nil) {
            onCompleted(success, error);
        }
    }];
    
}

- (void) getStepActive:(NSDate*) startDate endDate:(NSDate*) endDate withCompletion:(void (^)(float totalSecondActivity, NSInteger totalStepsCount, NSError *error)) onCompleted {
    HKSampleType *type = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSPredicate *stepPredicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    NSSortDescriptor *stepSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    
    HKSampleQuery *stepQuery = [[HKSampleQuery alloc] initWithSampleType:type predicate:stepPredicate limit:0 sortDescriptors:@[stepSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *hkSample, NSError *error){
        
        float totalTime = 0;
        NSInteger totalStep = 0;
        
        for (int i = 0; i < [hkSample count]; i++) {
            HKQuantitySample *sampleStep = [hkSample objectAtIndex:i];
            NSDate *startDate = [sampleStep startDate];
            NSDate *endDate = [sampleStep endDate];
            NSTimeInterval secondBetween = [endDate timeIntervalSinceDate:startDate];
            NSInteger stepCount = [[sampleStep quantity] doubleValueForUnit:[HKUnit countUnit]];
            totalTime += secondBetween;
            totalStep += stepCount;
            // TODO: time active can be zero if data source from healthkit app, because start date and end date is same
            NSLog(@"second activity %@ = %@ = %f = %ld", startDate, endDate, secondBetween, (long)stepCount);
        }
        NSLog(@"total activity %@ = %@ = %f = %ld", startDate, endDate, totalTime, (long)totalStep);
        onCompleted(totalTime, totalStep, error);
    }];
   
    
    [self.healthStore executeQuery:stepQuery];
}

- (void) getDistanceWalkingRunning:(NSDate*) startDate endDate:(NSDate*) endDate withCompletion:(void (^)(double totalDistance, NSArray * listOfSpeed, NSError *error)) onCompleted {
    HKSampleType *type = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    NSPredicate *stepPredicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    NSSortDescriptor *stepSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    
    HKSampleQuery *stepQuery = [[HKSampleQuery alloc] initWithSampleType:type predicate:stepPredicate limit:0 sortDescriptors:@[stepSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *hkSample, NSError *error){
        
        double totalDistance = 0;
        NSMutableArray *listOfSpeed = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [hkSample count]; i++) {
            HKQuantitySample *sampleData = [hkSample objectAtIndex:i];
            double distance = [[sampleData quantity] doubleValueForUnit:[HKUnit meterUnitWithMetricPrefix:HKMetricPrefixKilo]];
            totalDistance += distance;
            
            double distanceMeter = [[sampleData quantity] doubleValueForUnit:[HKUnit meterUnit]];
//            double distanceSecond = [[sampleData startDate] doubleValueForUnit:[HKUnit secondUnitWithMetricPrefix:HKMetricPrefixKilo]];
            NSDate *startDate = [sampleData startDate];
            NSDate *endDate = [sampleData endDate];
            NSTimeInterval distanceSecond = [endDate timeIntervalSinceDate:startDate];
            
            double distanceMeterPerSecond = distanceMeter / distanceSecond;
            NSNumber *numberMeterPerSecond = [NSNumber numberWithDouble:distanceMeterPerSecond];
            [listOfSpeed addObject:numberMeterPerSecond];
            
//            HKUnit *meters = [HKUnit meterUnit];
//            HKUnit *seconds = [HKUnit secondUnit];
//            HKUnit *metersPerSecond = [meters unitDividedByUnit:seconds];
//            HKQuantity *quantityPerSecond = [HKQuantity quantityWithUnit:metersPerSecond doubleValue:distanceMeter];
            
//            NSLog(@"distance activity %f, %@, %f m/s", distance, quantityPerSecond, distanceMeterPerSecond);
            
        }
        NSLog(@"total distance %f", totalDistance);
        onCompleted(totalDistance, listOfSpeed, error);
    }];
    
    
    [self.healthStore executeQuery:stepQuery];
}

- (void) getHeartRate:(NSDate*) startDate endDate:(NSDate*) endDate withCompletion:(void (^)(double bpm, NSError *error)) onCompleted {
    HKSampleType *type = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    NSPredicate *stepPredicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    NSSortDescriptor *stepSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    
    HKSampleQuery *stepQuery = [[HKSampleQuery alloc] initWithSampleType:type predicate:stepPredicate limit:0 sortDescriptors:@[stepSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *hkSample, NSError *error){
        
        double totalBpm = 0;
        
        for (int i = 0; i < [hkSample count]; i++) {
            HKQuantitySample *sampleData = [hkSample objectAtIndex:i];
            double bpm = [[sampleData quantity] doubleValueForUnit:[HKUnit countUnit]];
            totalBpm += bpm;
            NSLog(@"distance activity %f", bpm);
            
        }
        NSLog(@"total distance %f", totalBpm);
        onCompleted(totalBpm, error);
    }];
    
    
    [self.healthStore executeQuery:stepQuery];
}


- (void) setStepActiveOnBackground{
    HKSampleType *type = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKObserverQuery *query = [[HKObserverQuery alloc] initWithSampleType:type predicate:nil updateHandler:^(HKObserverQuery *query, HKObserverQueryCompletionHandler completionHandler, NSError *error){
        if (error) {
            NSLog(@"*** An error occured while setting up the stepCount observer. %@ ***",
                  error.localizedDescription);
            abort();
        }
        
        NSLog(@"receive background changes");
        NSDate *endDate = [[NSDate alloc] init];
        NSDate *startDate = [endDate dateByAddingTimeInterval:-24 * 60 *60];
        [self getStepActive:startDate endDate:endDate withCompletion:^(float secondActive, NSInteger stepCount, NSError *error){
            
        }];
        
        completionHandler();
        
    }];
    
    [self.healthStore executeQuery:query];
    
    [self.healthStore enableBackgroundDeliveryForType:type frequency:HKUpdateFrequencyImmediate withCompletion:^(BOOL success, NSError *error){
        if (success) {
            NSLog(@"success background changes");
        }
    }];
}

- (void) enabledBackgroundDelivery{
    HKSampleType *type = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    [self.healthStore enableBackgroundDeliveryForType:type frequency:HKUpdateFrequencyImmediate withCompletion:^(BOOL success, NSError *error){
        if (success) {
            NSLog(@"success background changes");
        }
    }];
}

- (void) getActivitySummary:(void (^) (NSArray *activitySummary, NSError *error)) onCompleted{
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDate *endDate = [NSDate date];
    NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:-7 toDate:endDate options:0];
    NSCalendarUnit unit = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitEra;
    
    NSDateComponents *startDateComponents = [calendar components:unit fromDate:startDate];
    startDateComponents.calendar = calendar;
    
    NSDateComponents *endDateComponents = [calendar components:unit fromDate:endDate];
    endDateComponents.calendar = calendar;
    
    NSPredicate *summariesWithinRange = [HKQuery predicateForActivitySummariesBetweenStartDateComponents:startDateComponents endDateComponents:endDateComponents];
    
    HKActivitySummaryQuery *query = [[HKActivitySummaryQuery alloc] initWithPredicate:summariesWithinRange resultsHandler:^(HKActivitySummaryQuery *query, NSArray *activitySummaries, NSError *error){
        NSLog(@"%ld", (unsigned long)[activitySummaries count]);
        for (int i=0; i < [activitySummaries count]; i++) {
            HKActivitySummary *activitySummary = [activitySummaries objectAtIndex:i];
            HKQuantity *quantityEnergyBurned = [activitySummary activeEnergyBurned];
            double secondUnit = [quantityEnergyBurned doubleValueForUnit:[HKUnit secondUnit]];
            NSLog(@"second unit %f", secondUnit);
        }
    }];
    
    [self.healthStore executeQuery:query];
}


@end
