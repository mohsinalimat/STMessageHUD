//
//  STMessageHUDConst.h
//  STMessageHUDDemo
//
//  Created by https://github.com/STShenZhaoliang/STMessageHUD  on 16/1/6.
//  Copyright © 2016年 ST. All rights reserved.
//

@import Foundation;
@import UIKit;

#define ScreenWidth  CGRectGetWidth([UIScreen mainScreen].bounds)
#define ScreenHeight CGRectGetHeight([UIScreen mainScreen].bounds)

UIKIT_EXTERN NSString *const STMessageHUDImageCheck;
UIKIT_EXTERN NSString *const STMessageHUDImageCross;
UIKIT_EXTERN NSString *const STMessageHUDImageProgress;

UIKIT_EXTERN NSString *const STMessageHUDImageCheckWhite;
UIKIT_EXTERN NSString *const STMessageHUDImageCrossWhite;
UIKIT_EXTERN NSString *const STMessageHUDImageProgressWhite;

UIKIT_EXTERN NSString *const STMessageHUDImageKeyCheck;
UIKIT_EXTERN NSString *const STMessageHUDImageKeyCross;
UIKIT_EXTERN NSString *const STMessageHUDImageKeyProgress;

UIKIT_EXTERN NSString *const STMessageHUDSuccessAnimationKey ;
UIKIT_EXTERN NSString *const STMessageHUDErrorAnimationKey  ;
UIKIT_EXTERN NSString *const STMessageHUDLoadingMessage ;

/** 1.状态栏和导航栏的高度和 */
UIKIT_EXTERN CGFloat const STNavgationBarHeight;

/** 2.在导航栏下方的默认高度 */
UIKIT_EXTERN CGFloat const STNavigationDefaultHeight;

/** 3.在状态栏模式下的默认高度 */
UIKIT_EXTERN CGFloat const STStatusBarDefaultHeight;

/** 3.控件之间的间隔 */
UIKIT_EXTERN CGFloat const STMargin;