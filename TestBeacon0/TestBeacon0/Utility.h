//
//  Utility.h
//  TestBeacon0
//
//  Created by JinyouHu on 15/3/16.
//  Copyright (c) 2015年 JinyouHu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface Utility : NSObject

+ (void)rangingNotification:(CLBeacon *)beacon;

+ (void)enterRanging;

+ (void)exitRanging;

+ (void)notify:(NSString *)notifyBody;

@end
