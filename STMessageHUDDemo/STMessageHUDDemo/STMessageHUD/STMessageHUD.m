//
//  STMessageHUD.m
//  STMessageHUDDemo
//
//  Created by https://github.com/STShenZhaoliang/STMessageHUD on 16/1/5.
//  Copyright © 2016年 ST. All rights reserved.
//

#import "STMessageHUD.h"

#define ScreenWidth  CGRectGetWidth([UIScreen mainScreen].bounds)
#define ScreenHeight CGRectGetHeight([UIScreen mainScreen].bounds)


static NSString *const STMessageHUDImageCheck = @"checkmark";
static NSString *const STMessageHUDImageCross = @"cross";
static NSString *const STMessageHUDImageProgress = @"progress";

static NSString *const STMessageHUDImageCheckWhite = @"checkmark_white";
static NSString *const STMessageHUDImageCrossWhite = @"cross_white";
static NSString *const STMessageHUDImageProgressWhite = @"progress_white";

static NSString *const STMessageHUDImageKeyCheck = @"Check";
static NSString *const STMessageHUDImageKeyCross = @"Cross";
static NSString *const STMessageHUDImageKeyProgress = @"Progress";

static NSString *const STMessageHUDSuccessAnimationKey = @"SuccessAnimation";
static NSString *const STMessageHUDErrorAnimationKey = @"ErrorAnimation";

static CGFloat const STMessageHUDMargin = 10;

/** 导航栏下方时的默认高度 */
static CGFloat const STMessageHUDShowStyleNavigationDefaultHeight = 50;

/** 动画展示的时间 */
static CGFloat const STMessageHUDShowDuration = 0.2;

/** 提示信息停留时间 */
static CGFloat const STMessageHUDShowTimeDuration = 1.6;

/** 背景透明度 */
static CGFloat const STMessageHUDBackgroundAlpha = 0.6;

/** Loading 的默认文字信息 */
static NSString *const STMessageHUDLoadingMessage = @"加载中...";

@interface STMessageHUD ()






/** 用来存放 "对勾""叉子"等 图片的字典 */
@property (nonatomic, strong) NSMutableDictionary *imageDict;

/** 存放资源的 Bundle */
@property (nonatomic, strong) NSBundle *resourseBundle;

/** 最大宽度 */
@property (nonatomic, assign) CGFloat maxWidth;

/** Tap 手势 */
//@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;

/** 用来判断是否已经展示 */
@property (nonatomic, assign) BOOL isShow;

/** 用来自动 Dismiss 的定时器 */
@property (nonatomic, strong) NSTimer *autoDismissTimer;

/** 是否需要 ImageView 动画 */
@property (nonatomic, assign) BOOL needImageViewAnimation;




/** 1.Tap 手势 */
@property (nonatomic, strong, nullable)UITapGestureRecognizer *tapDouble;

/** 2.内部视图 */
@property (nonatomic, strong) UIView *contentView;

/** 3.显示"对勾"、"叉子"等图片的 ImageView */
@property (nonatomic, strong) UIImageView *imageView;

/** 4.显示 Loading 图片的 ImageView */
@property (nonatomic, strong) UIImageView *imageLoading;

/** 5.显示 提示文字 的 Label */
@property (nonatomic, strong) UILabel *labelMessage;

@end

@implementation STMessageHUD

#pragma mark - 单例

static STMessageHUD *instance_ = nil;

+ (instancetype)sharedMessageHUD
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance_ = [[self alloc] init];
    });
    return instance_;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance_ = [super allocWithZone:zone];
    });
    return instance_;
}

#pragma mark - 构造方法

- (instancetype)init
{
    if (self = [super init]) {
        // 1.设置默认配置
        [self setupDefaultUI];
        
    
        
        // 2. 配置成员变量
        [self configureVariables];
        

    }
    return self;
}

#pragma mark - 设置默认配置
- (void)setupDefaultUI
{
    // 1.设置自身属性
    [self setBackgroundColor:[UIColor clearColor]];
    [self setFrame:[UIApplication sharedApplication].keyWindow.bounds];
    [self setClipsToBounds:YES];
    [self setWindowLevel:UIWindowLevelStatusBar];
    [self makeKeyAndVisible];
    
    // 2.添加子视图
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.imageLoading];
    [self.contentView addSubview:self.labelMessage];
    
    // 3.添加手势
    [self addGestureRecognizer:self.tapDouble];
    
    // 4.设置默认数据
    _colorBackground = [UIColor blackColor];
    
    [self refreshUI];
}

#pragma mark 配置成员变量
- (void) configureVariables {
    
    // 1. 存放图片资源的 Bundle
    NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"STMessageHUDResource.bundle"];
    self.resourseBundle = [NSBundle bundleWithPath: bundlePath];
    
    
    // 3. 设置最大宽度
    self.maxWidth = [UIScreen mainScreen].bounds.size.width/2.0;
    
    // 4. 需要双击手势
    self.needDoubleTap = YES;
}

#pragma mark 根据 STHUDStyle 刷新 UI
- (void) refreshUI {
            self.imageDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                              [UIImage imageWithContentsOfFile: [self.resourseBundle pathForResource:STMessageHUDImageCheckWhite ofType:@"png"]], STMessageHUDImageKeyCheck,
                              [UIImage imageWithContentsOfFile: [self.resourseBundle pathForResource:STMessageHUDImageCrossWhite ofType:@"png"]], STMessageHUDImageKeyCross,
                              [UIImage imageWithContentsOfFile: [self.resourseBundle pathForResource:STMessageHUDImageProgressWhite ofType:@"png"]], STMessageHUDImageKeyProgress,
                              nil];
            
            self.labelMessage.textColor = [UIColor whiteColor];
            self.alpha = 0.0;
            
            switch (self.showStyle) {
                case STHUDShowStyleNormal:
                {
                    CGFloat width = [UIScreen mainScreen].bounds.size.width/3.0;
                    
                    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
                    ;
                    self.windowLevel = UIWindowLevelNormal;
                    self.contentView.frame = CGRectMake(0, 0, width, width);
                    self.contentView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
                    self.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent: 0.3];
                    self.contentView.layer.cornerRadius = width/16;
                }
                    break;
                    
                case STHUDShowStyleNavigationBar:
                {
                    self.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent: 0.3];
                    self.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, STMessageHUDShowStyleNavigationDefaultHeight);
                    self.windowLevel = UIWindowLevelNormal;
                    self.contentView.frame = (CGRect) {CGPointZero, self.frame.size};
                    self.contentView.layer.cornerRadius = 0;
                }
                    break;
                    
                case STHUDShowStyleStatusBar:
                {
                    self.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent: 0.9];
                    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20);
                    self.windowLevel = UIWindowLevelStatusBar;
                    self.contentView.frame = (CGRect) {CGPointZero, self.frame.size};
                    self.imageView.hidden = YES;
                    self.imageLoading.hidden = YES;
                    self.contentView.layer.cornerRadius = 0;
                }
                    break;
                    
                default:
                    break;
            }
}

#pragma mark - 公有方法
#pragma mark -
#pragma mark 显示
+ (void) show {
    
    STMessageHUD *messageHUD = [STMessageHUD sharedMessageHUD];
    [messageHUD stopTimer];
    [messageHUD showMessageHUDWithMessage: STMessageHUDLoadingMessage
                                    image: messageHUD.imageDictionary[STMessageHUDImageKeyProgress]
                                showStyle: STHUDShowStyleNormal messageType: STHUDMessageTypeLoading];
}
#pragma mark 隐藏
+ (void) dismiss {
    
    STMessageHUD *messageHUD = [STMessageHUD sharedMessageHUD];
    [messageHUD hideMessageHUDWithShowStyle: messageHUD.showStyle animation: NO];
}
#pragma mark 动画隐藏
+ (void) dismissWithAnimation {
    
    STMessageHUD *messageHUD = [STMessageHUD sharedMessageHUD];
    [messageHUD hideMessageHUDWithShowStyle: messageHUD.showStyle animation: YES];
}
#pragma mark 显示文字, 然后隐藏
+ (void) dismissWithMessage:(NSString *)message messageType:(STHUDMessageType)messageType {
    
    STMessageHUD *messageHUD = [STMessageHUD sharedMessageHUD];
    
    UIImage *showImage = nil;
    
    switch (messageType) {
        case STHUDMessageTypeSuccess:
        {
            showImage = messageHUD.imageDictionary[STMessageHUDImageKeyCheck];
        }
            break;
            
        case STHUDMessageTypeError:
        {
            showImage = messageHUD.imageDictionary[STMessageHUDImageKeyCross];
        }
            break;
            
        default:
            break;
    }
    
    messageHUD.needImageViewAnimation = YES;
    
    [messageHUD configureContentWithMessage: message image: showImage messageType: messageType];
    
    messageHUD.autoDismissTimer = [NSTimer scheduledTimerWithTimeInterval:STMessageHUDShowTimeDuration target:[self class] selector:@selector(dismissWithAnimation) userInfo:nil repeats:NO];
}

#pragma mark 提示错误信息,  默认的 ShowStyle = STHUDShowStyleNormal
+ (void) showErrorMessage:(NSString *)message {
    [STMessageHUD showErrorMessage:message showStyle: STHUDShowStyleNormal];
}

#pragma mark 提示错误信息
+ (void) showErrorMessage:(NSString *)message showStyle:(STHUDShowStyle)showStyle {
    STMessageHUD *messageHUD = [STMessageHUD sharedMessageHUD];
    
    [messageHUD showMessageHUDWithMessage: message image: messageHUD.imageDictionary[STMessageHUDImageKeyCross] showStyle: showStyle messageType: STHUDMessageTypeError];
    
    [messageHUD startTimer];
}

#pragma mark 提示成功信息,  默认的 ShowStyle = STHUDShowStyleNormal
+ (void) showSuccessMessage:(NSString *)message {
    [STMessageHUD showSuccessMessage: message showStyle: STHUDShowStyleNormal];
}

#pragma mark 提示成功信息
+ (void) showSuccessMessage:(NSString *)message showStyle:(STHUDShowStyle)showStyle {
    
    STMessageHUD *messageHUD = [STMessageHUD sharedMessageHUD];
    
    [messageHUD showMessageHUDWithMessage: message image: messageHUD.imageDictionary[STMessageHUDImageKeyCheck] showStyle: showStyle messageType: STHUDMessageTypeSuccess];
    
    [messageHUD startTimer];
}

#pragma mark - Set 方法重写


#pragma mark Set ShowStyle
- (void) setShowStyle:(STHUDShowStyle)showStyle {
    
    if (_showStyle == showStyle) {
        return;
    }
    
    _showStyle = showStyle;
    
    // 1. 刷新 UI
    [self refreshUI];
}

#pragma mark - Get 方法重写
#pragma mark -
#pragma mark Get ImageDictionary
- (NSMutableDictionary *) imageDictionary {
    return self.imageDict;
}

#pragma mark - 私有方法
#pragma mark -
#pragma mark 播放图片动画
- (void) beginImageViewAnimationWithMessageType:(STHUDMessageType)messageType {
    
    switch (messageType) {
        case STHUDMessageTypeSuccess: // 成功时, "对勾"图片会有个放大缩小的动画
        {
            CAKeyframeAnimation *successAnimation = [CAKeyframeAnimation animationWithKeyPath: @"transform.scale"];
            successAnimation.values = @[@(1.2), @(0.8), @(1.0)];
            successAnimation.duration = 0.25f;
            [self.imageView.layer addAnimation: successAnimation forKey: STMessageHUDSuccessAnimationKey];
        }
            break;
            
        case STHUDMessageTypeError: // 失败时, "叉子"图片会有个抖动的动画
        {
            CAKeyframeAnimation *errorAnimation = [CAKeyframeAnimation animationWithKeyPath: @"transform.translation.x"];
            errorAnimation.values = @[@(-2), @(2), @(-2), @(2), @(-2), @(2), @(0)];
            errorAnimation.duration = 0.25f;
            [self.imageView.layer addAnimation: errorAnimation forKey: STMessageHUDErrorAnimationKey];
        }
            
        default:
            break;
    }
}
#pragma mark 刷新控件状态
- (void) refreshUIState {
    
    [self.imageLoading.layer removeAnimationForKey: STMessageHUDLoadingMessage];
    [self.imageLoading.layer removeAllAnimations];
    [self.imageView.layer removeAnimationForKey: STMessageHUDErrorAnimationKey];
    [self.imageView.layer removeAnimationForKey: STMessageHUDSuccessAnimationKey];
    [self.imageView.layer removeAllAnimations];
    self.labelMessage.text = @"";
    self.isShow = NO;
    self.alpha = 0.0;
}
#pragma mark 隐藏 STMessageHUD
- (void) hideMessageHUDWithShowStyle:(STHUDShowStyle)showStyle animation:(BOOL)needAnimation{
    
    // 1. 关闭用户交互
    self.userInteractionEnabled = NO;
    
    // 2. 根据 ShowStyle, 设置 UI, 进行隐藏动画
    switch (showStyle) {
        case STHUDShowStyleNormal:
        {
            if (needAnimation) {
                [UIView animateWithDuration: STMessageHUDShowDuration delay: 0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.alpha = 0.0;
                    self.contentView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                } completion:^(BOOL finished) {
                    self.contentView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    [self refreshUIState];
                }];
            } else {
                [self refreshUIState];
            }
        }
            break;
            
        case STHUDShowStyleNavigationBar:
        {
            if (needAnimation) {
                [UIView animateWithDuration: STMessageHUDShowDuration delay: 0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.alpha = 0.0;
                    self.contentView.transform = CGAffineTransformMakeScale(1.0, 0.1);
                } completion:^(BOOL finished) {
                    self.contentView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    [self refreshUIState];
                }];
            } else {
                [self refreshUIState];
            }
        }
            break;
            
        case STHUDShowStyleStatusBar:
        {
            if (needAnimation) {
                [UIView animateWithDuration: STMessageHUDShowDuration delay: 0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.alpha = 0.0;
                } completion:^(BOOL finished) {
                    [self refreshUIState];
                }];
            } else {
                [self refreshUIState];
            }
        }
            break;
            
        case STHUDShowStyleBottomBar:
        {
            
        }
            break;
            
        default:
            break;
    }
}
#pragma mark 动画显示 STMessageHUD
- (void) showMessageHUDWithMessage:(NSString *)message image:(UIImage *)image showStyle:(STHUDShowStyle)showStyle messageType:(STHUDMessageType)messageType {
    
    @synchronized(self)  {
        
        if (self.isShow) {
            [self hideMessageHUDWithShowStyle: STHUDShowStyleNormal animation: NO];
        }
        self.isShow = YES;
        
        // 0. 保存 ShowStyle
        self.showStyle = showStyle;
        
        // 1. 判断是否需要双击手势
        if (self.needDoubleTap) {
            self.userInteractionEnabled = YES;
        } else {
            self.userInteractionEnabled = NO;
        }
        
        // 2. 根据 ShowStyle, 设置 UI, 进行动画显示
        switch (showStyle) {
            case STHUDShowStyleNormal:
            {
                // 3. 设置显示内容
                [self configureContentWithMessage: message image: image messageType: messageType];
                
                // 4. 播放动画
                self.contentView.transform = CGAffineTransformMakeScale(0.2, 0.2);
                [UIView animateWithDuration:STMessageHUDShowDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.alpha = 1.0;
                    self.contentView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                } completion:^(BOOL finished) {
                    
                    [self beginImageViewAnimationWithMessageType: messageType];
                }];
            }
                break;
                
            case STHUDShowStyleNavigationBar:
            {
                // 3. 设置显示内容
                [self configureContentWithMessage: message image: image messageType: messageType];
                
                // 4. 播放动画
                self.contentView.transform = CGAffineTransformMakeScale(1.0, 0.0);
                [UIView animateWithDuration:STMessageHUDShowDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.alpha = 1.0;
                    self.contentView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                } completion:^(BOOL finished) {
                    
                    [self beginImageViewAnimationWithMessageType: messageType];
                }];
            }
                break;
                
            case STHUDShowStyleStatusBar:
            {
                // 3. 设置显示内容
                [self configureContentWithMessage: message image: image messageType: messageType];
                
                // 4. 动画显示
                [UIView animateWithDuration:STMessageHUDShowDuration*2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.alpha = 1.0;
                } completion:^(BOOL finished) {
                }];
            }
                break;
                
            case STHUDShowStyleBottomBar:
            {
                
            }
                break;
                
            default:
                break;
        }
    }
}

#pragma mark 配置显示内容 (适用于: STHUDShowStyleStatusBar)
- (void) configureStatusBarStyleContentWithMessage:(NSString *)message image:(UIImage *)image messageType:(STHUDMessageType)messageType {
    
    // 0. 停止动画
    [self.imageLoading.layer removeAllAnimations];
    [self.imageView.layer removeAllAnimations];
    
    // 1. 设置 Label 位置
    self.labelMessage.frame = CGRectMake(0, 0, self.contentView.bounds.size.width - 2*STMessageHUDMargin, 20);
    
    // 2. 设置 Label 文字
    self.labelMessage.text = message;
}

#pragma mark 配置显示内容 (适用于: STHUDShowStyleNavigationBar)
- (void) configureNavigationBarStyleContentWithMessage:(NSString *)message image:(UIImage *)image messageType:(STHUDMessageType)messageType {
    
    // 0. 停止动画
    [self.imageLoading.layer removeAllAnimations];
    [self.imageView.layer removeAllAnimations];
    
    // 1. 设置图片位置
    CGFloat scale = image.size.width / image.size.height;
    CGFloat imageHeight = STMessageHUDShowStyleNavigationDefaultHeight - STMessageHUDMargin*2;
    CGFloat imageWidth = scale * imageHeight;
    self.imageLoading.frame = CGRectMake(STMessageHUDMargin, STMessageHUDMargin, imageWidth, imageHeight);
    self.imageView.frame = self.imageLoading.frame;
    
    // 2. 设置 Label 位置
    self.labelMessage.frame = CGRectMake(CGRectGetMaxX(self.imageLoading.frame)+STMessageHUDMargin, 0, self.contentView.bounds.size.width - 2*STMessageHUDMargin - imageWidth, self.contentView.frame.size.height);
    
    // 3. 显示或隐藏 Loading ImageView
    if ([message isEqualToString: STMessageHUDLoadingMessage]) {
        
        self.imageLoading.hidden = NO;
        self.imageView.hidden = YES;
        
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath: @"transform.rotation.z" ];
        rotationAnimation.fromValue = @(0.0);
        rotationAnimation.toValue = @( 100 * M_PI );
        rotationAnimation.repeatCount = HUGE_VALF;
        rotationAnimation.duration = 36.0f;
        rotationAnimation.autoreverses = YES;
        [self.imageLoading.layer addAnimation: rotationAnimation  forKey: STMessageHUDLoadingMessage];
    } else {
        self.imageLoading.hidden = YES;
        self.imageView.hidden = NO;
    }
    
    // 11. 设置显示内容
    //    CATransition *animation = [CATransition animation];
    //    animation.duration = STMessageHUDShowDuration * 2;
    self.labelMessage.text = message;
    //    [self.labelMessage.layer addAnimation:animation forKey:nil];
    self.imageView.image = image;
    self.imageLoading.image = self.imageDict[STMessageHUDImageKeyProgress];
    
    // 12. 播放 ImageView 动画
    if (self.needImageViewAnimation) {
        self.needImageViewAnimation = NO;
        [self beginImageViewAnimationWithMessageType: messageType];
    }
}

#pragma mark 配置显示内容 (适用于: STHUDShowStyleNormal 和 STHUDShowStyleNavigationBar)
- (void) configureContentWithMessage:(NSString *)message image:(UIImage *)image messageType:(STHUDMessageType)messageType {
    
    if (self.showStyle == STHUDShowStyleStatusBar) {
        [self configureStatusBarStyleContentWithMessage: message image: image messageType: messageType];
        return;
    }
    
    if (self.showStyle == STHUDShowStyleNavigationBar) {
        [self configureNavigationBarStyleContentWithMessage: message image: image messageType: messageType];
        return;
    }
    
    // 0. 停止动画
    [self.imageLoading.layer removeAllAnimations];
    [self.imageView.layer removeAllAnimations];
    
    // 1. 计算 Message 的长度, 获取 Label 应有的高度
    CGFloat labelMessageHeight = [message boundingRectWithSize: CGSizeMake(image.size.width + 2*STMessageHUDMargin, MAXFLOAT)
                                                       options: NSStringDrawingUsesLineFragmentOrigin
                                                    attributes: @{NSFontAttributeName : self.labelMessage.font}
                                                       context: nil].size.height + STMessageHUDMargin;
    
    // 2. 获取 Image 的高度
    CGFloat imageHeight = image.size.height;
    
    // 3. 计算并设置 STMessageHUD 的 bounds
    CGFloat height = labelMessageHeight + imageHeight + 3*STMessageHUDMargin;
    CGFloat width = height<self.maxWidth ? height : self.maxWidth;
    
    // 4. 宽度计算完成后, 再计算一次 Label 的高度
    CGFloat currentHeight = [message boundingRectWithSize: CGSizeMake(width - 2*STMessageHUDMargin, MAXFLOAT)
                                                  options: NSStringDrawingUsesLineFragmentOrigin
                                               attributes: @{NSFontAttributeName : self.labelMessage.font}
                                                  context: nil].size.height + STMessageHUDMargin;
    
    // 5. 如果计算后的 Label 高度 小于 之前 Label 的高度, 则 Self 的高度应该减去一个差值
    if (currentHeight < labelMessageHeight) {
        height -= (labelMessageHeight - currentHeight);
    }
    
    // 6. 设置 UI 控件的位置
    [UIView animateWithDuration: STMessageHUDShowDuration delay:0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        
        // 7. 设置 内容视图的大小
        self.contentView.bounds = (CGRect){CGPointZero, {width, height}};
        
        // 8. 设置 Image 的 Frame
        self.imageView.frame = CGRectMake((self.contentView.bounds.size.width - image.size.width) * 0.5, STMessageHUDMargin, image.size.width, imageHeight);
        self.imageLoading.frame = self.imageView.frame;
        
        // 9. 设置 Label 的 位置
        self.labelMessage.frame = CGRectMake(STMessageHUDMargin, CGRectGetMaxY(self.imageView.frame) + STMessageHUDMargin, self.contentView.bounds.size.width - 2*STMessageHUDMargin, currentHeight);
    } completion:^(BOOL finished) {}];
    
    // 10. 显示或隐藏 Loading ImageView
    if ([message isEqualToString: STMessageHUDLoadingMessage]) {
        
        self.imageLoading.hidden = NO;
        self.imageView.hidden = YES;
        
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath: @"transform.rotation.z" ];
        rotationAnimation.fromValue = @(0.0);
        rotationAnimation.toValue = @( 100 * M_PI );
        rotationAnimation.repeatCount = HUGE_VALF;
        rotationAnimation.duration = 36.0f;
        rotationAnimation.autoreverses = YES;
        [self.imageLoading.layer addAnimation: rotationAnimation  forKey: STMessageHUDLoadingMessage];
    } else {
        self.imageLoading.hidden = YES;
        self.imageView.hidden = NO;
    }
    
    // 11. 设置显示内容
    //    CATransition *animation = [CATransition animation];
    //    animation.duration = STMessageHUDShowDuration * 2;
    self.labelMessage.text = message;
    //    [self.labelMessage.layer addAnimation:animation forKey:nil];
    self.imageView.image = image;
    self.imageLoading.image = self.imageDict[STMessageHUDImageKeyProgress];
    
    // 12. 播放 ImageView 动画
    if (self.needImageViewAnimation) {
        self.needImageViewAnimation = NO;
        [self beginImageViewAnimationWithMessageType: messageType];
    }
}

#pragma mark 停止定时器
- (void) stopTimer {
    
    [[STMessageHUD sharedMessageHUD].autoDismissTimer invalidate];
    [STMessageHUD sharedMessageHUD].autoDismissTimer = nil;
}

#pragma mark 开启定时器
- (void) startTimer {
    
    if ([STMessageHUD sharedMessageHUD].autoDismissTimer.valid) {
        [[STMessageHUD sharedMessageHUD] stopTimer];
    }
    
    [STMessageHUD sharedMessageHUD].autoDismissTimer = [NSTimer scheduledTimerWithTimeInterval:STMessageHUDShowTimeDuration target:[self class] selector:@selector(dismissWithAnimation) userInfo:nil repeats:NO];
}

#pragma mark - 事件
#pragma mark -
#pragma mark Tap 手势事件
- (void) tapAction:(UITapGestureRecognizer *)tap {
    [[STMessageHUD sharedMessageHUD] stopTimer];
    [STMessageHUD dismissWithAnimation];
}

#pragma mark - setter方法
- (void)setColorBackground:(UIColor *)colorBackground
{
    _colorBackground = colorBackground;
    [self.contentView setBackgroundColor:colorBackground];
}

#pragma mark - getter方法
/** 1.Tap 手势 */
- (UITapGestureRecognizer *)tapDouble
{
    if (!_tapDouble) {
        _tapDouble = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        _tapDouble.numberOfTapsRequired = 2;
    }
    return _tapDouble;
}

/** 2.内部视图 */
- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        
        CGFloat contentWidth = ScreenWidth / 3.0;
        _contentView.frame = CGRectMake(0,
                                        0,
                                        contentWidth,
                                        contentWidth);
        CGFloat contentCenter = ScreenWidth / 2.0;
        _contentView.center = CGPointMake(contentCenter,
                                          contentCenter);
        _contentView.layer.cornerRadius = 4;
        _contentView.layer.shadowColor = [UIColor blackColor].CGColor;
        _contentView.layer.shadowOffset = CGSizeMake(0.5, 0.5);
        _contentView.layer.shadowOpacity = 0.5;
        _contentView.layer.shadowRadius = 1.0;
    }
    return _contentView;
}

/** 3.显示"对勾"、"叉子"等图片的 ImageView */
- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        [_imageView setBackgroundColor:[UIColor clearColor]];
    }
    return _imageView;
}

/** 4.显示 Loading 图片的 ImageView */
- (UIImageView *)imageLoading
{
    if (!_imageLoading) {
        _imageLoading = [[UIImageView alloc]init];
        [_imageLoading setBackgroundColor:[UIColor clearColor]];
    }
    return _imageLoading;
}

/** 5.显示 提示文字 的 Label */
- (UILabel *)labelMessage
{
    if (!_labelMessage) {
        _labelMessage = [[UILabel alloc] init];
        [_labelMessage setFont:[UIFont systemFontOfSize:14]];
        [_labelMessage setTextAlignment:NSTextAlignmentCenter];
        [_labelMessage setNumberOfLines:4];
        [_labelMessage setAdjustsFontSizeToFitWidth:YES];
    }
    return _labelMessage;
}

@end
