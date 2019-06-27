//
//  TTExpandStateView.m
//  TT
//
//  Created by simp on 2017/12/28.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandStateView.h"
#import <TTThirdPartTools/Masonry.h>
#import "UIColor+TTColor_Generated.h"
#import "UIImageView+AvatarService.h"
#import <TTService.h>
#import <TTFoundation/TTFoundation.h>
#import <TTCore/TTCore.h>
#import "UIColor+Extension.h"

@interface TTExpandStateView()<TTExpandLikedStateProtocol>

@property (nonatomic, strong) UILabel * titleLabel;

@property (nonatomic, strong) UILabel * charmLabel;

@property (nonatomic, strong) UILabel * charmCountLabel;

@property (nonatomic, strong) UILabel * likeVoice;

@property (nonatomic, strong) UIImageView * avatorView;

@property (nonatomic, strong) UIImageView * arrowView;


@end

@implementation TTExpandStateView


- (instancetype)init {
    if (self = [super init]) {
        [self initialUI];
    }
    return self;
}

- (void)initialUI {
    [self initialTitleView];
    [self initialCharmLabel];
    [self initialCharmCountLabel];
    [self initialLikeVoice];
    [self initialArrow];
    [self initialAvatorView];
    self.backgroundColor = [UIColor ARGB:0xFF4594FF];
    self.layer.cornerRadius = 4;
}

- (void)initialTitleView {
    self.titleLabel = [[UILabel alloc] init];
    [self addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(7);
        make.left.equalTo(self.mas_left).offset(16);
        make.width.mas_equalTo(37);
        make.height.mas_equalTo(25);
    }];
    
    self.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.text = @"扩圈";

}


- (void)initialCharmLabel {
    self.charmLabel = [[UILabel alloc] init];
    [self addSubview:self.charmLabel];
    
    [self.charmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(4);
        make.left.equalTo(self.titleLabel.mas_left);
        make.height.mas_equalTo(17);
    }];
    self.charmLabel.text = @"魅力值";
    self.charmLabel.textColor = [UIColor TTYellowMain];
    self.charmLabel.font = [UIFont systemFontOfSize:12];
}

- (void)initialCharmCountLabel {
    self.charmCountLabel  = [[UILabel alloc] init];
    [self addSubview:self.charmCountLabel];
    [self.charmCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.charmLabel.mas_right).offset(2);
        make.top.equalTo(self.charmLabel.mas_top);
        make.bottom.equalTo(self.charmLabel.mas_bottom);
    }];
    self.charmCountLabel.text = @"";
    self.charmCountLabel.textColor = [UIColor TTYellowMain];
    self.charmCountLabel.font = [UIFont systemFontOfSize:12];
}

- (void)initialLikeVoice {
    self.likeVoice = [[UILabel alloc] init];
    [self addSubview:self.likeVoice];
    
    [self.likeVoice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.charmLabel.mas_bottom).offset(2);
        make.left.equalTo(self.charmLabel.mas_left);
        make.height.mas_equalTo(17);
    }];
    
    self.likeVoice.font = [UIFont systemFontOfSize:12];
    self.likeVoice.textColor = [UIColor whiteColor];
}

- (void)initialArrow {
    self.arrowView = [[UIImageView alloc] init];
    [self addSubview:self.arrowView];
    
    [self.arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self.mas_right).offset(-16);
        make.width.mas_equalTo(12);
        make.height.mas_equalTo(16);
    }];
    
    self.arrowView.image = [UIImage imageNamed:@"icon_kuoquan_arrows"];
}

- (void)initialAvatorView {
    self.avatorView = [[UIImageView alloc] init];
    [self addSubview:self.avatorView];
    
    [self.avatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.arrowView.mas_left).offset(-4);
        make.centerY.equalTo(self.arrowView.mas_centerY);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(30);
    }];
    
    self.avatorView.layer.cornerRadius = 15;
    self.avatorView.layer.borderWidth = 1.5;
    self.avatorView.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.avatorView setImageWithAvatarForAccount:[GET_SERVICE(AuthService) myAccount]];
    self.avatorView.layer.masksToBounds = YES;
}

- (void)setLikeState:(TTExpandLikedState*)likeState {
    self.charmLabel.text = @"魅力值";
    self.charmCountLabel.text = [NSString stringWithFormat:@"+%ld",likeState.charm];
    self.likeVoice.text = [NSString stringWithFormat:@"%ld个人喜欢你的声音，并送了小花给你",likeState.likedCount];
    _likeState = likeState;
}


//- (void)setMeUser:(TTExpandMeUser *)meUser {
//    self.charmCountLabel.text = [NSString stringWithFormat:@"+%ld",meUser.charm];
//    self.likeVoice.text = [NSString stringWithFormat:@"%ld个人喜欢你的声音，并送了小花给你",meUser.likedCount];
//    _meUser = meUser;
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
