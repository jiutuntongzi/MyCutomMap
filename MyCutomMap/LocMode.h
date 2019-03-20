//
//  LocMode.h
//  MyCutomMap
//
//  Created by ispeak on 2018/3/26.
//  Copyright © 2018年 ydd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocMode : NSObject

@property (nonatomic, strong) NSString *name;
/*
 西南角经度
 */
@property (nonatomic, strong) NSString *westlongitude;
/*
 西南角纬度
 */
@property (nonatomic, strong) NSString *westlatitude;

/*
 东北角经度
 */
@property (nonatomic, strong) NSString *eastlongitude;
/*
 东北角纬度
 */
@property (nonatomic, strong) NSString *eastlatitude;
/*
 图片
 */
@property (nonatomic, strong) NSString *imageName;



@end
