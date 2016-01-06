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



static NSString *const STMessageHUDImageCheck          = @"checkmark";
static NSString *const STMessageHUDImageCross          = @"cross";
static NSString *const STMessageHUDImageProgress       = @"progress";

static NSString *const STMessageHUDImageCheckWhite     = @"checkmark_white";
static NSString *const STMessageHUDImageCrossWhite     = @"cross_white";
static NSString *const STMessageHUDImageProgressWhite  = @"progress_white";

static NSString *const STMessageHUDImageKeyCheck       = @"Check";
static NSString *const STMessageHUDImageKeyCross       = @"Cross";
static NSString *const STMessageHUDImageKeyProgress    = @"Progress";

static NSString *const STMessageHUDSuccessAnimationKey = @"SuccessAnimation";
static NSString *const STMessageHUDErrorAnimationKey   = @"ErrorAnimation";


/** Loading 的默认文字信息 */
static NSString *const STMessageHUDLoadingMessage = @"加载中...";

/** 1.状态栏和导航栏的高度和 */
static CGFloat const STNavgationBarHeight = 64;

/** 2.在导航栏下方的默认高度 */
static CGFloat const STNavigationDefaultHeight = 50;

/** 3.在状态栏模式下的默认高度 */
static CGFloat const STStatusBarDefaultHeight = 20;

/** 3.控件之间的间隔 */
static CGFloat const STMargin = 10;




@interface STMessageHUD ()


/** 用来判断是否已经展示 */
@property (nonatomic, assign) BOOL isShow;


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

/** 7.是否需要图片视图动画 */
@property (nonatomic, assign) BOOL needImageAnimation;

/** 8.成功时, 放大缩小的动画 */
@property (nonatomic, strong, nullable)CAKeyframeAnimation *animationSuccess;

/** 9.失败时, 抖动的动画 */
@property (nonatomic, strong, nullable)CAKeyframeAnimation *animationError;

/** 10.等待时, 旋转的动画 */
@property (nonatomic, strong, nullable)CABasicAnimation *animationRotation;

/** 11.定时器, 自定消失 */
@property (nonatomic, strong) NSTimer *timerAutoDismiss;

/** 12.警示框的最大宽度 */
@property (nonatomic, assign) CGFloat widthMax;

/** 13.图片 */
@property (nonatomic, strong, nullable)UIImage *imageHud; //

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
    _widthMax = ScreenWidth / 2;
    _showStyle = STHUDShowStyleNormal;
    _duration = 0.2;
    _timeStay = 1.6;
    _messageType = STHUDMessageTypeLoading;
    
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
- (void) reloadData
{
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

#pragma mark - 视图显示
- (void)show {
    [self stopTimer];
    [STMessageHUDSingleton messageHUDShowWithMessage:STMessageHUDLoadingMessage
                              image:self.dictionaryImage[STMessageHUDImageKeyProgress]
                          showStyle:self.showStyle
                        messageType:self.messageType];
}


#pragma mark 动画隐藏
- (void) dismissWithAnimation
{
    [STMessageHUDSingleton messageHUDHideWithShowStyle:self.showStyle
                                             animation:YES];
}
#pragma mark 显示文字, 然后隐藏
- (void) dismissWithMessage:(NSString *)message
                messageType:(STHUDMessageType)messageType
{
    UIImage *imageShow;
    
    switch (messageType) {
        case STHUDMessageTypeSuccess:
            imageShow = self.dictionaryImage[STMessageHUDImageKeyCheck];break;
        case STHUDMessageTypeError:
            imageShow = self.dictionaryImage[STMessageHUDImageKeyCross];break;
        default:break;
    }
    
    self.needImageAnimation = YES;
    [self setupContentWithMessage: message
                                image: imageShow
                          messageType: messageType];
    [self timerAutoDismiss];
}

#pragma mark 提示错误信息,  默认的 ShowStyle = STHUDShowStyleNormal
+ (void) showErrorMessage:(NSString *)message {
    [STMessageHUD showErrorMessage:message showStyle: STHUDShowStyleNormal];
}

#pragma mark 提示错误信息
+ (void) showErrorMessage:(NSString *)message showStyle:(STHUDShowStyle)showStyle {
    [STMessageHUDSingleton messageHUDShowWithMessage: message
                                               image: STMessageHUDSingleton.dictionaryImage[STMessageHUDImageKeyCross]
                                           showStyle: showStyle
                                         messageType: STHUDMessageTypeError];
    
    [STMessageHUDSingleton startTimer];
}

#pragma mark 提示成功信息,  默认的 ShowStyle = STHUDShowStyleNormal
+ (void) showSuccessMessage:(NSString *)message {
    [STMessageHUD showSuccessMessage: message
                           showStyle: STHUDShowStyleNormal];
}

#pragma mark 提示成功信息
+ (void) showSuccessMessage:(NSString *)message showStyle:(STHUDShowStyle)showStyle {
    [STMessageHUDSingleton messageHUDShowWithMessage: message
                                               image: STMessageHUDSingleton.dictionaryImage[STMessageHUDImageKeyCheck]
                                           showStyle: showStyle
                                         messageType: STHUDMessageTypeSuccess];
    [STMessageHUDSingleton startTimer];
}



#pragma mark - 播放不同信息时的动画
- (void)animationWithMessageType:(STHUDMessageType)messageType
{
    switch (messageType) {
        case STHUDMessageTypeSuccess:
            [self.imageView.layer addAnimation: self.animationSuccess
                                        forKey: STMessageHUDSuccessAnimationKey];
            break;
        case STHUDMessageTypeError:
            [self.imageView.layer addAnimation: self.animationError
                                        forKey: STMessageHUDErrorAnimationKey];
        default:
            break;
    }
}

#pragma mark - 移除控件状态
- (void)removeDataState{
    [self removeUIAnimations];
    
    [self.labelMessage setText:@""];
    [self setIsShow:NO];
    [self setAlpha:0];
}

#pragma mark - 移除控件动画
- (void)removeUIAnimations
{
    [self.imageLoading.layer removeAllAnimations];
    [self.imageView.layer removeAllAnimations];
}


#pragma mark - 隐藏STMessageHUD
- (void)messageHUDHideWithShowStyle:(STHUDShowStyle)showStyle
                          animation:(BOOL)needAnimation{
    
    // 1. 关闭用户交互
    self.userInteractionEnabled = NO;
    
    // 2. 根据 ShowStyle, 设置 UI, 进行隐藏动画
    switch (showStyle) {
        case STHUDShowStyleNormal:
        {
            if (needAnimation) {
                [UIView animateWithDuration: self.duration
                                      delay: 0
                                    options: UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                    [self setAlpha:0.0];
                    self.contentView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                } completion:^(BOOL finished) {
                    self.contentView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                }];
            } else {
                
            }
            
            [self removeDataState];
        }
            break;
            
        case STHUDShowStyleNavigationBar:
        {
            if (needAnimation) {
                [UIView animateWithDuration: self.duration
                                      delay: 0
                                    options: UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                    [self setAlpha:0.0];
                    self.contentView.transform = CGAffineTransformMakeScale(1.0, 0.1);
                } completion:^(BOOL finished) {
                    self.contentView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                }];
            } else {
               
            }
            
            [self removeDataState];
            
        }
            break;
            
        case STHUDShowStyleStatusBar:
        {
            if (needAnimation) {
                [UIView animateWithDuration: self.duration
                                      delay: 0
                                    options: UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                     [self setAlpha:0.0];
                } completion:^(BOOL finished) {
                }];
            } else {
                
            }
            
            [self removeDataState];
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

#pragma mark - 动画显示STMessageHUD
- (void) messageHUDShowWithMessage:(NSString *)message
                             image:(UIImage *)image
                         showStyle:(STHUDShowStyle)showStyle
                       messageType:(STHUDMessageType)messageType
{
    @synchronized(self)  {
        if (self.isShow) {
            [self messageHUDHideWithShowStyle: STHUDShowStyleNormal
                                    animation: NO];
        }
        self.isShow = YES;
        
        // 0. 保存 ShowStyle
        self.showStyle = showStyle;
        
        
        // 2. 根据 ShowStyle, 设置 UI, 进行动画显示
        switch (showStyle) {
            case STHUDShowStyleNormal:
            {
                // 3. 设置显示内容
                [self setupContentWithMessage: message image: image messageType: messageType];
                
                // 4. 播放动画
                self.contentView.transform = CGAffineTransformMakeScale(0.2, 0.2);
                [UIView animateWithDuration:self.duration
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                    self.alpha = 1.0;
                    self.contentView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                } completion:^(BOOL finished) {
                    [self animationWithMessageType: messageType];
                }];
            }
                break;
                
            case STHUDShowStyleNavigationBar:
            {
                // 3. 设置显示内容
                [self setupContentWithMessage: message image: image messageType: messageType];
                
                // 4. 播放动画
                self.contentView.transform = CGAffineTransformMakeScale(1.0, 0.0);
                [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.alpha = 1.0;
                    self.contentView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                } completion:^(BOOL finished) {
                    
                    [self animationWithMessageType: messageType];
                }];
            }
                break;
                
            case STHUDShowStyleStatusBar:
            {
                // 3. 设置显示内容
                [self setupContentWithMessage: message image: image messageType: messageType];
                
                // 4. 动画显示
                [UIView animateWithDuration:self.duration*2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
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

#pragma mark - 配置显示内容 (适用于: STHUDShowStyleStatusBar)
- (void)setupStatusBarWithImage:(UIImage *)image
{
    // 1.停止动画
    [self.imageLoading.layer removeAllAnimations];
    [self.imageView.layer removeAllAnimations];
    
    // 2.设置 Label 位置
    CGFloat messageW = self.contentView.bounds.size.width - 2*STMargin;
    CGFloat messageH = STStatusBarDefaultHeight;
    self.labelMessage.frame = CGRectMake(0,
                                         0,
                                         messageW,
                                         messageH);
}

#pragma mark - 配置显示内容 (适用于: STHUDShowStyleNavigationBar)
- (void)setupNavigationBarrWithMessage:(NSString *)message
                                 image:(UIImage *)image
                           messageType:(STHUDMessageType)messageType
{
    // 1.停止动画
    [self.imageLoading.layer removeAllAnimations];
    [self.imageView.layer removeAllAnimations];
    
    // 2.设置图片位置
    CGFloat scale = image.size.width / image.size.height;
    CGFloat imageX = STMargin;
    CGFloat imageY = STMargin;
    CGFloat imageH = STNavigationDefaultHeight - STMargin*2;
    CGFloat imageW = scale * imageH;
    self.imageLoading.frame = CGRectMake(imageX, imageY, imageW, imageH);
    self.imageView.frame = self.imageLoading.frame;
    
    // 3.设置文本视图位置
    CGFloat messageX = CGRectGetMaxX(self.imageLoading.frame)+STMargin;
    CGFloat messageY = 0;
    CGFloat messageW = self.contentView.bounds.size.width - 2*STMargin - imageW;
    CGFloat messageH = self.contentView.frame.size.height;
    self.labelMessage.frame = CGRectMake(messageX, messageY, messageW, messageH);
    
    // 4.显示或隐藏 Loading ImageView
    if ([message isEqualToString: STMessageHUDLoadingMessage]) {
        
        self.imageLoading.hidden = NO;
        self.imageView.hidden = YES;
        
        [self.imageLoading.layer addAnimation: self.animationRotation  forKey: STMessageHUDLoadingMessage];
    } else {
        self.imageLoading.hidden = YES;
        self.imageView.hidden = NO;
    }
    
    // 5. 设置显示内容
    self.imageView.image = image;
    self.imageLoading.image = self.dictionaryImage[STMessageHUDImageKeyProgress];
    
    // 6. 播放 ImageView 动画
    if (self.needImageAnimation) {
        self.needImageAnimation = NO;
        [self animationWithMessageType: messageType];
    }

}

#pragma mark 配置显示内容 (适用于: STHUDShowStyleNormal 和 STHUDShowStyleNavigationBar)
- (void) setupContentWithMessage:(NSString *)message image:(UIImage *)image messageType:(STHUDMessageType)messageType {
    
    if (self.showStyle == STHUDShowStyleStatusBar) {
        [self setupStatusBarWithImage:image];
        return;
    }
    
    if (self.showStyle == STHUDShowStyleNavigationBar) {
        [self setupNavigationBarrWithMessage:message image:image messageType:messageType];
        return;
    }
    
    // 1.停止动画
     [self removeUIAnimations];
    
    // 2.图片的尺寸
    CGFloat imageW = image.size.width;
    CGFloat imageH = image.size.height;
    
    // 2.计算message的Size
    CGSize sizeMessage = [message boundingRectWithSize:CGSizeMake(imageW + 2 * STMargin, MAXFLOAT)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName : self.labelMessage.font}
                                               context:nil].size;
    
    
    // 3.计算STMessageHUD的Size
    CGFloat hudH = sizeMessage.height + imageH + 4 * STMargin;
    CGFloat hudW = hudH < self.widthMax ? hudH : self.widthMax;
    
    // 4.计算文本框的Size
    CGSize sizeLabel = [message boundingRectWithSize:CGSizeMake(hudW + 2 * STMargin, MAXFLOAT)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName : self.labelMessage.font}
                                             context:nil].size;
    // 5.如果计算后的Label高度小于之前Label的高度, 则Self的高度应该减去一个差值
    if (sizeLabel.height < sizeMessage.height) {
        hudH -= (sizeMessage.height - sizeLabel.height);
    }
    
    // 6.设置UI控件的位置
    [UIView animateWithDuration: self.duration
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        
        // 7.设置内容视图的大小
        self.contentView.bounds = (CGRect){CGPointZero, {hudW, hudH}};
        
        // 8. 设置Image的Frame
        CGFloat imageX = (self.contentView.bounds.size.width - imageW) / 2.0;
        CGFloat imageY = STMargin;
        self.imageView.frame = CGRectMake(imageX,
                                          imageY,
                                          imageW,
                                          imageH);
        self.imageLoading.frame = self.imageView.frame;
        
        // 9. 设置Label的位置
        CGFloat messageX = STMargin;
        CGFloat messageY = CGRectGetMaxY(self.imageView.frame) + STMargin;
        CGFloat messageW = self.contentView.bounds.size.width - 2*STMargin;
        CGFloat messageH = sizeLabel.height;
        self.labelMessage.frame = CGRectMake(messageX,
                                             messageY,
                                             messageW,
                                             messageH);
    } completion:^(BOOL finished) {}];

    // 10. 显示或隐藏 Loading ImageView
    if ([message isEqualToString: STMessageHUDLoadingMessage]) {
        
        self.imageLoading.hidden = NO;
        self.imageView.hidden = YES;

        [self.imageLoading.layer addAnimation: self.animationRotation
                                       forKey: STMessageHUDLoadingMessage];
    } else {
        self.imageLoading.hidden = YES;
        self.imageView.hidden = NO;
    }
    
    // 11. 设置显示内容
    self.imageView.image = image;
    self.imageLoading.image = self.dictionaryImage[STMessageHUDImageKeyProgress];
    
    // 12. 播放 ImageView 动画
    if (self.needImageAnimation) {
        self.needImageAnimation = NO;
        [self animationWithMessageType: messageType];
    }
}


#pragma mark - 开启定时器
- (void) startTimer
{
    if (self.timerAutoDismiss.valid) {
        [self stopTimer];
    }
    [self timerAutoDismiss];
}
#pragma mark - 停止定时器
- (void) stopTimer
{
    [self.timerAutoDismiss invalidate];
    self.timerAutoDismiss = nil;
}

#pragma mark - Tap的手势事件
- (void) tapAction:(UITapGestureRecognizer *)tap
{
    [self stopTimer];
    [self dismissWithAnimation];
}

#pragma mark - setter方法
/** 1.设置内部视图的背景色 */
- (void)setColorBackground:(UIColor *)colorBackground
{
    _colorBackground = colorBackground;
    [self.contentView setBackgroundColor:colorBackground];
}

/** 2.是否需要双击手势, 双击手势默认行为: Dismiss 掉 STMessageHUD */
- (void)setNeedDoubleTap:(BOOL)needDoubleTap
{
    _needDoubleTap = needDoubleTap;
    self.userInteractionEnabled = needDoubleTap;
}

/** 3.STMessageHUD 的出现样式 */
- (void)setShowStyle:(STHUDShowStyle)showStyle
{
    if (_showStyle != showStyle) {
        _showStyle = showStyle;
        [self reloadData];
    }
    
    
    
    
}

/** 4.动画展示的持续时间 */
- (void)setDuration:(CGFloat)duration
{
    _duration = duration;
}
/** 5.提示信息的停留时间 */

- (void)setTimeStay:(CGFloat)timeStay
{
    _timeStay = timeStay;
}

/** 6.提示信息 */
- (void)setMessage:(NSString *)message
{
    _message = message;
    [self.labelMessage setText:message];
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

/** 6.用来存放 "对勾""叉子"等 图片的字典 */
- (NSMutableDictionary *)dictionaryImage
{
    if (!_dictionaryImage) {
        _dictionaryImage = @{STMessageHUDImageKeyCheck:[UIImage imageNamed:STMessageHUDImageCheck],
                             STMessageHUDImageKeyCross:[UIImage imageNamed:STMessageHUDImageCross],
                             STMessageHUDImageKeyProgress:[UIImage imageNamed:STMessageHUDImageProgress]}.mutableCopy;
        
    }
    return _dictionaryImage;
}

/** 8.成功时, 放大缩小的动画 */
- (CAKeyframeAnimation *)animationSuccess
{
    if (!_animationSuccess) {
        _animationSuccess = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        _animationSuccess.values = @[@1.2, @0.8, @1.0];
        _animationSuccess.duration = 0.25f;
    }
    return _animationSuccess;
}

/** 9.失败时, 抖动的动画 */
- (CAKeyframeAnimation *)animationError
{
    if (!_animationError) {
        _animationError = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
        _animationError.values = @[@(-2), @(2), @(-2), @(2), @(-2), @(2), @(0)];
        _animationError.duration = 0.25f;
    }
    return _animationError;
}

/** 10.等待时, 旋转的动画 */
- (CABasicAnimation *)animationRotation
{
    if (!_animationRotation) {
        _animationRotation = [CABasicAnimation animationWithKeyPath: @"transform.rotation.z" ];
        _animationRotation.fromValue = @(0.0);
        _animationRotation.toValue = @( 100 * M_PI );
        _animationRotation.repeatCount = HUGE_VALF;
        _animationRotation.duration = 36.0f;
        _animationRotation.autoreverses = YES;
    }
    return _animationRotation;
}

/** 11.定时器, 自定消失 */
- (NSTimer *)timerAutoDismiss
{
    if (!_timerAutoDismiss) {
        _timerAutoDismiss = [NSTimer scheduledTimerWithTimeInterval:self.timeStay
                                                             target:self
                                                           selector:@selector(dismissWithAnimation)
                                                           userInfo:nil
                                                            repeats:NO];
    }
    return _timerAutoDismiss;
}
@end
