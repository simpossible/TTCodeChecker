//
//  TTExpandLoadingView.m
//  TT
//
//  Created by simp on 2017/11/3.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandLoadingView.h"
#import "TTExpandWaveView.h"
#import <TTThirdPartTools/Masonry.h>
#import <TTThirdPartTools/TTThirdPartTools.h>
#import <TTService.h>
#import <TTFoundation/TTFoundation.h>
#import <TTCore/TTCore.h>
#import "UIImageView+AvatarService.h"

@interface TTExpandLoadingView ()

@property (nonatomic, strong) UIView * avatorContainer;

@property (nonatomic, strong) UIView * animateview;

@property (nonatomic, strong) NSMutableArray * animaters;

@property (nonatomic, strong) UIImageView * bgView;

@property (nonatomic, strong) UIButton * errorButton;

@property (nonatomic, strong) TTExpandReLoadingCallback reloadCb;


@end

@implementation TTExpandLoadingView

- (instancetype)init {
    if (self = [super init]) {
        self.animaters = [NSMutableArray array];
        [self initialUI];
    }
    return self;
}


- (void)initialUI {
    [self initialMyAvatoraContainerView];
    [self initialAnimateView];
    [self initialAvator];
    [self initialBGView];
    [self initialErrorButton];
}

- (void)initialMyAvatoraContainerView {
    self.avatorContainer = [[UIView alloc] init];
    [self addSubview:self.avatorContainer];
    
    CGFloat barheight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    [self.avatorContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(barheight + 44 + 135);
        make.centerX.equalTo(self.mas_centerX);
        make.width.mas_equalTo(156);
        make.height.mas_equalTo(156);
    }];
    
    self.avatorContainer.layer.borderWidth = 2;
    self.avatorContainer.layer.cornerRadius = 78;
    self.avatorContainer.layer.borderColor = [[UIColor colorWithRed:172.0f/255 green:92.0f/255 blue:237.0f/255 alpha:1] CGColor];
    
    self.avatorContainer.backgroundColor = [UIColor whiteColor];
    self.avatorContainer.opaque = NO;
    
}

- (void)initialAvator {
    self.avatorView = [[UIImageView alloc] init];

    [self addSubview:self.avatorView];
    
    [self.avatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.avatorContainer.mas_centerX);
        make.centerY.equalTo(self.avatorContainer.mas_centerY);
        make.height.mas_equalTo(140);
        make.width.mas_equalTo(140);
    }];
    
    self.avatorView.backgroundColor = [UIColor yellowColor];
    self.avatorView.layer.cornerRadius = 70;
    self.avatorView.layer.masksToBounds = YES;
    [self.avatorView setImageWithAvatarForAccount:[GET_SERVICE(AuthService) myAccount]];
}

- (void)initialAnimateView {
    self.animateview = [[UIView alloc] init];
    [self insertSubview:self.animateview atIndex:0];
    
    [self.animateview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.avatorContainer.mas_centerX);;
        make.centerY.equalTo(self.avatorContainer.mas_centerY);
        make.width.mas_equalTo(600);
        make.height.mas_equalTo(600);
    }];
    
    self.animateview.layer.masksToBounds = NO;
    
}

- (void)initialErrorButton {
    self.errorButton = [[UIButton alloc] init];
    [self addSubview:self.errorButton];
    
    [self.errorButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.bottom.equalTo(self.mas_bottom).offset(-100);
        make.height.mas_equalTo(44);
        make.width.mas_greaterThanOrEqualTo(1);
    }];
    
    self.errorButton.backgroundColor = [UIColor colorWithRed:0.44 green:0 blue:0.98 alpha:1];
    self.errorButton.hidden = YES;
    [self.errorButton setTitle:@"网络出问题咯" forState:UIControlStateNormal];
    [self.errorButton addTarget:self action:@selector(errorButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.errorButton.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 20);
    self.errorButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.errorButton.layer.cornerRadius = 22;
}

- (void)initialBGView {
    self.bgView = [[UIImageView alloc] init];
    [self insertSubview:self.bgView atIndex:0];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    self.bgView.image = [UIImage imageNamed:@"kuoquan_bg_loading"];
}

- (void)startAnimate {
    
    if (self.animaters.count == 0) {
        self.errorButton.hidden = YES;
        TTExpandWaveView * wave = [[TTExpandWaveView alloc] init];
        wave.startRadiu = 0;
        wave.endRadiu  = 240;
        wave.speed = 8;
        [self.animateview addSubview:wave];
        [wave mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        
        [wave startAnimate];
        [self.animaters addObject:wave];
        
        TTExpandWaveView * wave1 = [[TTExpandWaveView alloc] init];
        wave1.startRadiu = 0;
        wave1.endRadiu  = 360;
        wave1.speed = 12;
        wave1.delay = 60;
        wave1.scale = 0.5;
        [self.animateview addSubview:wave1];
        [wave1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        [wave1 startAnimate];
        [self.animaters addObject:wave1];
    }

}


- (void)stopAnimate {
    for (TTExpandWaveView *wave in self.animaters) {
        [wave stopAnimate];
        [wave removeFromSuperview];
    }
}

- (void)showErrorWithCallBack:(TTExpandReLoadingCallback)reloadCallback {
    self.errorButton.hidden = NO;;
    self.reloadCb = reloadCallback;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)errorButtonClicked:(UIButton *)sender {
    if (self.reloadCb) {
        self.reloadCb();
        self.reloadCb = nil;
    }
}

- (void)drawRect:(CGRect)rect {

}



@end
