//
//  ET.h
//  TestBeacon0
//
//  Created by JinyouHu on 15/3/17.
//  Copyright (c) 2015年 JinyouHu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ET : NSManagedObject

@property (nonatomic, retain) NSString * reid;
@property (nonatomic, retain) NSNumber * major;
@property (nonatomic, retain) NSNumber * minor;
@property (nonatomic, retain) NSNumber * distance;

@end
