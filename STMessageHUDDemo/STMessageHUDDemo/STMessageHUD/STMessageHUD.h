//
//  STMessageHUD.h
//  STMessageHUDDemo
//
//  Created by https://github.com/STShenZhaoliang/STMessageHUD on 16/1/5.
//  Copyright © 2016年 ST. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMessageHUDConst.h"

#import "NSObject+ST.h"



//#define STMessageHUDSingleton  [STMessageHUD sharedMessageHUD]

/** 活动提示框 出现样式 */
typedef NS_ENUM(NSInteger, STHUDShowStyle) {
    STHUDShowStyleNormal,       // 出现在视图中心
    STHUDShowStyleStatusBar,    // 出现在状态栏中
    STHUDShowStyleNavigationBar,// 出现在导航栏下方
    STHUDShowStyleBottomBar     // 出现在屏幕下方
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

/** 4.动画展示的持续时间 */
@property (nonatomic, assign)CGFloat duration; //

/** 5.提示信息的停留时间 */
@property (nonatomic, assign)CGFloat timeStay; //

/** 6.提示信息 */
@property (nonatomic, strong, nullable)NSString *message; //

@property (nonatomic, assign)STHUDMessageType messageType; //


/** 1.STMessageHUD 单例对象 */
+ (instancetype _Nonnull)sharedMessageHUD;

/** 2.显示视图，默认为Loading样式 */
- (void)show;




/** 1.Tap 手势 */
@property (nonatomic, strong, nullable)UITapGestureRecognizer *tapDouble;

/** 2.内部视图 */
@property (nonatomic, strong, nullable) UIView *contentView;

/** 3.显示"对勾"、"叉子"等图片的 ImageView */
@property (nonatomic, strong, nullable) UIImageView *imageView;

/** 4.显示 Loading 图片的 ImageView */
@property (nonatomic, strong, nullable) UIImageView *imageLoading;

/** 5.显示 提示文字 的 Label */
@property (nonatomic, strong, nullable) UILabel *labelMessage;

/** 6.用来存放 "对勾""叉子"等 图片的字典 */
@property (nonatomic, strong, nullable) NSMutableDictionary *dictionaryImage;

/** 7.是否需要图片视图动画 */
@property (nonatomic, assign) BOOL needImageAnimation;

/** 8.成功时, 放大缩小的动画 */
@property (nonatomic, strong, nullable)CAKeyframeAnimation *animationSuccess;

/** 9.失败时, 抖动的动画 */
@property (nonatomic, strong, nullable)CAKeyframeAnimation *animationError;

/** 10.等待时, 旋转的动画 */
@property (nonatomic, strong, nullable)CABasicAnimation *animationRotation;

/** 11.定时器, 自定消失 */
@property (nonatomic, strong, nullable) NSTimer *timerAutoDismiss;

/** 12.警示框的最大宽度 */
@property (nonatomic, assign) CGFloat widthMax;

/** 13.图片 */
@property (nonatomic, strong, nullable)UIImage *imageHud; //

/** 14.用来判断是否已经展示 */
@property (nonatomic, assign) BOOL isShow;





///**
// *  提示错误信息,  默认的 ShowStyle = STHUDShowStyleNormal
// *
// *  @param message 文字信息
// */
//+ (void) showErrorMessage:(NSString *_Nonnull)message;
//
///**
// *  提示错误信息
// *
// *  @param message   文字信息
// *  @param showStyle 展示方式
// */
//+ (void) showErrorMessage:(NSString *_Nonnull)message showStyle:(STHUDShowStyle)showStyle;
//
///**
// *  提示成功信息,  默认的 ShowStyle = STHUDShowStyleNormal
// *
// *  @param message 文字信息
// */
//+ (void) showSuccessMessage:(NSString *_Nonnull)message;
//
///**
// *  提示成功信息
// *
// *  @param message   文字信息
// *  @param showStyle 展示方式
// */
//+ (void) showSuccessMessage:(NSString *_Nonnull)message showStyle:(STHUDShowStyle)showStyle;



///**
// *  动画隐藏 (如果您希望在 UIViewController 的 viewWillDisappear 或 viewDidDisapper 中 dismiss 掉 STMessageHUD, 请使用 +(void) dismiss 方法)
// */
//- (void) dismissWithAnimation;
//
///**
// *  展示文字, 然后隐藏 (当您确定 STMessageHUD 正在处于 Loading 状态显示的时候, 调用此方法来提示用户成功 或 失败)
// *
// *  @param message     需要展示的消息
// *  @param messageType 消息类型, 成功 或 失败
// */
//- (void) dismissWithMessage:(NSString *_Nonnull)message messageType:(STHUDMessageType)messageType;

@end
