//
//  TTExpandAlert.m
//  TT
//
//  Created by simp on 2017/11/7.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandAlert.h"
#import <TTThirdPartTools/Masonry.h>

@interface TTExpandAlert ()

@property (nonatomic, strong) UIView * containerView;

@property (nonatomic, strong) UIImageView * imgView;

@property (nonatomic, strong) UILabel * messageLabel;

@property (nonatomic, strong) UIButton * jumpButton;

@property (nonatomic, strong) UIButton * closeButoon;


@end

@implementation TTExpandAlert


- (instancetype)init {
    if (self = [super init]) {
        [self initialUI];
    }
    return self;
}

- (void)initialUI {
    [self initialContainerView];
    [self initialImgView];
    [self initialMessageLabel];
    [self initialJumpButton];
    [self initialCloseButton];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
 
}



- (void)initialContainerView {
    self.containerView = [[UIView alloc] init];
    [self addSubview:self.containerView];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_offset(280);
        make.height.mas_equalTo(310);
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
    }];
    self.containerView.backgroundColor = [UIColor colorWithRed:0.36 green:0.08 blue:1 alpha:1];
    self.containerView.layer.cornerRadius = 4;
    self.containerView.layer.masksToBounds = YES;
    
}

- (void)initialCloseButton {
    self.closeButoon = [[UIButton alloc] init];
    [self.containerView addSubview:self.closeButoon];
    
    [self.closeButoon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.containerView.mas_right).offset(-8);
        make.top.equalTo(self.containerView.mas_top).offset(8);
        make.height.mas_equalTo(24);
        make.width.mas_equalTo(24);
    }];
    
    UIImage *close = [UIImage imageNamed:@"kuoquan_icon_dislike"];
    [self.closeButoon setImage:close forState:UIControlStateNormal];
    self.closeButoon.layer.cornerRadius = 12;
    self.closeButoon.layer.masksToBounds = YES;
    self.closeButoon.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    self.closeButoon.imageEdgeInsets = UIEdgeInsetsMake(3.7, 3.6, 3.7, 3.6);
    [self.closeButoon addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initialImgView {
    self.imgView = [[UIImageView alloc] init];
    [self.containerView addSubview:self.imgView];
    
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.containerView.mas_centerX);
        make.top.equalTo(self.containerView.mas_top).offset(22);
        make.height.mas_equalTo(174);
        make.width.mas_equalTo(164);
    }];
}

- (void)initialMessageLabel {
    self.messageLabel = [[UILabel alloc] init];
    [self.containerView addSubview:self.messageLabel];
    
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView.mas_left);
        make.right.equalTo(self.containerView.mas_right);
        make.top.equalTo(self.imgView.mas_bottom).offset(20);;
    }];

    self.messageLabel.numberOfLines = 0;
    self.messageLabel.font = [UIFont systemFontOfSize:14];
    self.messageLabel.textColor = [UIColor whiteColor];
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    
}

- (void)initialJumpButton {
    self.jumpButton = [[UIButton alloc] init];
    [self.containerView addSubview:self.jumpButton];
    
    [self.jumpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.containerView.mas_right);
        make.left.equalTo(self.containerView.mas_left);
        make.height.equalTo(40);
        make.bottom.equalTo(self.containerView.mas_bottom);
    }];
    self.jumpButton.backgroundColor  = [UIColor colorWithRed:0.24 green:0.01 blue:0.78 alpha:1];
    self.jumpButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.jumpButton addTarget:self action:@selector(jumpButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setInfo:(NSString *)info {
    self.messageLabel.text = info;
}

- (void)setButtonTitle:(NSString *)buttonTitle {
    [self.jumpButton setTitle:buttonTitle forState:UIControlStateNormal];
}

- (void)setImage:(UIImage *)image {
    self.imgView.image = image;
}

- (void)jumpButtonClicked:(UIButton *)sender {
    [self removeFromSuperview];
    if (self.callback) {
        self.callback();
        self.callback = nil;
    }
}


- (void)closeButtonClicked:(UIButton *)sender {
    if (self.cancelCallBack) {
        self.cancelCallBack();
    }
    [self removeFromSuperview];
}


- (void)showOnView:(UIView *)view {
    [view addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
