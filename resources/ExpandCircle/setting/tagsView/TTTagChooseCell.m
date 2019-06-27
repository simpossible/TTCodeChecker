//
//  TTTagChooseCell.m
//  TT
//
//  Created by simp on 2017/12/26.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTTagChooseCell.h"
#import <TTThirdPartTools/Masonry.h>

@interface TTTagChooseCell()<TTTagChooseItemEvent>

@property (nonatomic, strong) UIImageView * closeImageView;

@end

@implementation TTTagChooseCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

    }
    return self;
}

- (void)setChooseItem:(TTTagChooseItem *)chooseItem {
    _chooseItem = chooseItem;
    chooseItem.delegate = self;
    self.text = chooseItem.tag;
    [self selectChanged];
    
}

- (void)initialUI {
    [super initialUI];
    [self initialCloseImage];
    
}

- (void)initialCloseImage {
    self.closeImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:self.closeImageView];
    CGFloat rate = self.frame.size.height/32.0f;
    
    [self.closeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-6);
        make.height.mas_equalTo(12*rate);
        make.width.mas_equalTo(12*rate);
        make.centerY.equalTo(self.mas_centerY);
    }];
    self.closeImageView.image = [UIImage imageNamed:@"kuoquan_icon_cancel"];
    self.closeImageView.hidden = YES;
}

- (void)selectChanged {
    [self tagSelect:self.chooseItem.selected];
}

- (void)setSelected:(BOOL)selected {

}

- (void)tagSelect:(BOOL)selected {
    [super tagSelect:selected];
    if (self.selectStyle == TTCollectionTextCellSelectStypeExpand) {
        self.closeImageView.hidden = !self.chooseItem.selected;
    }else {
        self.closeImageView.hidden = YES;
    }
}
@end
