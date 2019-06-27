//
//  TTExpandCircleRoundItem.h
//  TT
//
//  Created by simp on 2017/11/8.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTService/ExpandCircleService.h>


@class TTExpandUserInfoView;
@class TTExpandCircleRoundItem;

typedef NS_ENUM(NSInteger,TTExpandCircleDirection) {
    TTExpandCircleDirectionLeft,
    TTExpandCircleDirectionRight,
};

@protocol TTExpandCircleRoundItemProtocl <NSObject>

/**是否能够被拖动*/
- (BOOL)expandCircleCellCanStartDrag:(TTExpandCircleRoundItem *)item;

- (void)expandCircleDisappearRoundItem:(TTExpandCircleRoundItem *)item;

- (void)expandCircleRoundItem:(TTExpandCircleRoundItem *)item WillDisappearAt:(TTExpandCircleDirection)direction;

- (void)expandCircleItemMoveProgress:(CGFloat)progress;

/**可不可以消失*/
- (BOOL)canItemDisappear:(TTExpandCircleRoundItem *)item atDirection:(TTExpandCircleDirection)direction;

- (void)expandUser:(TTExpandUser *)user PhotoClickedAtIndex:(NSInteger)index;

- (void)expandUser:(TTExpandUser *)user PhotoClickedAtIndex:(NSInteger)index fromView:(UIView *)view;

@end

@interface TTExpandCircleRoundItem : UIView

@property (nonatomic, weak) id<TTExpandCircleRoundItemProtocl> delegate;

@property (nonatomic, strong) TTExpandUser * expandUser;

@property (nonatomic, strong, readonly) TTExpandUserInfoView * infoView;

- (void)toRightDisappear;

- (void)toLeftDisappear;

- (void)resetItem;

- (void)setProgress:(CGFloat)progress;

- (void)setColor:(UIColor *)color;
@end
