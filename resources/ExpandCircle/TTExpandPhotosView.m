//
//  TTExpandPhotosView.m
//  TT
//
//  Created by simp on 2017/11/2.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandPhotosView.h"
#import <TTThirdPartTools/Masonry.h>

@interface TTExpandPhotosView ()

@property (nonatomic, strong) UIImageView * leftView;

@property (nonatomic, strong) UIView * rightView;

@property (nonatomic, strong) NSMutableArray * imagesViewArray;

@end

@implementation TTExpandPhotosView


- (instancetype)init {
    if (self = [super init]) {
        self.imagesViewArray = [NSMutableArray array];
        [self initialUI];
    }
    return self;
}


- (void)initialUI {
    [self initialLeftView];
    [self initialRightView];
}

- (void)initialLeftView {
    self.leftView = [[UIImageView alloc] init];
    [self addSubview:self.leftView];
    
    [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.top.equalTo(self.mas_top);
        make.width.equalTo(self.mas_width).multipliedBy(228/340.0f);
        make.height.equalTo(self.mas_height).multipliedBy(340/336.0f);
    }];
    
    self.rightView.backgroundColor = [UIColor orangeColor];
    [self.imagesViewArray addObject:self.leftView];
    
}

- (void)initialRightView {
    self.rightView = [UIView new];
    [self addSubview:self.rightView];
    
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftView.mas_right);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
    }];
    
    [self initialRightSmallViews];
    
}

- (void)initialRightSmallViews {
    UIView *lastView = nil;
    for (int i = 0 ; i < 3; i ++) {
        UIImageView *img = [[UIImageView alloc] init];
        [self.rightView addSubview:img];
        
        [img mas_makeConstraints:^(MASConstraintMaker *make) {
            if (!lastView) {
                make.top.equalTo(self.rightView.mas_top);
            }else {
                make.top.equalTo(lastView.mas_bottom);
                make.height.equalTo(lastView.mas_height);
            }
            make.width.equalTo(self.rightView.mas_width);
            
            make.left.equalTo(self.rightView.mas_left);
            if (i == 2) {
                make.bottom.equalTo(self.rightView.mas_bottom);
            }
        }];
        lastView = img;
        img.backgroundColor = [UIColor colorWithRed:0.1 green:0.2 blue:1.0f/(i+1) alpha:1];
        [self.imagesViewArray addObject:img];
        
       
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
