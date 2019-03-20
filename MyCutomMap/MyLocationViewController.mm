//
//  MyLocationViewController.m
//  MyCutomMap
//
//  Created by ispeak on 2018/3/26.
//  Copyright © 2018年 ydd. All rights reserved.
//

#import "MyLocationViewController.h"
#import <Photos/Photos.h>
#import <BMKLocationKit/BMKLocationComponent.h>
typedef enum : NSInteger {
    selectMode_def,
    selectMode_start = 100,
    selectMode_east, //选取东北角
    selectMode_wast, //选取西南角
    selectMode_finish, // 选取完成
} selectMode;

@interface MyLocationViewController ()<BMKMapViewDelegate, BMKLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) BMKMapView *mapView;
@property (nonatomic, strong) BMKLocationManager *locManager;

@property (nonatomic, strong) BMKGroundOverlay *groundImage;

@property (nonatomic, strong) UILabel *locInfoLable;

@property (nonatomic, strong) UIToolbar *saveBar;

@property (nonatomic, assign) BOOL isSelect;

@property (nonatomic, assign) selectMode selectMode;
@property (nonatomic, assign) CLLocationCoordinate2D selectCoord;

@property (nonatomic, strong) UIBarButtonItem *eastbar;
@property (nonatomic, strong) UIBarButtonItem *wastBar;
@property (nonatomic, strong) BMKUserLocation *userLocation;

@end

@implementation MyLocationViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _locMode = [[LocMode alloc] init];
        _isSelect = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    NSArray *items = @[@"info",@"普通", @"添加图层", @"update", @"标准"];
    if (_loctype == LocType_location) {
        self.navigationController.title = _locMode.name ? _locMode.name : @"我的地图";
    } else {
        self.navigationController.title = @"收集经纬度";
        items = @[@"info",@"普通", @"添加图层",@"Edit", @"标准"];
    }

    NSMutableArray<UIBarButtonItem *> *barItems = [NSMutableArray array];
    for (int i = items.count - 1; i >= 0; i--) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:items[i] style:UIBarButtonItemStylePlain target:self action:@selector(barButtonAction:)];
        item.tag = i;
        [barItems addObject:item];
    }
    self.navigationItem.rightBarButtonItems = barItems;
    
    
    
    
    [self createMapView];
    
    [self initInfoLabel];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(20, 64, ScreenWidth, 40)];
    toolBar.barStyle = UIBarStyleDefault;
    [self.view addSubview:toolBar];
    
    NSMutableArray<UIBarButtonItem *> *toolItems = [NSMutableArray array];
    NSArray *titelArr = @[@"图片",@"东北角",@"西南角", @"拾取坐标"];
    for (int i = 0; i < titelArr.count; i++) {
        UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithTitle:titelArr[i] style:UIBarButtonItemStylePlain target:self action:@selector(saveBarbuttonAction:)];
        bar.tag = i;
        [bar setTintColor:[UIColor redColor]];
        [toolItems addObject:bar];
        if (i == 1) {
            _eastbar = bar;
        } else if (i == 2) {
            _wastBar = bar;
        }
    }
    [toolBar setItems:toolItems animated:YES];
    toolBar.backgroundColor = [UIColor clearColor];
    
    _saveBar = toolBar;
    _saveBar.hidden = YES;
}

- (void)initInfoLabel
{
    _locInfoLable = [[UILabel alloc] init];
    _locInfoLable.backgroundColor = [UIColor clearColor];
    _locInfoLable.textColor = [UIColor blackColor];
    _locInfoLable.font = [UIFont systemFontOfSize:12];
    _locInfoLable.textAlignment = NSTextAlignmentLeft;
    _locInfoLable.numberOfLines = 0;
    _locInfoLable.alpha = 0.5;
    [self.view addSubview:_locInfoLable];
    [_locInfoLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(64);
        make.width.mas_offset(ScreenWidth - 40);
        make.left.mas_offset(20);
        make.right.mas_offset(-20);
    }];
    _locInfoLable.hidden = YES;
}

- (void)setLocInfoLabelValue
{
    _locInfoLable.text = [NSString stringWithFormat:@"地图等级:%f\n经度:%f\n纬度:%f\n imagePath:%@\n eastLat:%@\n eastLong:%@\n wastLat:%@\n wastLong:%@",
                          [MyAppMode shareAppMode].zoomLevel,
                          [MyAppMode shareAppMode].currentCoord.longitude,
                          [MyAppMode shareAppMode].currentCoord.latitude, _locMode.imageName,
                          _locMode.eastlatitude, _locMode.eastlongitude, _locMode.westlatitude,_locMode.westlongitude];
}


- (void)barButtonAction:(UIBarButtonItem *)barItem
{
    
    if (barItem.tag == 0) {
        _locInfoLable.hidden = !_locInfoLable.hidden;
        _saveBar.hidden = YES;
    } else if (barItem.tag == 1) {
        static int mode = 0;
        [self selectTrackingMode:mode % 4];
        NSString *title = @"普通";
        switch (mode) {
            case 0:
                title = @"普通";
                break;
            case 1:
                title = @"方向";                    // 定位方向模式
                break;
                
            case 2:  //罗盘态
                title = @"罗盘";
                break;
            case 3:  //跟随状态
               title = @"跟随";
                break;
        }
        barItem.title = title;
        mode++;
        _saveBar.hidden = YES;
    } else if (barItem.tag == 2) {
        [self addGroundImageAction];
        _saveBar.hidden = YES;
    } else if (barItem.tag == 3) {
        _saveBar.hidden = !_saveBar.hidden;
        _selectMode = selectMode_def;
        _isSelect = NO;
    } else if (barItem.tag == 4) {
        static int type = 0;
        type = type % 3;
        NSString *title;
        if (type == 0) {
            _mapView.mapType = BMKMapTypeNone;
            title = @"空白";
        } else if (type == 1) {
            _mapView.mapType = BMKMapTypeStandard;
            title = @"标准";
        } else {
            _mapView.mapType = BMKMapTypeSatellite;
            title = @"卫星";
        }
        barItem.title = title;
        type++;
    }
}

- (void)saveBarbuttonAction:(UIBarButtonItem *)item
{
    if (item.tag == 0) {
        PHAuthorizationStatus authorStatus = [PHPhotoLibrary authorizationStatus];
        NSLog(@"openGallery_authorStatus == %ld",(long)authorStatus);
        if (authorStatus == PHAuthorizationStatusAuthorized || PHAuthorizationStatusDenied){
            //获取权限
            //调用系统相册的类
            UIImagePickerController *pickerController = [[UIImagePickerController alloc]init];
            
            //设置选取的照片是否可编辑
            pickerController.allowsEditing = NO;
            //设置相册呈现的样式
            pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//            UIImagePickerControllerSourceTypeSavedPhotosAlbum;//图片分组列表样式
            //照片的选取样式还有以下两种
            //UIImagePickerControllerSourceTypePhotoLibrary,直接全部呈现系统相册
            
            //选择完成图片或者点击取消按钮都是通过代理来操作我们所需要的逻辑过程
            pickerController.delegate = self;
            //使用模态呈现相册
            [self.navigationController presentViewController:pickerController animated:YES completion:^{
                
            }];
            
        } else {
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:@"请开启相册权限\n 设置 -> 隐私 -> 照片" preferredStyle:UIAlertControllerStyleAlert];
            [alertVc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"]]) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"]];
                }
                
            }]];
            
            [self presentViewController:alertVc animated:YES completion:nil];
        }
    } else if (item.tag == 1) {
        UIAlertController *aler = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定保存当前为坐标为东北角坐标吗?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style: UIAlertActionStyleCancel handler:nil];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            _locMode.eastlatitude = [NSString stringWithFormat:@"%f",[MyAppMode shareAppMode].currentCoord.latitude];
            _locMode.eastlongitude = [NSString stringWithFormat:@"%f",[MyAppMode shareAppMode].currentCoord.longitude];
            BOOL isSuc = [[MyAppMode shareAppMode] saveLocDataForLocMode:_locMode];
            if (isSuc) {
                [[MyAppMode shareAppMode] showAlertView:@"东北角坐标保存成功🙂" dealy:2];
            } else {
                [[MyAppMode shareAppMode] showAlertView:@"东北角坐标保存失败😭" dealy:2];
            }
        }];
        [aler addAction:cancel];
        [aler addAction:action];
        [self presentViewController:aler animated:YES completion:nil];
        
        
    } else if (item.tag == 2) {
        
        UIAlertController *aler = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定保存当前为坐标为西南角坐标吗?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style: UIAlertActionStyleCancel handler:nil];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

            _locMode.westlatitude = [NSString stringWithFormat:@"%f",[MyAppMode shareAppMode].currentCoord.latitude];
            _locMode.westlongitude = [NSString stringWithFormat:@"%f",[MyAppMode shareAppMode].currentCoord.longitude];

            BOOL isSuc = [[MyAppMode shareAppMode] saveLocDataForLocMode:_locMode];
            if (isSuc) {
                [[MyAppMode shareAppMode] showAlertView:@"西南角坐标保存成功🙂" dealy:2];
            } else {
                [[MyAppMode shareAppMode] showAlertView:@"西南角坐标保存失败😭" dealy:2];
            }
        }];
        [aler addAction:cancel];
        [aler addAction:action];
        [self presentViewController:aler animated:YES completion:nil];

    } else if (item.tag == 3) {
        if (!_isSelect) {
            [self showAlertView:@"确定要开启选取坐标模式吗?" tag:selectMode_start];
            _isSelect = YES;
        } else {
            _isSelect = NO;
            [[MyAppMode shareAppMode] showAlertView:@"已退出选取坐标模式" dealy:2];
        }
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (alertView.tag == selectMode_start) {
            _isSelect = YES;
            _wastBar.enabled = NO;
            _eastbar.enabled = NO;
            [self showprompt:@"请放大地图并寻找到西南角位置,点击获取坐标点"];
            _selectMode = selectMode_wast;
        } else if (alertView.tag == selectMode_wast) {
            if ([self saveWastPoint]) {
                [self showprompt:@"请放大地图并寻找到东北角位置,点击获取坐标点"];
                _selectMode = selectMode_east;
            }
        } else if (alertView.tag == selectMode_east) {
            if ([self saveEast]) {
                _selectMode = selectMode_def;
                _isSelect = NO;
                _wastBar.enabled = YES;
                _eastbar.enabled = YES;
                [[MyAppMode shareAppMode] showAlertView:@"拾取坐标完成,可以点击查看啦😁" dealy:2];
            }
        }
    } else {
        _isSelect = NO;
        _selectMode = selectMode_def;
        _wastBar.enabled = YES;
        _eastbar.enabled = YES;
        [[MyAppMode shareAppMode] showAlertView:@"已退出选取坐标模式" dealy:2];
    }
}

- (void)showAlertView:(NSString *)msg tag:(selectMode)tag
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示🙂" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = tag;
    [alert show];
}

- (void)showprompt:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示🙂" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

- (BOOL)saveWastPoint
{
    _locMode.westlatitude = [NSString stringWithFormat:@"%f",_selectCoord.latitude];
    _locMode.westlongitude = [NSString stringWithFormat:@"%f",_selectCoord.longitude];
    
    BOOL isSuc = [[MyAppMode shareAppMode] saveLocDataForLocMode:_locMode];
    if (isSuc) {
//        [[MyAppMode shareAppMode] showAlertView:@"西南角坐标保存成功🙂" dealy:1];
    } else {
        [[MyAppMode shareAppMode] showAlertView:@"西南角坐标保存失败😭" dealy:1];
    }
    return isSuc;
}

- (BOOL)saveEast
{
    _locMode.eastlatitude = [NSString stringWithFormat:@"%f",_selectCoord.latitude];
    _locMode.eastlongitude = [NSString stringWithFormat:@"%f",_selectCoord.longitude];

    BOOL isSuc = [[MyAppMode shareAppMode] saveLocDataForLocMode:_locMode];
    if (isSuc) {
//        [[MyAppMode shareAppMode] showAlertView:@"东北角坐标保存成功🙂" dealy:2];
    } else {
        [[MyAppMode shareAppMode] showAlertView:@"东北角坐标保存失败😭" dealy:2];
    }
    return isSuc;
}



- (void)createMapView
{
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)];
    _mapView.delegate = self;
    // 当前地图类型，可设定为标准地图、卫星地图
    _mapView.mapType = BMKMapTypeStandard;
    // 是否打开路况图层
    [_mapView setTrafficEnabled:NO];
    // 是否现显示3D楼块效果
    [_mapView setBuildingsEnabled:NO];
    // 是否打开百度城市热力图图层（百度自有数据）,注：地图层级大于11时，可显示热力图
    [_mapView setBaiduHeatMapEnabled:NO];
//    _mapView.minZoomLevel = 14;
    [_mapView setZoomLevel:16];
    
    
    _mapView.centerCoordinate = [MyAppMode shareAppMode].myCoord;

    [self.view addSubview:_mapView];
    

  //实例化BMKLocationManager定位信息类对象
  _locManager = [[BMKLocationManager alloc] init];
  //设置BMKLocationManager的代理
  _locManager.delegate = self;
    
    [self customLocationAccuracyCircle];
}

- (void)addGroundImageAction
{
    _groundImage = nil;
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotations:_mapView.annotations];
    
    [self addGroundOverlay];

}

- (void)addGroundOverlay {
    //添加图片图层覆盖物
    if (_groundImage == nil) {
        CLLocationCoordinate2D coords[2] = {0};
        
        if (_loctype == LocType_myLocation) {
            coords[0].latitude =  [MyAppMode shareAppMode].myCoord.latitude - 0.01; //39.910;
            coords[0].longitude = [MyAppMode shareAppMode].myCoord.longitude - 0.01;//116.370;
            coords[1].latitude = [MyAppMode shareAppMode].myCoord.latitude + 0.01;//39.950;
            coords[1].longitude = [MyAppMode shareAppMode].myCoord.longitude + 0.01;//116.430;
        } else {
            coords[0].latitude = [_locMode.westlatitude floatValue]; //39.910;
            coords[0].longitude = [_locMode.westlongitude floatValue];//116.370;
            coords[1].latitude = [_locMode.eastlatitude floatValue];//39.950;
            coords[1].longitude = [_locMode.eastlongitude floatValue];//116.430;
        }
        
        BMKCoordinateBounds bound;
        bound.southWest = coords[0];
        bound.northEast = coords[1];
        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ninda" ofType:@"jpg"]];
        if (_locMode.imageName.length > 0) {
            UIImage *tmpimage = [UIImage imageWithContentsOfFile:_locMode.imageName];
            if (tmpimage) {
                image = tmpimage;
            }
        }
        _groundImage = [BMKGroundOverlay groundOverlayWithBounds:bound icon:image];
        _groundImage.alpha = 0.8;
        
        [_mapView addOverlay:_groundImage];
        _mapView.zoomLevel = 16;
        CLLocationCoordinate2D coord;
        coord.latitude = (coords[0].latitude +  coords[1].latitude) * 0.5;
        coord.longitude = (coords[0].longitude + coords[1].longitude) * 0.5;
        _mapView.centerCoordinate = coord;
        
    }
    
    
}

- (void)startLocation
{
    [_locManager startUpdatingLocation];
    [self selectTrackingMode:1];
    
}


- (void)selectTrackingMode:(int)mode
{
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    
    NSLog(@"当前地图的 zoom = %f", _mapView.zoomLevel);
    //设置定位的状态
    switch (mode) {
        case 0:
             _mapView.userTrackingMode = BMKUserTrackingModeNone;
            break;
        case 1:
            _mapView.userTrackingMode = BMKUserTrackingModeHeading;                    // 定位方向模式
            break;
            
        case 2:  //罗盘态
            _mapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading;
            break;
        case 3:  //跟随状态
            _mapView.userTrackingMode = BMKUserTrackingModeFollow;
            break;
            
        default:
            break;
    }
   
    _mapView.showsUserLocation = YES;//显示定位图层
}

- (void)stopLocation
{
    [_locManager stopUpdatingLocation];
    _mapView.showsUserLocation = NO;
}

//自定义精度圈
- (void)customLocationAccuracyCircle {
    BMKLocationViewDisplayParam *param = [[BMKLocationViewDisplayParam alloc] init];
    param.accuracyCircleStrokeColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
    param.accuracyCircleFillColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.3];
    [_mapView updateLocationViewWithParam:param];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startLocation];
}

- (BMKUserLocation *)userLocation {
  if (!_userLocation) {
    //初始化BMKUserLocation类的实例
    _userLocation = [[BMKUserLocation alloc] init];
  }
  return _userLocation;
}

- (void)dealloc
{
    if (_mapView) {
        _mapView = nil;
    }
}

#pragma mark BMKMapViewDelegate
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView
{
    NSLog(@"地图初始化完毕时会调用此接口");
}


/**
 *点中地图空白处会回调此接口
 *@param mapView 地图View
 *@param coordinate 空白处坐标点的经纬度
 */
- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"单击地图");
    
    if (_selectMode == selectMode_wast) {
        _selectCoord = coordinate;
        [self showAlertView:@"是否保存西南角坐标" tag:selectMode_wast];
    } else if (_selectMode == selectMode_east) {
        _selectCoord = coordinate;
        [self showAlertView:@"是否保存东北角坐标" tag:selectMode_east];
    }
    
}

/**
 *双击地图时会回调此接口
 *@param mapView 地图View
 *@param coordinate 返回双击处坐标点的经纬度
 */
- (void)mapview:(BMKMapView *)mapView onDoubleClick:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"双击地图");
}

#pragma mark }

#pragma mark BMKLocationManagerDelegate {

/**
 * @brief 该方法为BMKLocationManager提供设备朝向的回调方法。
 * @param manager 提供该定位结果的BMKLocationManager类的实例
 * @param heading 设备的朝向结果
 */
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager
          didUpdateHeading:(CLHeading * _Nullable)heading {
  self.userLocation.heading = heading;
  [_mapView updateLocationData:self.userLocation];
  NSLog(@"heading is %@", heading);
}

/**
 *  @brief 连续定位回调函数。
 *  @param manager 定位 BMKLocationManager 类。
 *  @param location 定位结果，参考BMKLocation。
 *  @param error 错误信息。
 */
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didUpdateLocation:(BMKLocation * _Nullable)location orError:(NSError * _Nullable)error {
  self.userLocation.location = location.location;
  [_mapView updateLocationData:self.userLocation];
  [MyAppMode shareAppMode].zoomLevel = _mapView.zoomLevel;
  [MyAppMode shareAppMode].currentCoord = self.userLocation.location.coordinate;
  [self setLocInfoLabelValue];
}

/**
 *  @brief 当定位发生错误时，会调用代理的此方法。
 *  @param manager 定位 BMKLocationManager 类。
 *  @param error 返回的错误，参考 CLError 。
 */
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didFailWithError:(NSError * _Nullable)error {
    NSLog(@"location error");
}

/**
 *  @brief 定位权限状态改变时回调函数
 *  @param manager 定位 BMKLocationManager 类。
 *  @param status 定位权限状态。
 */
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {

}

#pragma mark }


#pragma mark implement BMKMapViewDelegate {

//根据overlay生成对应的View
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay
{
//    if ([overlay isKindOfClass:[BMKCircle class]])
//    {
//        BMKCircleView* circleView = [[BMKCircleView alloc] initWithOverlay:overlay];
//        circleView.fillColor = [[UIColor alloc] initWithRed:1 green:0 blue:0 alpha:0.5];
//        circleView.strokeColor = [[UIColor alloc] initWithRed:0 green:0 blue:1 alpha:0.5];
//        circleView.lineWidth = 5.0;
//
//        return circleView;
//    }
//
//    if ([overlay isKindOfClass:[BMKPolyline class]])
//    {
//        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
//        if (overlay == colorfulPolyline) {
//            polylineView.lineWidth = 5;
//            /// 使用分段颜色绘制时，必须设置（内容必须为UIColor）
//            polylineView.colors = [NSArray arrayWithObjects:
//                                   [[UIColor alloc] initWithRed:0 green:1 blue:0 alpha:1],
//                                   [[UIColor alloc] initWithRed:1 green:0 blue:0 alpha:1],
//                                   [[UIColor alloc] initWithRed:1 green:1 blue:0 alpha:0.5], nil];
//        } else {
//            polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:1];
//            polylineView.lineWidth = 20.0;
//            [polylineView loadStrokeTextureImage:[UIImage imageNamed:@"texture_arrow.png"]];
//        }
//        return polylineView;
//    }
//
//    if ([overlay isKindOfClass:[BMKPolygon class]])
//    {
//        BMKPolygonView* polygonView = [[BMKPolygonView alloc] initWithOverlay:overlay];
//        polygonView.strokeColor = [[UIColor alloc] initWithRed:0.0 green:0 blue:0.5 alpha:1];
//        polygonView.fillColor = [[UIColor alloc] initWithRed:0 green:1 blue:1 alpha:0.2];
//        polygonView.lineWidth =2.0;
//        polygonView.lineDash = (overlay == polygon2);
//        return polygonView;
//    }
    if ([overlay isKindOfClass:[BMKGroundOverlay class]])
    {
        BMKGroundOverlayView* groundView = [[BMKGroundOverlayView alloc] initWithOverlay:overlay];
        return groundView;
    }
//    if ([overlay isKindOfClass:[BMKArcline class]]) {
//        BMKArclineView *arclineView = [[BMKArclineView alloc] initWithArcline:overlay];
//        arclineView.strokeColor = [UIColor blueColor];
//        arclineView.lineDash = YES;
//        arclineView.lineWidth = 6.0;
//        return arclineView;
//    }
    return nil;
}


// 根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    //动画annotation
//    if (annotation == animatedAnnotation) {
//        NSString *AnnotationViewID = @"AnimatedAnnotation";
//        MyAnimatedAnnotationView *annotationView = nil;
//        if (annotationView == nil) {
//            annotationView = [[MyAnimatedAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
//        }
//        NSMutableArray *images = [NSMutableArray array];
//        for (int i = 1; i < 4; i++) {
//            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"poi_%d.png", i]];
//            [images addObject:image];
//        }
//        annotationView.annotationImages = images;
//        return annotationView;
//    }
    //普通annotation
//    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
//        NSString *AnnotationViewID = @"renameMark";
//        BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
//        if (annotationView == nil) {
//            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
//            if (annotation == lockedScreenAnnotation) {
//                // 设置颜色
//                annotationView.pinColor = BMKPinAnnotationColorGreen;
//                // 设置可拖拽
//                annotationView.draggable = NO;
//            } else {
//                // 设置可拖拽
//                annotationView.draggable = YES;
//            }
//            // 从天上掉下效果
//            annotationView.animatesDrop = YES;
//        }
//        return annotationView;
//    }
    return nil;
}

// 当点击annotation view弹出的泡泡时，调用此接口
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view;
{
    NSLog(@"paopaoclick");
}

#pragma mark }

#pragma mark UIImagePick
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    //info是所选择照片的信息
    
    //    UIImagePickerControllerEditedImage//编辑过的图片
    //    UIImagePickerControllerOriginalImage//原图
    NSLog(@"%@",info);
    
    UIImage *resultImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    if (resultImage) {
        NSData *data = UIImagePNGRepresentation(resultImage);
        NSString *imageName = [_locMode.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *imagePath = [[MyAppMode shareAppMode] getImagePath];
        imageName = [imagePath stringByAppendingPathComponent:imageName];
        imagePath = [NSString stringWithFormat:@"%@.png",imageName];
        NSFileManager *fileManager = [[NSFileManager alloc]init];
        if ([fileManager fileExistsAtPath:imagePath]) {
            [fileManager removeItemAtPath:imagePath error:nil];
        }
        if (data) {
           BOOL isSuc = [data writeToFile:imagePath atomically:YES];
            if (isSuc) {
                _locMode.imageName = imagePath;
                BOOL isSuc = [[MyAppMode shareAppMode] saveLocDataForLocMode:_locMode];
                if (isSuc) {
                    [[MyAppMode shareAppMode] showAlertView:@"图片保存成功🙂" dealy:2];
                } else {
                    [[MyAppMode shareAppMode] showAlertView:@"图片保存失败🙂" dealy:2];
                }
            }
        }
    }
    
    //使用模态返回到软件界面
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    
    //这是捕获点击右上角cancel按钮所触发的事件，如果我们需要在点击cancel按钮的时候做一些其他逻辑操作。就需要实现该代理方法，如果不做任何逻辑操作，就可以不实现
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
