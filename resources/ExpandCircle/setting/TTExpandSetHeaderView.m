//
//  TTExpandSetHeaderView.m
//  TT
//
//  Created by simp on 2017/12/25.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandSetHeaderView.h"
#import <TTThirdPartTools/Masonry.h>
#import "UIColor+TTColor_Generated.h"
#import "UIColor+Extension.h"
@interface TTExpandSetHeaderView()

@property (nonatomic, strong)  UILabel * titleLabel;
@end

@implementation TTExpandSetHeaderView

- (instancetype)initWithTitle:(NSString *)title{
    if (self = [super init]) {
        [self initialUI];
        self.titleLabel.text = title;
    }
    return self;
}

- (void)initialUI {
    [self initialTitleLabel];
}

- (void)initialTitleLabel {
    self.titleLabel = [[UILabel alloc] init];
    [self addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).offset(-7);
        make.left.equalTo(self.mas_left).offset(16);
        make.height.mas_equalTo(17);
    }];
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    self.titleLabel.textColor = [UIColor ARGB:0xFFB9B9B9];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
