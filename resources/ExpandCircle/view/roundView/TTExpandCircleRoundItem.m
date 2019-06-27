//
//  TTExpandCircleCell.m
//  expandDemo
//
//  Created by simp on 2017/11/6.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandCircleRoundItem.h"
#import <TTThirdPartTools/Masonry.h>
#import "TTExpandUserInfoView.h"

@interface TTExpandCircleRoundItem ()<UIGestureRecognizerDelegate,TTExpandPhotosViewProtocol>

/**
 * 动画视图
 */
@property (nonatomic, strong) UIView * animateView;

/**
 * 最大的旋转角度
 */
@property (nonatomic, assign) CGFloat rotationAngel;

/**
 * 最大的旋转系数
 * 通过最大的旋转角度 * 旋转系数来确定具体旋转角度的
 */
@property (nonatomic, assign) CGFloat rotationPowerMax;

/**最大的旋转距离 超过这个距离不再旋转*/
@property (nonatomic, assign) CGFloat maxPandistance;

/***/
@property (nonatomic, assign) CGFloat powerLenght;

@property (nonatomic, assign) CGFloat radiuY;

@property (nonatomic, strong) CADisplayLink * dispalyLink;



@property (nonatomic, assign) CGFloat disAppearIndex;

@property (nonatomic, assign) CGFloat disAppearFlag;

@property (nonatomic, assign) CGFloat disAeeparY;

@property (nonatomic, assign) TTExpandCircleDirection currentDirection;

/**最大的浮动倍数 0.3 ： 0.7-1*/
@property (nonatomic, assign) CGFloat floatScale;

/**判断是否消失的临界值*/
@property (nonatomic, assign) CGFloat maxDisappearRate;

@end

@implementation TTExpandCircleRoundItem

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
       
    }
  
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor yellowColor];
        self.radiuY = 490;
        self.rotationAngel = M_PI/8;
        self.rotationPowerMax = 1;
        self.maxPandistance = 120;
        self.disAeeparY = 0;
        self.powerLenght = [[UIScreen mainScreen] bounds].size.width;
        self.floatScale = 0.2;
        self.maxDisappearRate = 0.3;
    }
    [self initialUI];
    [self addGesture];
    self.layer.masksToBounds = NO;
    return self;
}

- (void)initialUI {
    [self initialAnimateView];
    [self initialInfoView];
    self.backgroundColor = [UIColor clearColor];
    
}

- (void)initialAnimateView {
    self.animateView = [[UIView alloc] init];
    [self addSubview:self.animateView];
    [self.animateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)initialInfoView {
    self.infoView = [[TTExpandUserInfoView alloc] initWithType:TTExpandUserInfoTypeOther];
    [self.animateView addSubview:self.infoView];
    [self.infoView setPhotosDelegate:self];
    [self.infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

#pragma mark - 设置卡片

- (void)setExpandUser:(TTExpandUser *)expandUser {
    _expandUser = expandUser;
    if (expandUser) {
        self.infoView.hidden = NO;
    }else {
        self.infoView.hidden = YES;
    }
    self.animateView.hidden = NO;
    [self.infoView setUser:expandUser];
}


#pragma mark - 动画行为
- (void)todisAppear {
    if (self.disAppearIndex < 0) {
        [self toLeftDisappear];
    }else {
        [self toRightDisappear];
    }
}

/** 添加手势 */
- (void)addGesture {
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] init];
    pan.delegate = self;
    [pan addTarget:self action:@selector(gestureMoved:)];
    [self addGestureRecognizer:pan];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.delegate respondsToSelector:@selector(expandCircleCellCanStartDrag:)]) {
        return [self.delegate expandCircleCellCanStartDrag:self];
    }
    //    return NO;
    return YES;
}

- (void)gestureMoved:(UIPanGestureRecognizer *)pan {
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        
    }else if (pan.state == UIGestureRecognizerStateChanged) {
        [self contentToChange:pan];
        
    }else if (pan.state == UIGestureRecognizerStateEnded) {
        [self panEnded:pan];
    }
}

- (void)backToCenter {
     [self.infoView clearDirection];
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5f initialSpringVelocity:10 options:0 animations:^{
        self.animateView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        self.animateView.transform = CGAffineTransformMakeRotation(0);
    } completion:^(BOOL finished) {
    }];
}

- (void)contentToChange:(UIPanGestureRecognizer *)pan {
    CGPoint tran =  [pan translationInView:self];
    CGFloat x = tran.x;
    CGFloat y = tran.y;
    self.disAeeparY = y;
    self.disAppearIndex = x;
    [self animateWithPoint:tran];
}

- (void)panEnded:(UIPanGestureRecognizer *)end {
    CGPoint transition =  [end translationInView:self];
    CGFloat x = transition.x;
    CGFloat rotationStrength = MIN(x / self.powerLenght, self.rotationPowerMax);
    CGFloat rotationAngel = (CGFloat) (self.rotationAngel * rotationStrength);
    
    if (rotationStrength>=self.maxDisappearRate || rotationStrength <= -self.maxDisappearRate) {
        
        BOOL canDisappper = YES;
        TTExpandCircleDirection direction = x < 0?TTExpandCircleDirectionLeft:TTExpandCircleDirectionRight;
        if ([self.delegate respondsToSelector:@selector(canItemDisappear:atDirection:)]) {            
            canDisappper = [self.delegate canItemDisappear:self atDirection:direction];
        }
        
        if (canDisappper) {//可以消失
            if ([self.delegate respondsToSelector:@selector(expandCircleRoundItem:WillDisappearAt:)]) {
                [self.delegate expandCircleRoundItem:self WillDisappearAt:direction];
            }
            [self todisAppear];
        }else { //回到原点
            [self backToCenter];
            self.disAppearIndex = 0;
            self.disAeeparY = 0;
        }
    }else{
        [self backToCenter];
        self.disAppearIndex = 0;
        self.disAeeparY = 0;
    }
}

- (void)animateWithPoint:(CGPoint)transition {
    CGFloat x = transition.x;
    CGFloat y = transition.y;
    
    if (x<0) {
        [self.infoView dealCurrentDirection:TTExpandCircleDirectionLeft];
    }
    if (x > 0) {
        [self.infoView dealCurrentDirection:TTExpandCircleDirectionRight];
    }
    
    if (x == 0) {
        [self.infoView clearDirection];
    }
    
    y = self.frame.size.height/2 + transition.y;

    NSLog(@"the center is %@",NSStringFromCGPoint(self.animateView.center));
    CGFloat abx = fabs(x);//绝对值
    CGFloat rotationStrength = MIN(abx / self.powerLenght, self.rotationPowerMax);
    NSInteger flag = x<0?-1:1;
    CGFloat rotationAngel = (CGFloat) (self.rotationAngel * rotationStrength*flag);
    
    if ([self.delegate respondsToSelector:@selector(expandCircleItemMoveProgress:)]) {
        CGFloat progress = rotationStrength>=self.maxDisappearRate?1:(fabs(rotationStrength)/self.maxDisappearRate);
        [self.delegate expandCircleItemMoveProgress:progress];
    }
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
    
    self.animateView.transform = transform;
    
    CGPoint center=self.animateView.center;
    x = self.frame.size.width/2 + x;
    center.y=y-(30)*fabs(x/self.maxPandistance)*0.6;//此处的0.6同上
    center.x = x;
    self.animateView.center=center;
    
}

- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint oldOrigin = view.frame.origin;
    view.layer.anchorPoint = anchorPoint;
    CGPoint newOrigin = view.frame.origin;
    
    CGPoint transition;
    transition.x = newOrigin.x - oldOrigin.x;
    transition.y = newOrigin.y - oldOrigin.y;
    
    view.center = CGPointMake (view.center.x - transition.x, view.center.y - transition.y);
}

- (void)toRightDisappear {
    if (!self.dispalyLink) {
        self.dispalyLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(disAppearGoing)];
        
        self.disAppearFlag = 15;
        [self.dispalyLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    
}

- (void)toLeftDisappear {
    if (!self.dispalyLink) {
        self.dispalyLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(disAppearGoing)];
        self.disAppearFlag = -15;
        [self.dispalyLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)disAppearGoing {
    self.disAppearIndex += self.disAppearFlag;
    CGFloat index = fabs(self.disAppearIndex);
    if (index > self.frame.size.width+ 100) {
        [self.dispalyLink invalidate];
        [self.dispalyLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        self.dispalyLink = nil;
        self.disAppearIndex = 0;
        self.disAeeparY = 0;
        self.dispalyLink = nil;
        CGAffineTransform transform = CGAffineTransformMakeRotation(0);

        CGPoint center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        self.animateView.center = center;
        self.animateView.transform = transform;
        self.animateView.hidden = YES;
        [self.infoView audioReset];
        [self.infoView clearDirection];
        if ([self.delegate respondsToSelector:@selector(expandCircleDisappearRoundItem:)]) {
            [self.delegate expandCircleDisappearRoundItem:self];
        }
        [self setProgress:0];
        return;
    }
    [self animateWithPoint:CGPointMake(self.disAppearIndex, self.disAeeparY)];
}

- (void)resetItem {
    self.dispalyLink = nil;
    self.animateView.hidden = NO;
    [self setProgress:0]; 
}

- (void)setProgress:(CGFloat)progress {
    CGFloat scale = self.floatScale *progress + 1 - self.floatScale;
    CGAffineTransform trans = CGAffineTransformMakeScale(scale, scale);
//    CGAffineTransform trans = CGAffineTransformScale(self.animateView.transform, scale, scale);
    self.animateView.transform = trans;
    [self layoutIfNeeded];
}

- (void)setColor:(UIColor *)color {
    self.animateView.backgroundColor = color;
}

- (BOOL)canItemDisappear:(TTExpandCircleRoundItem *)item atDirection:(TTExpandCircleDirection)direction {
    if ([self.delegate respondsToSelector:@selector(canItemDisappear:atDirection:)]) {
        return [self.delegate canItemDisappear:item atDirection:direction];
    }
    return YES;
}

#pragma mark - 图片被点击的事件

- (void)photoCoosedAtIndex:(NSInteger)index withItem:(TTExpandPhotoItem *)item {
    if ([self.delegate respondsToSelector:@selector(expandUser:PhotoClickedAtIndex:fromView:)]) {
        [self.delegate expandUser:self.infoView.user PhotoClickedAtIndex:index fromView:item];
    }
}

#pragma mark - setter

- (void)setInfoView:(TTExpandUserInfoView *)infoView {
    _infoView = infoView;
}

@end

