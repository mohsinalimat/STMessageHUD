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

/** 1.状态栏和导航栏的高度和 */
static CGFloat const STNavgationBarHeight = 64;

/** 2.在导航栏下方的默认高度 */
static CGFloat const STNavigationDefaultHeight = 50;

/** 3.在状态栏模式下的默认高度 */
static CGFloat const STStatusBarDefaultHeight = 20;

/** 3.控件之间的间隔 */
static CGFloat const STMargin = 10;


/** 动画展示的时间 */
static CGFloat const STMessageHUDShowDuration = 0.2;

/** 提示信息停留时间 */
static CGFloat const STMessageHUDShowTimeDuration = 1.6;


/** Loading 的默认文字信息 */
static NSString *const STMessageHUDLoadingMessage = @"加载中...";

@interface STMessageHUD ()





/** 最大宽度 */
@property (nonatomic, assign) CGFloat maxWidth;

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

/** 6.用来存放 "对勾""叉子"等 图片的字典 */
@property (nonatomic, strong) NSMutableDictionary *dictionaryImage;

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
    [self setAlpha:0.0];
    [self makeKeyAndVisible];

    // 4.设置默认数据
    _colorBackground = [UIColor orangeColor];
    _needDoubleTap = YES;
    _maxWidth = ScreenWidth / 2;
    _showStyle = STHUDShowStyleNormal;

    // 2.添加子视图
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.imageLoading];
    [self.contentView addSubview:self.labelMessage];

    // 3.添加手势
    [self addGestureRecognizer:self.tapDouble];



    // 5.载入视图数据
    [self reloadData];
}

#pragma mark - 载入视图数据
- (void) reloadData {
    switch (self.showStyle) {
        case STHUDShowStyleNormal:
        {
            self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
            self.windowLevel = UIWindowLevelNormal;

            CGFloat contentWidth = ScreenWidth / 3.0;
            self.contentView.frame = CGRectMake(0, 0, contentWidth, contentWidth);
            self.contentView.center = self.center;
            self.contentView.layer.cornerRadius = 4;
        }
            break;

        case STHUDShowStyleNavigationBar:
        {
            self.frame = CGRectMake(0, STNavgationBarHeight, ScreenWidth, STNavigationDefaultHeight);
            self.windowLevel = UIWindowLevelNormal;
            self.contentView.frame = (CGRect) {CGPointZero, self.frame.size};
            self.contentView.layer.cornerRadius = 0;
        }
            break;

        case STHUDShowStyleStatusBar:
        {
            self.frame = CGRectMake(0, 0, ScreenWidth, STStatusBarDefaultHeight);
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
- (void) show {
    [STMessageHUDSingleton stopTimer];
    [STMessageHUDSingleton showMessageHUDWithMessage: STMessageHUDLoadingMessage
                                               image: STMessageHUDSingleton.dictionaryImage[STMessageHUDImageKeyProgress]
                                           showStyle: STHUDShowStyleNormal messageType: STHUDMessageTypeLoading];
}
#pragma mark 隐藏
- (void) dismiss {

    [STMessageHUDSingleton hideMessageHUDWithShowStyle: STMessageHUDSingleton.showStyle animation: NO];
}
#pragma mark 动画隐藏
+ (void) dismissWithAnimation {
    [STMessageHUDSingleton hideMessageHUDWithShowStyle: STMessageHUDSingleton.showStyle animation: YES];
}
#pragma mark 显示文字, 然后隐藏
+ (void) dismissWithMessage:(NSString *)message messageType:(STHUDMessageType)messageType {

    STMessageHUD *messageHUD = [STMessageHUD sharedMessageHUD];

    UIImage *showImage = nil;

    switch (messageType) {
        case STHUDMessageTypeSuccess:
        {
            showImage = messageHUD.dictionaryImage[STMessageHUDImageKeyCheck];
        }
            break;

        case STHUDMessageTypeError:
        {
            showImage = messageHUD.dictionaryImage[STMessageHUDImageKeyCross];
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

    [messageHUD showMessageHUDWithMessage: message image: messageHUD.dictionaryImage[STMessageHUDImageKeyCross] showStyle: showStyle messageType: STHUDMessageTypeError];

    [messageHUD startTimer];
}

#pragma mark 提示成功信息,  默认的 ShowStyle = STHUDShowStyleNormal
+ (void) showSuccessMessage:(NSString *)message {
    [STMessageHUD showSuccessMessage: message showStyle: STHUDShowStyleNormal];
}

#pragma mark 提示成功信息
+ (void) showSuccessMessage:(NSString *)message showStyle:(STHUDShowStyle)showStyle {

    STMessageHUD *messageHUD = [STMessageHUD sharedMessageHUD];

    [messageHUD showMessageHUDWithMessage: message image: messageHUD.dictionaryImage[STMessageHUDImageKeyCheck] showStyle: showStyle messageType: STHUDMessageTypeSuccess];

    [messageHUD startTimer];
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
- (void) reloadDataState {

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
                    [self reloadDataState];
                }];
            } else {
                [self reloadDataState];
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
                    [self reloadDataState];
                }];
            } else {
                [self reloadDataState];
            }
        }
            break;

        case STHUDShowStyleStatusBar:
        {
            if (needAnimation) {
                [UIView animateWithDuration: STMessageHUDShowDuration delay: 0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.alpha = 0.0;
                } completion:^(BOOL finished) {
                    [self reloadDataState];
                }];
            } else {
                [self reloadDataState];
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
    self.labelMessage.frame = CGRectMake(0, 0, self.contentView.bounds.size.width - 2*STMargin, 20);

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
    CGFloat imageHeight = STNavigationDefaultHeight - STMargin*2;
    CGFloat imageWidth = scale * imageHeight;
    self.imageLoading.frame = CGRectMake(STMargin, STMargin, imageWidth, imageHeight);
    self.imageView.frame = self.imageLoading.frame;

    // 2. 设置 Label 位置
    self.labelMessage.frame = CGRectMake(CGRectGetMaxX(self.imageLoading.frame)+STMargin, 0, self.contentView.bounds.size.width - 2*STMargin - imageWidth, self.contentView.frame.size.height);

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
    self.imageLoading.image = self.dictionaryImage[STMessageHUDImageKeyProgress];

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
    CGFloat labelMessageHeight = [message boundingRectWithSize: CGSizeMake(image.size.width + 2*STMargin, MAXFLOAT)
                                                       options: NSStringDrawingUsesLineFragmentOrigin
                                                    attributes: @{NSFontAttributeName : self.labelMessage.font}
                                                       context: nil].size.height + STMargin;

    // 2. 获取 Image 的高度
    CGFloat imageHeight = image.size.height;

    // 3. 计算并设置 STMessageHUD 的 bounds
    CGFloat height = labelMessageHeight + imageHeight + 3*STMargin;
    CGFloat width = height<self.maxWidth ? height : self.maxWidth;

    // 4. 宽度计算完成后, 再计算一次 Label 的高度
    CGFloat currentHeight = [message boundingRectWithSize: CGSizeMake(width - 2*STMargin, MAXFLOAT)
                                                  options: NSStringDrawingUsesLineFragmentOrigin
                                               attributes: @{NSFontAttributeName : self.labelMessage.font}
                                                  context: nil].size.height + STMargin;

    // 5. 如果计算后的 Label 高度 小于 之前 Label 的高度, 则 Self 的高度应该减去一个差值
    if (currentHeight < labelMessageHeight) {
        height -= (labelMessageHeight - currentHeight);
    }

    // 6. 设置 UI 控件的位置
    [UIView animateWithDuration: STMessageHUDShowDuration delay:0 options: UIViewAnimationOptionCurveEaseInOut animations:^{

        // 7. 设置 内容视图的大小
        self.contentView.bounds = (CGRect){CGPointZero, {width, height}};

        // 8. 设置 Image 的 Frame
        self.imageView.frame = CGRectMake((self.contentView.bounds.size.width - image.size.width) * 0.5, STMargin, image.size.width, imageHeight);
        self.imageLoading.frame = self.imageView.frame;

        // 9. 设置 Label 的 位置
        self.labelMessage.frame = CGRectMake(STMargin, CGRectGetMaxY(self.imageView.frame) + STMargin, self.contentView.bounds.size.width - 2*STMargin, currentHeight);
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
    self.imageLoading.image = self.dictionaryImage[STMessageHUDImageKeyProgress];

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
/** 1.设置内部视图的背景色 */
- (void)setColorBackground:(UIColor *)colorBackground
{
    _colorBackground = colorBackground;
    [self.contentView setBackgroundColor:colorBackground];
}

- (void)setNeedDoubleTap:(BOOL)needDoubleTap
{
    _needDoubleTap = needDoubleTap;

    self.userInteractionEnabled = needDoubleTap;
}

- (void)setShowStyle:(STHUDShowStyle)showStyle
{
    if (_showStyle != showStyle) {
        _showStyle = showStyle;
        [self reloadData];
    }
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
        [_contentView setBackgroundColor:self.colorBackground];
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
        [_labelMessage setTextColor:[UIColor whiteColor]];
        [_labelMessage setTextAlignment:NSTextAlignmentCenter];
        [_labelMessage setNumberOfLines:4];
        [_labelMessage setAdjustsFontSizeToFitWidth:YES];
    }
    return _labelMessage;
}

- (NSMutableDictionary *)dictionaryImage
{
    if (!_dictionaryImage) {
        _dictionaryImage = @{STMessageHUDImageKeyCheck:[UIImage imageNamed:STMessageHUDImageCheck],
                             STMessageHUDImageKeyCross:[UIImage imageNamed:STMessageHUDImageCross],
                             STMessageHUDImageKeyProgress:[UIImage imageNamed:STMessageHUDImageProgress]}.mutableCopy;
        
    }
    return _dictionaryImage;
}

@end
