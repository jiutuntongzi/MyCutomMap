//
//  ViewController.m
//  MyCutomMap
//
//  Created by ispeak on 2018/3/23.
//  Copyright © 2018年 ydd. All rights reserved.
//

#import "ViewController.h"
#import "MyLocationViewController.h"

@interface ViewController ()<UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UIButton *backBtn;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.title = @"我的地图";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addItem)];
    self.navigationItem.rightBarButtonItem = rightBar;
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(20, 100, ScreenWidth - 40, 100);
    btn.backgroundColor = [UIColor clearColor];
    btn.center = self.view.center;
    btn.titleLabel.numberOfLines = 0;
    [btn setTitle:@"当前没有位置数据，可以点击右上角添加。（点击查看当前位置示哦）" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(startLocationExamples) forControlEvents:UIControlEventTouchUpInside];
    btn.enabled = YES;
    [self.view addSubview:btn];
    btn.hidden = YES;
    _backBtn = btn;
    
    [self.view addSubview:self.myTableView];
    
}

- (void)startLocationExamples
{
    if ([MyAppMode shareAppMode].locServiceAble) {
        MyLocationViewController *locationVC = [[MyLocationViewController alloc]init];
        locationVC.loctype = LocType_myLocation;
        locationVC.locMode.name = @"我的位置";
        [self.navigationController pushViewController:locationVC animated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"是否授权开启定位功能" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 101;
        [alert show];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadUI];
}

- (void)reloadUI
{
    _dataArr = [[MyAppMode shareAppMode] getLocDataAll];
    if (_dataArr.count > 0) {
        _myTableView.hidden = NO;
        _backBtn.hidden = YES;
        [_myTableView reloadData];
    } else {
        _myTableView.hidden = YES;
        _backBtn.hidden = NO;
    }
}
- (UITableView *)myTableView
{
    if (!_myTableView) {
        _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64) style:UITableViewStylePlain];
        _myTableView.dataSource = self;
        _myTableView.delegate = self;

        [_myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        _myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _myTableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    LocMode *locMode = _dataArr[indexPath.row];
    cell.textLabel.text = locMode.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LocMode *locMode = _dataArr[indexPath.row];
    [self startLocationForLocMode:locMode];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return   UITableViewCellEditingStyleDelete;
}
//先要设Cell可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//进入编辑模式，按下出现的编辑按钮后
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView setEditing:NO animated:YES];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[MyAppMode shareAppMode] deleteLocDataForLocMode:_dataArr[indexPath.row]];
        [self reloadUI];
    }
}
//修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
//设置进入编辑状态时，Cell不会缩进
- (BOOL)tableView: (UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


- (void)addItem
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"新建位置" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *txtName = [alert textFieldAtIndex:0];
    txtName.placeholder = @"请输入位置名称";
    alert.tag = 100;
    [alert show];
}

- (void)startLocationForLocMode:(LocMode *)locMode
{
    if ([MyAppMode shareAppMode].locServiceAble) {
        MyLocationViewController *locationVC = [[MyLocationViewController alloc]init];
        locationVC.loctype = LocType_location;
        locationVC.locMode = locMode;
        [self.navigationController pushViewController:locationVC animated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"是否授权开启定位功能" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 101;
        [alert show];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 1) {
        if (alertView.tag == 100) {
            UITextField *txt = [alertView textFieldAtIndex:0];
            NSString *name = txt.text;
            if (name.length > 0) {
                MyLocationViewController *locationVC = [[MyLocationViewController alloc]init];
                locationVC.loctype = LocType_gather;
                locationVC.locMode.name = name;
                [self.navigationController pushViewController:locationVC animated:YES];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"位置名称不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
        } else if (alertView.tag == 101) {
            NSURL *url = [NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
            if ([[UIApplication sharedApplication]canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
        
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
