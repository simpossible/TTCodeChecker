//
//  TTExpandCircleRoundView.m
//  TT
//
//  Created by simp on 2017/11/8.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandCircleRoundView.h"
#import <TTThirdPartTools/Masonry.h>

@interface TTExpandCircleRoundView ()<TTExpandCircleRoundItemProtocl>

@property (nonatomic, assign) UIEdgeInsets itenEdge;

@property (nonatomic, strong) TTExpandCircleRoundItem * secondItem;

@end

@implementation TTExpandCircleRoundView

- (instancetype)init {
    if (self = [super init]) {
        self.numberOfPageToload = 3;
    }
    return self;
}

- (void)initialUI {
    
}

- (void)loadView {
    if (!self.items) {
        self.items = [NSMutableArray array];
        [self addSubview:[UIView new]];
        UIEdgeInsets edge = UIEdgeInsetsZero;
        if ([self.delegate respondsToSelector:@selector(edgeForRoundItem)]) {
            edge = [self.delegate edgeForRoundItem];
        }
        self.itenEdge = edge;
        for (int i = 0 ; i < self.numberOfPageToload; i ++) {
            TTExpandCircleRoundItem *item = [[TTExpandCircleRoundItem alloc] init];
            [self insertSubview:item atIndex:0];
            
            [item mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(edge);
            }];
            
            [item setProgress:0];
            item.delegate = self;
            [self.items addObject:item];
            
            if ([self.delegate respondsToSelector:@selector(roundItem:insertAtIndex:)]) {
                [self.delegate roundItem:item insertAtIndex:i];
            }
        }
        self.secondItem = [self.items objectAtIndex:1];
        TTExpandCircleRoundItem *item = [self.items objectAtIndex:0];
        [item setProgress:1];
    }else {
        for (int i = 0 ; i < self.items.count; i ++) {
            TTExpandCircleRoundItem *item = [self.items objectAtIndex:i];
            if ([self.delegate respondsToSelector:@selector(roundItem:insertAtIndex:)]) {
                [self.delegate roundItem:item insertAtIndex:i];
            }
            [item setProgress:0];
        }
        
        self.secondItem = [self.items objectAtIndex:1];
        TTExpandCircleRoundItem *item = [self.items objectAtIndex:0];
        [item setProgress:1];
    }
}

- (BOOL)expandCircleCellCanStartDrag:(TTExpandCircleRoundItem *)item {
    if ([self.delegate respondsToSelector:@selector(canExpandRoundItemBedrag:)]) {
        return [self.delegate canExpandRoundItemBedrag:item];
    }
    return YES;
}

- (void)expandCircleDisappearRoundItem:(TTExpandCircleRoundItem *)item  {
    [item removeFromSuperview];
    [self insertSubview:item atIndex:0];
    [item mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.itenEdge);
    }];
    [item resetItem];
    
    [self.secondItem setProgress:1];
    
    [self.items removeObject:item];
    [self.items addObject:item];
    
    self.secondItem = self.items[1];
    
    if ([self.delegate respondsToSelector:@selector(roundItem:insertAtIndex:)]) {
        [self.delegate roundItem:item insertAtIndex:self.numberOfPageToload-1];
    }
}

- (void)expandCircleRoundItem:(TTExpandCircleRoundItem *)item WillDisappearAt:(TTExpandCircleDirection)direction {
    if ([self.delegate respondsToSelector:@selector(expandCircleRoundItem:WillDisappearAt:)]) {
        [self.delegate expandCircleRoundItem:item WillDisappearAt:direction];
    }
}

- (void)appendItem:(TTExpandCircleRoundItem *)item {
    
}

- (void)expandCircleItemMoveProgress:(CGFloat)progress {
    [self.secondItem setProgress:progress];
}

- (BOOL)canItemDisappear:(TTExpandCircleRoundItem *)item atDirection:(TTExpandCircleDirection)direction {
    if ([self.delegate respondsToSelector:@selector(canRoundItemDisappear:atDirection:)]) {
        return  [self.delegate canRoundItemDisappear:item atDirection:direction];
    }
    return YES;
}

- (void)expandUser:(TTExpandUser *)user PhotoClickedAtIndex:(NSInteger)index fromViews:(NSArray *)views{
    if ([self.delegate respondsToSelector:@selector(expandUser:PhotoClickedAtIndex:fromViews:)]) {
        [self.delegate expandUser:user PhotoClickedAtIndex:index fromViews:views];
    }
}

#pragma mark - 哈哈

- (TTExpandCircleRoundItem *)FirstItem {
    if (self.items.count >0) {
        return [self.items objectAtIndex:0];
    }
    return nil;
}

- (void)setItems:(NSMutableArray *)items {
    _items = items;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
