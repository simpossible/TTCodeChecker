//
//  TTExpandRollingView.m
//  TT
//
//  Created by simp on 2017/12/21.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandRollingView.h"
#import <TTThirdPartTools/Masonry.h>

@interface TTExpandRollingView ()

@property (nonatomic, strong) UIImageView * imageView;

@property (nonatomic, strong) CADisplayLink * link;

@property (nonatomic, assign) CGFloat angle;

@property (nonatomic, assign) CGFloat speed;

@end

@implementation TTExpandRollingView

- (instancetype)init {
    if (self = [super init]) {
        [self initialUI];
        [self initialData];
    }
    return self;
}

- (void)initialData {
    self.speed = M_PI/30;
}

- (void)initialUI {
    [self initialImageView];
    self.userInteractionEnabled = NO;
}

- (void)initialImageView {
    self.imageView = [[UIImageView alloc] init];
    [self addSubview:self.imageView];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}


- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)startRolling {
     self.hidden = NO;
    if (!self.link) {
        self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(rolling)];
        [self.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)stopRolling {
    [self.link invalidate];
    self.hidden = YES;
    self.link = nil;
}

- (void)rolling {
    _angle +=self.speed;
    self.imageView.transform = CGAffineTransformMakeRotation(_angle);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
