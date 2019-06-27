//
//  TTExpandSetCell.m
//  TT
//
//  Created by simp on 2017/12/25.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandSetCell.h"
#import <TTThirdPartTools/Masonry.h>
#import "UIColor+TTColor_Generated.h"
#import "UIColor+Extension.h"

@interface TTExpandSetCell ()

/**标题栏*/
@property (nonatomic, strong) UILabel * titleLabel;

/**箭头*/
@property (nonatomic, strong) UIImageView * arrowView;

/**在箭头旁边显示详情的label*/
@property (nonatomic, strong) UILabel * detailLabel;

@end

@implementation TTExpandSetCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initialUI];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (void)initialUI {
    [self initialTitleLabel];
    [self initialArrowView];
    [self initialDetailLabel];
}

- (void)initialTitleLabel {
    self.titleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY).offset(-1);
        make.left.equalTo(self.contentView.mas_left).offset(16);
        make.height.mas_equalTo(20);
    }];
    
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.textColor = [UIColor TTGray1];
}

- (void)initialArrowView {
    self.arrowView = [[UIImageView alloc] init];
    [self.contentView addSubview:self.arrowView];
    
    [self.arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY).offset(-1);
        make.right.equalTo(self.contentView.mas_right).offset(-16);
    }];
    self.arrowView.image = [UIImage imageNamed:@"icon_arrows_all"];
}

- (void)initialDetailLabel {
    self.detailLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.detailLabel];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.arrowView.mas_left).offset(-4);
        make.centerY.equalTo(self.arrowView.mas_centerY);
        make.height.mas_equalTo(18);
    }];
    self.detailLabel.font = [UIFont systemFontOfSize:13];
    self.detailLabel.textColor = [UIColor ARGB:0xFFB9B9B9];
}

- (void)dealJson:(NSDictionary *)json {
    NSString *title = [json objectForKey:@"title"];
    [self setTitle:title];
    
    NSString *detail = [json objectForKey:@"detail"];
    self.detailLabel.text = detail;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)showArrow:(BOOL)showArrow {
    self.arrowView.hidden = !showArrow;
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}
@end
