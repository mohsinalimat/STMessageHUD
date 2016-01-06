//
//  ViewController.m
//  STMessageHUDDemo
//
//  Created by https://github.com/STShenZhaoliang/STMessageHUD on 16/1/5.
//  Copyright © 2016年 ST. All rights reserved.
//

#import "ViewController.h"
#import "STMessageHUD.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - lift cycle 生命周期

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

#pragma mark - Delegate 视图委托

#pragma mark - event response 事件相应

#pragma mark - private methods 私有方法
- (IBAction)click:(UIButton *)sender {
    NSLog(@"%s, %@", __FUNCTION__, self);
    
    STMessageHUD *hud = [[STMessageHUD alloc]init];
    hud.message = @"加载中...";
    hud.showStyle = STHUDShowStyleNormal;
    [hud show];
//    STMessageHUDSingleton.message = @"加载中...";
//    STMessageHUDSingleton.showStyle = STHUDShowStyleNormal;
//    STMessageHUDSingleton.imageHud = STMessageHUDSingleton.dictionaryImage[STMessageHUDImageKeyProgress];
//    [STMessageHUDSingleton show];
}

#pragma mark - getters and setters 属性


@end
