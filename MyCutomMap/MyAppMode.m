//
//  MyAppMode.m
//  MyCutomMap
//
//  Created by ispeak on 2018/3/26.
//  Copyright © 2018年 ydd. All rights reserved.
//

#import "MyAppMode.h"

@implementation MyAppMode

static MyAppMode *appMode = nil;

+ (instancetype)shareAppMode
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appMode = [[MyAppMode alloc] init];
    });
    return appMode;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _myCoord = CLLocationCoordinate2D();
        _locServiceAble = NO;
        _currentCoord = CLLocationCoordinate2D();
        _zoomLevel = 0.0;
        
        _alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        _alertView.layer.cornerRadius = 10;
        _alertView.layer.masksToBounds = YES;
        _alertView.center = CGPointMake(ScreenWidth * 0.5, ScreenHeight * 0.5);
        [[[UIApplication sharedApplication] keyWindow] addSubview:_alertView];
        
        UIView *bgView = [[UIView alloc]initWithFrame:_alertView.bounds];
        bgView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.7];
        [_alertView addSubview:bgView];
        
        _alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 180)];
        _alertLabel.textAlignment = NSTextAlignmentCenter;
        _alertLabel.textColor = [UIColor whiteColor];
        _alertLabel.numberOfLines = 0;
        [_alertView addSubview:_alertLabel];
        _alertView.hidden = YES;
        
        
    }
    return self;
}

- (void)showAlertView:(NSString *)title dealy:(CGFloat)dealy
{
    if (!_alertView.hidden) {
        return;
    }
    _alertLabel.text = title;
    _alertView.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(dealy * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _alertView.hidden = YES;
    });
}

- (NSString *)getImagePath
{
    NSString *path =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    path = [path stringByAppendingPathComponent:@"groundImage"];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL isDire;
    BOOL isExis = [fileManager fileExistsAtPath:path isDirectory:&isDire];
    if (!isDire || !isExis) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

- (BOOL)saveLocDataForLocMode:(LocMode *)locMode
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [defaults objectForKey:kLocationKey];
    BOOL ishave = NO;
//    if (array && array.count > 0) {
        NSMutableArray *newArray = [NSMutableArray array];
        NSMutableDictionary *newDic = [NSMutableDictionary dictionary];
        for (NSDictionary *dic in array) {
            newDic = [NSMutableDictionary dictionaryWithDictionary:dic];
            NSString *nameStr = [dic objectForKey:kLocationName];
            if (locMode.name && locMode.name.length > 0 && [nameStr isEqualToString:locMode.name]) {
                ishave = YES;
                
                [newDic setObject:nameStr forKey:kLocationName];
                
                NSString *westLat = [dic objectForKey:kWestLatitude];
                if (locMode.westlatitude && locMode.westlatitude.length > 0 &&  ![westLat isEqualToString:locMode.westlatitude]) {
                    [newDic setObject:locMode.westlatitude forKey:kWestLatitude];
                }
                
                NSString *westLong = [dic objectForKey:kWestLongitude];
                if (locMode.westlongitude && locMode.westlongitude.length > 0 &&  ![westLong isEqualToString:locMode.westlongitude]) {
                    [newDic setObject:locMode.westlongitude forKey:kWestLongitude];
                }
                
                NSString *eastLat = [dic objectForKey:kEastLatitude];
                if (locMode.eastlatitude && locMode.eastlatitude.length > 0 && ![eastLat isEqualToString:locMode.eastlatitude]) {
                    [newDic setObject:locMode.eastlatitude forKey:kEastLatitude];
                }
                
                NSString *eastlong = [dic objectForKey:kEastLongitude];
                if (locMode.eastlongitude && locMode.eastlongitude.length > 0 && ![eastlong isEqualToString:locMode.eastlongitude]) {
                    [newDic setObject:locMode.eastlongitude forKey:kEastLongitude];
                }
                
                NSString *imageName = [dic objectForKey:kImageKey];
                if (locMode.imageName && locMode.imageName.length > 0 && ![imageName isEqualToString:locMode.imageName]) {
                    [newDic setObject:locMode.imageName forKey:kImageKey];
                }
                [newArray addObject:newDic];
                
            } else {
                [newArray addObject:dic];
            }
        }
        
        if (!ishave) {
            
            if (locMode.name && locMode.name.length > 0) {
                [newDic setObject:locMode.name forKey:kLocationName];
            }
            
            if (locMode.westlatitude && locMode.westlatitude.length > 0) {
                [newDic setObject:locMode.westlatitude forKey:kWestLatitude];
            }
            
            NSString *westLong = locMode.westlongitude;
            if (westLong && westLong.length > 0) {
                [newDic setObject:westLong forKey:kWestLongitude];
            }
            
            NSString *eastLat = locMode.eastlatitude;
            if (eastLat && eastLat.length > 0) {
                [newDic setObject:eastLat forKey:kEastLatitude];
            }
            
            NSString *eastlong = locMode.eastlongitude;
            if (eastlong && eastlong.length > 0) {
                [newDic setObject:eastlong forKey:kEastLongitude];
            }
            
            NSString *imageName = locMode.imageName;
            if (imageName && imageName.length > 0) {
                [newDic setObject:imageName forKey:kImageKey];
            }
            [newArray addObject:newDic];
        }
    if (newArray.count > 0) {
        [defaults setObject:newArray forKey:kLocationKey];
        return YES;
    } else {
        return NO;
    }
}

- (void)deleteLocDataForLocMode:(LocMode *)locMode
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [defaults objectForKey:kLocationKey];

    //    if (array && array.count > 0) {
    NSMutableArray *newArray = [NSMutableArray array];

    for (NSDictionary *dic in array) {
        NSString *nameStr = [dic objectForKey:kLocationName];
        if (nameStr && nameStr.length > 0 && [nameStr isEqualToString:locMode.name]) {
            continue;
        } else {
            [newArray addObject:dic];
        }
    }
    [defaults setObject:newArray forKey:kLocationKey];

    //    } else {
    //
    //    }
}


- (NSMutableArray *)getLocDataAll
{
    NSMutableArray *muteArray = [NSMutableArray array];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [defaults objectForKey:kLocationKey];
    if (array && array.count > 0) {
        for (NSDictionary *dic in array) {
            LocMode *locMode = [[LocMode alloc] init];
            locMode.name = [dic objectForKey:kLocationName];
            locMode.westlatitude = [dic objectForKey:kWestLatitude];
            locMode.westlongitude = [dic objectForKey:kWestLongitude];
            locMode.eastlatitude = [dic objectForKey:kEastLatitude];
            locMode.eastlongitude = [dic objectForKey:kEastLongitude];
            locMode.imageName = [dic objectForKey:kImageKey];
            [muteArray addObject:locMode];
        }
    }
    return muteArray;
}


@end
