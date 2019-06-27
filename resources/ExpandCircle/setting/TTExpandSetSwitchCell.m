//
//  TTExpandSetSwitchCell.m
//  TT
//
//  Created by simp on 2017/12/25.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandSetSwitchCell.h"
#import <TTThirdPartTools/Masonry.h>
#import "UIColor+TTColor_Generated.h"

@interface TTExpandSetSwitchCell ()

@property (nonatomic, strong) UISwitch * switcher;

@end

@implementation TTExpandSetSwitchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
 
    }
    return self;
}

- (void)initialUI {
    [super initialUI];
    [self initialSwitcher];
    [self showArrow:NO];
}


- (void)initialSwitcher {
    self.switcher = [[UISwitch alloc] init];
    [self.contentView addSubview:self.switcher];
    
    [self.switcher mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY).offset(-1);
        make.right.equalTo(self.contentView.mas_right).offset(-16);
        make.width.mas_equalTo(48);
        make.height.mas_equalTo(25);
    }];
    
    [self.switcher addTarget:self action:@selector(switcherChanged:) forControlEvents:UIControlEventValueChanged];
}

/**设置状态*/
- (void)setSwitched:(BOOL)switched {
    [self.switcher setOn:switched];
}

- (void)switcherChanged:(id)sender {
    if ([self.delegate respondsToSelector:@selector(switcherStateChanged:)]) {
        [self.delegate switcherStateChanged:self.switcher.on];
    }
}

- (void)dealJson:(NSDictionary *)json {
    [super dealJson:json];
    
    BOOL autoplay =  [[json objectForKey:@"autoPlay"] integerValue];
    self.switcher.on = autoplay;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    // Configure the view for the selected state
}

@end
