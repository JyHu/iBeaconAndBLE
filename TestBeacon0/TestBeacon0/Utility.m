//
//  Utility.m
//  TestBeacon0
//
//  Created by JinyouHu on 15/3/16.
//  Copyright (c) 2015年 JinyouHu. All rights reserved.
//

#import "Utility.h"

@implementation Utility

+ (void)rangingNotification:(CLBeacon *)beacon
{
    UILocalNotification *notify = [[UILocalNotification alloc] init];
    
    NSString *proximityString ;
    
    switch (beacon.proximity)
    {
        case CLProximityNear:
            proximityString = @"Near";
            break;
            
        case CLProximityFar:
            proximityString = @"Far";
            break;
            
        case CLProximityImmediate:
            proximityString = @"Immediate";
            break;
            
        case CLProximityUnknown:
        default:
            break;
    }
    
    notify.alertBody = [NSString stringWithFormat:@"%@,%@ • %@ • %f • %li", beacon.major.stringValue, beacon.minor.stringValue, proximityString, beacon.accuracy, (long)beacon.rssi];
    
    [self cacheNotify:notify.alertBody];
    
//    [[UIApplication sharedApplication] presentLocalNotificationNow:notify];
}

+ (void)enterRanging
{
    UILocalNotification *lNotify = [[UILocalNotification alloc] init];
    lNotify.alertBody = @"enter ranging";
//    [[UIApplication sharedApplication] presentLocalNotificationNow:lNotify];
    
    [self cacheNotify:@"enter ranging"];
}

+ (void)exitRanging
{
    UILocalNotification *notify = [[UILocalNotification alloc] init];
    notify.alertBody = @"exit ranging";
//    [[UIApplication sharedApplication] presentLocalNotificationNow:notify];
    
    [self cacheNotify:@"exit ranging"];
}

+ (void)notify:(NSString *)notifyBody
{
    UILocalNotification *notify = [[UILocalNotification alloc] init];
    notify.alertBody = notifyBody;
//    [[UIApplication sharedApplication] presentLocalNotificationNow:notify];
    
    [self cacheNotify:notifyBody];
}

+ (void)cacheNotify:(NSString *)noti
{
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:TestDefaultsKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@\n%@  ---- %@", str, [NSDate date], noti] forKey:TestDefaultsKey];
}

@end
