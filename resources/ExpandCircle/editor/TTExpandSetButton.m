//
//  TTExpandSetButton.m
//  TT
//
//  Created by simp on 2017/12/20.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandSetButton.h"
#import <TTThirdPartTools/Masonry.h>
#import "UIColor+Extension.h"
#import "UIColor+TTColor_Generated.h"

@interface TTExpandSetButton ()

@property (nonatomic, strong) UILabel * titleLabel;

@property (nonatomic, strong) UIImageView * arrowView;

@end

@implementation TTExpandSetButton

- (instancetype)init {
    if (self = [super init]) {
        [self initialUI];
    }
    return self;
}

- (void)initialUI {
    [self initialTitleLabel];
    [self initialArrowView];
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 9;
    self.layer.borderWidth =1;
    self.layer.borderColor = [UIColor TTGray4].CGColor;
}

- (void)initialTitleLabel {
    self.titleLabel = [[UILabel alloc] init];
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self.mas_left).offset(10);
        make.height.mas_equalTo(25);
    }];
    
    self.titleLabel.text = @"扩圈设置";
    self.titleLabel.textColor = [UIColor TTGray1];
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    
}

- (void)initialArrowView {
    self.arrowView = [[UIImageView alloc] init];
    [self addSubview:self.arrowView];
    
    [self.arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self.mas_right).offset(-14);
        make.width.mas_equalTo(12);
        make.height.mas_equalTo(16);
    }];
    
    self.arrowView.image = [UIImage imageNamed:@"icon_arrows_all"];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
