//
//  HealthkitManager.h
//  Fire Power
//
//  Created by Sense on 6/20/16.
//  Copyright © 2016 Sense. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HealthkitManager : NSObject

+ (HealthkitManager*) sharedInstance;
- (void) requestAuthorizeHealthKit:(void (^)(BOOL success, NSError *error)) completion;
- (void) getActivitySummary:(void (^) (NSArray *activitySummary, NSError *error)) onCompleted;
- (void) getStepActive:(NSDate*) startDate endDate:(NSDate*) endDate withCompletion:(void (^)(float totalSecondActivity, NSInteger totalStepsCount, NSError *error)) onCompleted;
- (void) getDistanceWalkingRunning:(NSDate*) startDate endDate:(NSDate*) endDate withCompletion:(void (^)(double totalDistance, NSArray * listOfSpeed, NSError *error)) onCompleted;
- (void) getHeartRate:(NSDate*) startDate endDate:(NSDate*) endDate withCompletion:(void (^)(double bpm, NSError *error)) onCompleted;
- (void) setStepActiveOnBackground;
- (void) enabledBackgroundDelivery;

@end
