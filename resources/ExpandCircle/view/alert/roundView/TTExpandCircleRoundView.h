//
//  TTExpandCircleRoundView.h
//  TT
//
//  Created by simp on 2017/11/8.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTExpandCircleRoundItem.h"
@class TTExpandPhotoItem;

@protocol TTExpandCircleRoundProtocol <NSObject>

- (UIEdgeInsets)edgeForRoundItem;

- (void)roundItem:(TTExpandCircleRoundItem*)item insertAtIndex:(NSInteger)index;

- (void)roundItemWillDisAppear:(TTExpandCircleRoundItem*)item;

/**item 将要消失*/
- (void)expandCircleRoundItem:(TTExpandCircleRoundItem *)item WillDisappearAt:(TTExpandCircleDirection)direction;

/**是否能够被拖动*/
- (BOOL)canExpandRoundItemBedrag:(TTExpandCircleRoundItem *)item;

/**可不可以消失*/
- (BOOL)canDisappear;

- (BOOL)canRoundItemDisappear:(TTExpandCircleRoundItem *)item atDirection:(TTExpandCircleDirection)direction;

- (void)expandUser:(TTExpandUser *)user PhotoClickedAtIndex:(NSInteger)index;
- (void)expandUser:(TTExpandUser *)user PhotoClickedAtIndex:(NSInteger)index fromView:(TTExpandPhotoItem *)view;
- (void)expandUser:(TTExpandUser *)user PhotoClickedAtIndex:(NSInteger)index fromViews:(NSArray *)views;

@end

@interface TTExpandCircleRoundView : UIView

@property (nonatomic, assign) NSInteger numberOfPageToload;

@property (nonatomic, weak) id<TTExpandCircleRoundProtocol> delegate;

@property (nonatomic, strong, readonly) NSMutableArray * items;

- (void)loadView;

- (void)appendItem:(TTExpandCircleRoundItem *)item;

- (void)likeCurrent:(BOOL)like;

- (TTExpandCircleRoundItem *)FirstItem;



@end
