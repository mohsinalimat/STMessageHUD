//
//  ViewController.m
//  STMessageHUDDemo
//
//  Created by https://github.com/STShenZhaoliang/STMessageHUD on 16/1/5.
//  Copyright © 2016年 ST. All rights reserved.
//

#import "ViewController.h"
#import "STMessageHUD.h"
typedef NS_ENUM(NSInteger, STSelectedType) {
    
    STSelectedTypeShow = 2, //
    STSelectedTypeShowDismissWithSuccessMessage,
    STSelectedTypeShowDismissWithErrorMessage,
    STSelectedTypeShowSuccessMessage,
    STSelectedTypeShowErrorMessage,
    
    STSelectedTypeShowSuccessMessageNavigationBar = 8,
    STSelectedTypeShowErrorMessageNavigationBar,
    
    STSelectedTypeShowMessage = 11,
};

static CGFloat const duration = 0.7;

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong, nullable)UITableView *tableView; //
@end

@implementation ViewController

#pragma mark - lift cycle 生命周期

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:self.tableView];
}

#pragma mark - Delegate 视图委托

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    cell.textLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
    [cell setBackgroundColor:[UIColor grayColor]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case STSelectedTypeShow:
        {
            [STMessageHUD show];
        }
            break;
            
        case STSelectedTypeShowDismissWithSuccessMessage:
        {
            [STMessageHUD show];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [STMessageHUD dismissWithMessage:@"Load Success" messageType:STHUDMessageTypeSuccess];
            });
        }
            break;
            
        case STSelectedTypeShowDismissWithErrorMessage:
        {
            [STMessageHUD show];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [STMessageHUD dismissWithMessage:@"Load Error" messageType:STHUDMessageTypeError];
            });
        }
            break;
            
        case STSelectedTypeShowSuccessMessage:
        {
            [STMessageHUD showSuccessMessage: @"Load Success" showStyle: STHUDShowStyleNormal];
            //            [STMessageHUD showSuccessMessage: @"Loading Success"]; // 等价于上面这个方法, 默认的 ShowStyle 就是 STHUDShowStyleNormal
        }
            break;
            
        case STSelectedTypeShowErrorMessage:
        {
            [STMessageHUD showErrorMessage: @"Load Error" showStyle: STHUDShowStyleNormal];
            //            [STMessageHUD showErrorMessage: @"Loading Error"]; // 等价于上面这个方法, 默认的 ShowStyle 就是 STHUDShowStyleNormal
        }
            break;
            
        case STSelectedTypeShowSuccessMessageNavigationBar:
        {
            [STMessageHUD showSuccessMessage: @"Load Success" showStyle: STHUDShowStyleNavigationBar];
        }
            break;
            
        case STSelectedTypeShowErrorMessageNavigationBar:
        {
            [STMessageHUD showErrorMessage: @"Load Error" showStyle: STHUDShowStyleNavigationBar];
        }
            break;
            
        case STSelectedTypeShowMessage:
        {
            [STMessageHUD showSuccessMessage: @"Refresh Success" showStyle: STHUDShowStyleStatusBar];
        }
            
        default:
            break;
    }

}

#pragma mark - event response 事件相应

#pragma mark - private methods 私有方法

#pragma mark - getters and setters 属性

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds
                                                 style:UITableViewStylePlain];
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    }
    return _tableView;
}
@end
