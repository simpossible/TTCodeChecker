//
//  TTTagChooseView.h
//  TT
//  以前为搜索写的只是重用了最小的cell - 整个视图的重用写一个复用性广的
//  Created by simp on 2017/12/25.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTCollectionTextLayout.h"
#import "TTCollectionTextCell.h"
#import "TTTagChooseItem.h"

@protocol TTTagChooseViewProtocol <NSObject>

- (CGFloat)heightForTag;

- (UIEdgeInsets)marginForTag;

- (CGFloat)widhtForChooseView;

- (UIEdgeInsets)marginForChooseView;

/**目前支持左右padding*/
- (UIEdgeInsets)paddingForTag;

/**如果到达最大的数量还选会走这个*/
- (void)maxTagSelectNumberReached;

- (BOOL)canBeSelectAfterMaxWithTag:(TTTagChooseItem *)item;

- (void)tagItemChoosed:(TTTagChooseItem *)item;

- (void)tagItemDeChoosed:(TTTagChooseItem *)item;

- (UIColor *)defaultBgColorForChooseView;
- (UIColor *)selectedBgColorForChooseView;
- (UIColor *)selectedTextColorForChooseView;
- (UIColor *)defaultTextColorForChooseView;


@end

@protocol TTTagChooseItemProtocol <NSObject>



@end

@interface TTTagChooseView : UIView

- (instancetype)initWithItems:(NSArray<TTTagChooseItem *> *)items;

@property (nonatomic, weak) id<TTTagChooseViewProtocol> delegate;

/**最多可被选中的个数*/
@property (nonatomic, assign) NSInteger maxSelectNumber;

@property (nonatomic, assign) CGFloat fontSize;

@property (nonatomic, assign) TTCollectionTextCellSelectStype tagSelectType;

- (void)layoutView;

/**根据布局计算出来的高度*/
- (CGFloat)dataHeight;

- (void)resetItems:(NSArray<TTTagChooseItem *> *)items;

@end
