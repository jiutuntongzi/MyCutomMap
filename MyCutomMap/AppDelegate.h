//
//  AppDelegate.h
//  MyCutomMap
//
//  Created by ispeak on 2018/3/23.
//  Copyright © 2018年 ydd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, BMKGeneralDelegate>
{
    BMKMapManager *_mapManager;
}

@property (strong, nonatomic) UIWindow *window;


@end

