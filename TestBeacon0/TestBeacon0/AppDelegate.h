//
//  AppDelegate.h
//  TestBeacon0
//
//  Created by JinyouHu on 15/3/16.
//  Copyright (c) 2015年 JinyouHu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ET.h"

#define TestDefaultsKey @"TestDefaultsKey"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)saveValue:(float)distance major:(NSNumber *)major minor:(NSNumber *)minor;

@end

