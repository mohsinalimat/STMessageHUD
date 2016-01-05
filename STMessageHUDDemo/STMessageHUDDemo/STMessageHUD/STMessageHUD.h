//
//  STMessageHUD.h
//  STMessageHUDDemo
//
//  Created by https://github.com/STShenZhaoliang/STMessageHUD on 16/1/5.
//  Copyright © 2016年 ST. All rights reserved.
//

#import <UIKit/UIKit.h>

#define STMessageHUDSingleton  [STMessageHUD sharedMessageHUD]

/** 活动提示框 出现样式 */
typedef NS_ENUM(NSInteger, STHUDShowStyle) {
    STHUDShowStyleNormal,       // 出现在视图中心
    STHUDShowStyleStatusBar,    // 出现在状态栏中
    STHUDShowStyleNavigationBar,// 出现在导航栏下方
    STHUDShowStyleBottomBar     // 出现在屏幕下方  PS: 未实现
};

/** HUD 消息样式 */
typedef NS_ENUM(NSInteger, STHUDMessageType) {
    STHUDMessageTypeLoading,
    STHUDMessageTypeSuccess, // 成功, 会显示 "对勾" 的图片
    STHUDMessageTypeError // 失败, 会显示 "叉子" 的图片
};

@interface STMessageHUD : UIWindow

/** 1.设置内部视图的背景色 */
@property (nonatomic, strong, nullable)UIColor *colorBackground;

/** 2.是否需要双击手势, 双击手势默认行为: Dismiss 掉 STMessageHUD */
@property (nonatomic, assign) BOOL needDoubleTap;

/** 3.STMessageHUD 的出现样式 */
@property (nonatomic, assign) STHUDShowStyle showStyle;

/** 1.STMessageHUD 单例对象 */
+ (instancetype) sharedMessageHUD;


/** 2.显示视图，默认为Loading样式 */
- (void)show;


/** 3.隐藏视图 */
- (void)dismiss;




/**
 *  用来存放 "对勾""叉子"等 图片的字典
 */
@property (nonatomic, strong, readonly) NSMutableDictionary *imageDictionary;







/**
 *  提示错误信息,  默认的 ShowStyle = STHUDShowStyleNormal
 *
 *  @param message 文字信息
 */
+ (void) showErrorMessage:(NSString *)message;

/**
 *  提示错误信息
 *
 *  @param message   文字信息
 *  @param showStyle 展示方式
 */
+ (void) showErrorMessage:(NSString *)message showStyle:(STHUDShowStyle)showStyle;

/**
 *  提示成功信息,  默认的 ShowStyle = STHUDShowStyleNormal
 *
 *  @param message 文字信息
 */
+ (void) showSuccessMessage:(NSString *)message;

/**
 *  提示成功信息
 *
 *  @param message   文字信息
 *  @param showStyle 展示方式
 */
+ (void) showSuccessMessage:(NSString *)message showStyle:(STHUDShowStyle)showStyle;



/**
 *  动画隐藏 (如果您希望在 UIViewController 的 viewWillDisappear 或 viewDidDisapper 中 dismiss 掉 STMessageHUD, 请使用 +(void) dismiss 方法)
 */
+ (void) dismissWithAnimation;

/**
 *  展示文字, 然后隐藏 (当您确定 STMessageHUD 正在处于 Loading 状态显示的时候, 调用此方法来提示用户成功 或 失败)
 *
 *  @param message     需要展示的消息
 *  @param messageType 消息类型, 成功 或 失败
 */
+ (void) dismissWithMessage:(NSString *)message messageType:(STHUDMessageType)messageType;

@end
