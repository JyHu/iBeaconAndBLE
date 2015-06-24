//
//  ViewController.m
//  TestBeacon0
//
//  Created by JinyouHu on 15/3/16.
//  Copyright (c) 2015年 JinyouHu. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Utility.h"
#import "AppDelegate.h"
#import "ET.h"

#define BeaconUUID @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
#define ScanServiceUUID @"1809"

@interface ViewController ()<CLLocationManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate>

@property (retain, nonatomic) CLLocationManager *locationManager;

@property (retain, nonatomic) CLBeaconRegion *beaconRegion;

@property (retain, nonatomic) CBCentralManager *centralManager;

@property (retain, nonatomic) CBPeripheral *peripheral;

@property (assign, nonatomic) BOOL hadInit;

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self beaconTest];
//    [self bleInit];
    
    _hadInit = NO;
}

#pragma mark - beacon test

- (void)beaconTest
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.activityType = CLActivityTypeFitness;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways)
        {
            [self.locationManager requestAlwaysAuthorization];
            
        }
    }
    
    [self.locationManager startUpdatingLocation];
    [self initRegion];
}

- (void)initRegion
{
    if (self.beaconRegion)
    {
        return;
    }
    
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:BeaconUUID] major:5677 minor:36014 identifier:@"SomeIdentifier"];
    self.beaconRegion.notifyEntryStateOnDisplay = YES;
    self.beaconRegion.notifyOnEntry = YES;
    self.beaconRegion.notifyOnExit = YES;
    
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"start monitoring for region");

    [self bleInit];
    
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"enter ranging");
    
    [Utility notify:@"enter ranging"];
    
    [self bleInit];
    
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"exit ranging");
    
    [Utility notify:@"exit ranging"];
    
    [self.centralManager stopScan];
    self.centralManager = nil;
    self.peripheral = nil;
    
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSLog(@"beacons count : %d",(int)beacons.count);
    
    if (beacons.count > 0)
    {
        CLBeacon *beacon = [beacons lastObject];
                
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] saveValue:beacon.accuracy major:beacon.major minor:beacon.minor];
        
//        [Utility rangingNotification:beacon];
        
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
        
        NSString *str = [NSString stringWithFormat:@"%@,%@ • %@ • %f • %li", beacon.major.stringValue, beacon.minor.stringValue, proximityString, beacon.accuracy, (long)beacon.rssi];
        self.resultLabel.text = str;
        NSLog(@"%@",str);
    }
}


#pragma mark - bluetooth

- (void)bleInit
{
    _centralManager = [[CBCentralManager alloc] initWithDelegate: self queue:nil];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn)
    {
        [Utility notify:@"ble not powered on "];
        
        return;
    }
    
    [Utility notify:@"scaning"];
    
    NSLog(@"scaning");
    
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:FALSE], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    
    [_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:ScanServiceUUID]] options:options];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSString *noty = [NSString stringWithFormat:@"discover peripheral %@， %@",peripheral.identifier,advertisementData];
    
    NSLog(@"%@",noty);
    
    [Utility notify:noty];
    
    _peripheral = peripheral;
    
    [_centralManager connectPeripheral:_peripheral options:nil];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"connect");
    
    [Utility notify:[NSString stringWithFormat:@"conect peripheral %@",peripheral.identifier]];
    
    _peripheral.delegate = self;
    
    [_peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"failed connect");
    
    [Utility notify:[NSString stringWithFormat:@"failed connect peripheral %@",peripheral.identifier]];
    
    [_centralManager retrievePeripheralsWithIdentifiers:@[_peripheral.identifier]];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *service in peripheral.services)
    {
        NSLog(@"find service %@",service.UUID);
        
        [Utility notify:[NSString stringWithFormat:@"find service %@ for peripheral %@",service.UUID, peripheral.identifier]];
        
        [_peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        NSLog(@"find characteristic %@",characteristic.UUID);
        
        [Utility notify:[NSString stringWithFormat:@"find characteristic %@ for service %@ peripheral %@",characteristic.UUID, service.UUID, peripheral.identifier]];
        
        [_peripheral setNotifyValue:YES forCharacteristic:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"update notification");
    
    [Utility notify:[NSString stringWithFormat:@"update notify for characteristic %@ for peripheral %@",characteristic.UUID, peripheral.identifier]];
    
    [_peripheral readValueForCharacteristic:characteristic];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"read value");
    
    [Utility notify:[NSString stringWithFormat:@"read value %@ for characteristic %@",characteristic.value, characteristic.UUID]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
