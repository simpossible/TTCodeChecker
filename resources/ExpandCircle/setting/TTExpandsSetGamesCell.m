//
//  TTExpandsSetGamesCell.m
//  TT
//
//  Created by simp on 2017/12/25.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandsSetGamesCell.h"
#import "UIColor+Extension.h"
#import "TTTagChooseView.h"
#import <TTThirdPartTools/Masonry.h>
#import <TTService/ExpandCircleService.h>
#import <TTService/ExpandCircleService.h>
@interface TTExpandsSetGamesCell()<TTTagChooseViewProtocol>

@property (nonatomic, strong) TTTagChooseView * tagChooseView;

@end

@implementation TTExpandsSetGamesCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setTags:(NSArray *)tags {
    if (_tags != tags) {
        _tags = tags;
        NSMutableArray *itemArray = [NSMutableArray array];
        for (TTExpandGame *ttgame in tags) {
            TTTagChooseItem *item = [[TTTagChooseItem alloc] initWithTag:ttgame.gameName andUserInfo:ttgame];
            [itemArray addObject:item];
        }
        if (!self.tagChooseView) {
            self.tagChooseView = [[TTTagChooseView alloc] initWithItems:itemArray];
            self.tagChooseView.tagSelectType = TTCollectionTextCellSelectStypeNone;
            self.tagChooseView.delegate = self;
            
            [self.contentView addSubview:self.tagChooseView];
            [self.tagChooseView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(UIEdgeInsetsZero);
            }];
            [self.tagChooseView layoutView];
        }else {
            [self.tagChooseView resetItems:itemArray];
        }
    }
}

#pragma mark -标签布局

- (CGFloat)heightForTag {
    return 32;
}

- (UIEdgeInsets)marginForTag {
    return UIEdgeInsetsMake(6, 6, 6, 6);
}

- (UIEdgeInsets)marginForChooseView {
    return UIEdgeInsetsMake(4, 10, 4, 10);
}

/**目前支持左右padding*/
- (UIEdgeInsets)paddingForTag {
    return UIEdgeInsetsMake(0, 22, 0, 22);
}

#pragma mark - 外部接口

- (CGFloat)currentHeight {
    return self.tagChooseView.dataHeight;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
