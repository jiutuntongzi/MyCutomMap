//
//  MyAppMode.h
//  MyCutomMap
//
//  Created by ispeak on 2018/3/26.
//  Copyright © 2018年 ydd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocMode.h"

@interface MyAppMode : NSObject

@property (nonatomic, assign) CLLocationCoordinate2D myCoord;
@property (nonatomic, assign) BOOL locServiceAble;
@property (nonatomic, assign) CLLocationCoordinate2D currentCoord;


@property (nonatomic, assign) CGFloat zoomLevel;

@property (nonatomic, strong) UIView *alertView;
@property (nonatomic, strong) UILabel *alertLabel;

+ (instancetype)shareAppMode;

- (NSString *)getImagePath;

/*
 获取所有位置数据
 */
- (NSMutableArray *)getLocDataAll;

/*
 保存位置数据
 */
- (BOOL)saveLocDataForLocMode:(LocMode *)locMode;

/*
 删除位置数据
 */
- (void)deleteLocDataForLocMode:(LocMode *)locMode;

- (void)showAlertView:(NSString *)title dealy:(CGFloat)dealy;

@end
