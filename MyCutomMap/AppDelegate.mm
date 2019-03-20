//
//  AppDelegate.m
//  MyCutomMap
//
//  Created by ispeak on 2018/3/23.
//  Copyright © 2018年 ydd. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager       *locationManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self getLocation];
    
  
    
    ViewController *VC = [[ViewController alloc] init];
    UINavigationController *navigVC = [[UINavigationController alloc] initWithRootViewController:VC];
    self.window.rootViewController = navigVC;
    [self.window makeKeyAndVisible];
  
  [self setBaiduMapSDK];
    
    
    
    return YES;
}

- (void)setBaiduMapSDK
{
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc] init];
    
    /**
     *百度地图SDK所有接口均支持百度坐标（BD09）和国测局坐标（GCJ02），用此方法设置您使用的坐标类型.
     *默认是BD09（BMK_COORDTYPE_BD09LL）坐标.
     *如果需要使用GCJ02坐标，需要设置CoordinateType为：BMK_COORDTYPE_COMMON.
     */
    if ([BMKMapManager setCoordinateTypeUsedInBaiduMapSDK:BMK_COORDTYPE_BD09LL]) {
        NSLog(@"经纬度类型设置成功");
    } else {
        NSLog(@"经纬度类型设置失败");
    }
    
    NSString *bundleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString *key = @"";
    if ([bundleID isEqualToString:@"com.qinhe.g.live"]) {
        key = @"2k6aF2oTUkR6A7HS2xQwVozBAY6ZAcG0";
    } else if ([bundleID isEqualToString:@"com.jilang.hotlives"]) {
        key = @"r6pt87zcwWPEjqPhCy93HrjjanPYWSD4";
    } else {
        [[MyAppMode shareAppMode] showAlertView:@"bundleID不匹配😭" dealy:5];
        return;
    }
    
    
    BOOL ret = [_mapManager start:key generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
}

#pragma mark BMKGeneralDelegate
- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        NSLog(@"联网成功");
    }
    else{
        NSLog(@"onGetNetworkState %d",iError);
    }
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        NSLog(@"授权成功");
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}

#pragma mark 获取定位
-(void)getLocation
{
    //    1.实例化定位管理器
    _locationManager = [[CLLocationManager alloc] init];
    //    2.设置代理
    _locationManager.delegate = self;
    //3.定位精度
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    //4.请求用户权限：分为：4.1只在前台开启定位4.2在后台也可定位，
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
        [_locationManager requestWhenInUseAuthorization];//4.1只在前台开启定位
        //        [_locationManager requestAlwaysAuthorization];//4.2在后台也可定位
    }
    //    5.0更新用户位置
    [_locationManager startUpdatingLocation];
}
//- CLLocationManagerDelegate -
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations  {
    if (locations && [locations count] > 0) {
        CLLocation *newLocation = locations[0];
//        CLLocationCoordinate2D oldCoordinate = newLocation.coordinate;
        [MyAppMode shareAppMode].myCoord = newLocation.coordinate;
        [manager stopUpdatingLocation];
        CLGeocoder *geocoder = [[CLGeocoder alloc]init];
        [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            if (placemarks && [placemarks count] > 0) {
                // 纬度
//                CLLocationDegrees latitude = newLocation.coordinate.latitude;
//                // 经度
//                CLLocationDegrees longitude = newLocation.coordinate.longitude;
                
            
            }
        }];
    }
}
// 定位服务状态改变时调用
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [MyAppMode shareAppMode].locServiceAble = NO;
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        {
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.locationManager requestAlwaysAuthorization];
            }
            NSLog(@"用户还未决定授权");
            break;
        }
        case kCLAuthorizationStatusRestricted:
        {
            NSLog(@"访问受限");
            break;
        }
        case kCLAuthorizationStatusDenied:
        {
            // 类方法，判断是否开启定位服务
            if ([CLLocationManager locationServicesEnabled]) {
                NSLog(@"定位服务开启，被拒绝");
                
            } else {
                NSLog(@"定位服务关闭，不可用");
            }
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        {
                        NSLog(@"获得前后台授权");
            [MyAppMode shareAppMode].locServiceAble = YES;
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
                        NSLog(@"获得前台授权");
             [MyAppMode shareAppMode].locServiceAble = YES;
            break;
        }
        default:
            break;
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
