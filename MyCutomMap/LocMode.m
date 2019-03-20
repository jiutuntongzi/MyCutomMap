//
//  LocMode.m
//  MyCutomMap
//
//  Created by ispeak on 2018/3/26.
//  Copyright © 2018年 ydd. All rights reserved.
//

#import "LocMode.h"

@implementation LocMode

- (instancetype)init
{
    self = [super init];
    if (self) {
        _name = nil;
        _eastlatitude = nil;
        _eastlongitude = nil;
        _westlatitude = nil;
        _westlongitude = nil;
        _imageName = nil;
    }
    return self;
}


@end
