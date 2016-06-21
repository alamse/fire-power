//
//  ViewController.m
//  Fire Power
//
//  Created by Sense on 6/20/16.
//  Copyright © 2016 Sense. All rights reserved.
//

#import "ViewController.h"
#import "HealthkitManager.h"
#import <HealthKit/HealthKit.h>

@interface ViewController ()
{
    HealthkitManager* healthManager;
    BOOL isAuth;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    healthManager = [HealthkitManager sharedInstance];
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDate *endDate = [NSDate date];
    NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:endDate options:0];
    
    
    
    [healthManager requestAuthorizeHealthKit:^(BOOL success, NSError *error){
        isAuth = success;
        if (success == NO) {
            NSLog(@"not authorized");
        }else{
            // TODO: Get Heart Rate
            [healthManager getHeartRate:startDate endDate:endDate withCompletion:^(double bpm, NSError *error){
                
            }];
            
            
            // TODO: Get Activity Summary
            [healthManager getActivitySummary:^(NSArray *activitySummary, NSError *error){
                
            }];
            
            // TODO: Get Step Active
            [healthManager getStepActive:startDate endDate:endDate withCompletion:^(float totalSecondActivity, NSInteger totalStepsCount, NSError *error){
            
            }];
            
            // TODO: Get Distance Walking Running
            [healthManager getDistanceWalkingRunning:startDate endDate:endDate withCompletion:^(double totalDistance, NSArray *listOfSpeed, NSError *error){
                
            }];
        }
    }];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
//    if (isAuth) {
//        
//        NSDate *endDate = [[NSDate alloc] init];
//        NSDate *startDate = [endDate dateByAddingTimeInterval:-24 * 60 *60];
//        [healthManager getStepActive:startDate endDate:endDate withCompletion:^(float secondActive, NSInteger stepCount, NSError *error){
//            
//        }];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
