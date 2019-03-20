//
//  MyLocationViewController.h
//  MyCutomMap
//
//  Created by ispeak on 2018/3/26.
//  Copyright © 2018年 ydd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocMode.h"

typedef enum : NSUInteger {
    LocType_location = 0,
    LocType_gather,
    LocType_myLocation,
} LocType;

@interface MyLocationViewController : UIViewController

@property (nonatomic, assign) CLLocationCoordinate2D coord;

@property (nonatomic, assign) LocType loctype;

@property (nonatomic, strong) LocMode *locMode;

@end
