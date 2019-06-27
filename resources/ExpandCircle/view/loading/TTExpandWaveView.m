//
//  TTExpandWaveView.m
//  TT
//
//  Created by simp on 2017/11/3.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandWaveView.h"

@interface TTExpandWaveView ()

@property (nonatomic, strong) CADisplayLink * link;

@property (nonatomic, strong) CAShapeLayer * maskLayer;

@property (nonatomic, assign) CGFloat animateFlag;

@property (nonatomic, assign) BOOL canStart;

@property (nonatomic, strong) CAShapeLayer * borderLayer;

@end

@implementation TTExpandWaveView

- (instancetype)init {
    if (self = [super init]) {
        _canStart = NO;
//        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5];
        self.backgroundColor = [UIColor clearColor];
        _animateFlag = 0;
        _scale = 1;
    }
    return self;
}

- (void)startAnimate {
    if (!self.link) {
        self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(animating)];
        [self.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    
    if (!self.maskLayer) {
        self.maskLayer = [CAShapeLayer layer];
    }
    

}

- (void)stopAnimate {
    self.link.paused = YES;
    [self.link invalidate];
    self.link = nil;
}

- (void)animating {
    
    CGFloat rat = _startRadiu/_endRadiu;//计算动态速度
    CGFloat degreen = M_PI_2*rat;
    CGFloat muti = sin(degreen) * 0.5 + 0.5;
    
    _animateFlag += _speed * muti;
    if (_animateFlag > _delay && !_canStart) {
        _canStart = YES;
        _animateFlag = 0;
    }
    if (_canStart) {
        _animateFlag = (_animateFlag > _endRadiu)?(_animateFlag - _endRadiu):_animateFlag;
        _animateFlag = (_animateFlag <  _startRadiu)?_startRadiu:_animateFlag;
        [self changeRadiu:_animateFlag];
    }
}


- (void)changeRadiu:(CGFloat)radiu {
    CGFloat meWidth = self.frame.size.width;
    CGFloat meHeight = self.frame.size.height;
    CGFloat rat = _animateFlag / _endRadiu;
    rat = rat * M_PI_2 ;//+ M_PI_2;
    
    CGFloat mutipy = sin(rat);
    //    mutipy = 1 - mutipy;
    CGFloat width = _endRadiu * mutipy*self.scale;
    
//    self.layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:(1-mutipy)/3].CGColor;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(meWidth/2 -width, meHeight/2 - width, width*2, width*2)];
//    self.maskLayer.path = path.CGPath;
    self.borderLayer.path = path.CGPath;
    self.borderLayer.fillColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:(1-mutipy)/8].CGColor;
    self.borderLayer.strokeColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:(1-mutipy)/3].CGColor;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)drawRect:(CGRect)rect {
    if (!self.borderLayer) {
        self.borderLayer = [CAShapeLayer layer];
        self.borderLayer.backgroundColor = [UIColor clearColor].CGColor;
        self.borderLayer.fillColor = [UIColor clearColor].CGColor;
        self.borderLayer.lineWidth = 0.1;
        self.borderLayer.strokeColor = [UIColor blackColor].CGColor;
        [self.layer addSublayer:self.borderLayer];
    }
}

- (void)dealloc {
    NSLog(@"asd");
}

@end

