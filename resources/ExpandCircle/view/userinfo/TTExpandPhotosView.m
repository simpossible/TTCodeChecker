//
//  TTExpandPhotosView.m
//  TT
//
//  Created by simp on 2017/11/2.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandPhotosView.h"
#import <TTThirdPartTools/Masonry.h>
#import <TTThirdPartTools/UIImageView+WebCache.h>
#import "UIColor+Extension.h"
#import "TTExpandPhotoItem.h"

@interface TTExpandPhotosView ()

@property (nonatomic, strong) TTExpandPhotoItem * leftView;

@property (nonatomic, strong) UIView * rightView;

@property (nonatomic, strong) NSMutableArray * imagesViewArray;

/**只有一张的情况下 有个大的显示视图*/
@property (nonatomic, strong) TTExpandPhotoItem * bigView;


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
    self.backgroundColor = [UIColor ARGB:0xf2f2f2];
    self.layer.masksToBounds = YES;
    [self initialBigView];
}

- (void)initialBigView {
    self.bigView = [[TTExpandPhotoItem alloc] init];
    [self addSubview:self.bigView];
    
    [self.bigView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    self.bigView.tag = 0;
    [self.bigView addTarget:self action:@selector(picTureclicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initialLeftView {
    self.leftView = [[TTExpandPhotoItem alloc] init];
    [self addSubview:self.leftView];
    
    [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.top.equalTo(self.mas_top);
        make.width.equalTo(self.mas_width).multipliedBy(231/343.0f);
        make.bottom.equalTo(self.mas_bottom);
    }];
    [self.leftView setContentMode:UIViewContentModeScaleAspectFill];
    [self.imagesViewArray addObject:self.leftView];
    self.leftView.tag = 0;
    [self.leftView addTarget:self action:@selector(picTureclicked:) forControlEvents:UIControlEventTouchUpInside];
    
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
        TTExpandPhotoItem *img = [[TTExpandPhotoItem alloc] init];
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
        if (i == 1) {
            img.backgroundColor = [UIColor ARGB:0xf5f5f5];
        }else {
            img.backgroundColor = [UIColor ARGB:0xf2f2f2];
        }
        lastView = img;
        [img setContentMode:UIViewContentModeScaleAspectFill];
        img.userInteractionEnabled = YES;
        img.layer.masksToBounds = YES;
        img.tag = i+1;
        [img addTarget:self action:@selector(picTureclicked:) forControlEvents:UIControlEventTouchUpInside];

        [self.imagesViewArray addObject:img];
        
    }
}

- (void)setImage:(UIImage *)image AtIndex:(NSInteger)index {
    if (index < self.imagesViewArray.count) {
        TTExpandPhotoItem *imgView = [self.imagesViewArray objectAtIndex:index];
        [imgView setImage:image];
    }
}

- (void)resetALLImage {
    for (TTExpandPhotoItem *img in self.imagesViewArray) {
        [img setImage:nil];
    }
}

- (void)picTureclicked:(TTExpandPhotoItem *)control {
    
    if ([self.delegate respondsToSelector:@selector(photoCoosedAtIndex:withItem:)]) {
        [self.delegate photoCoosedAtIndex:control.tag withItem:control];
    }
    if ([self.delegate respondsToSelector:@selector(photoCoosedAtIndex:withItems:)]) {
        if (self.bigView.hidden) {
            [self.delegate photoCoosedAtIndex:control.tag withItems:self.imagesViewArray];
        }else{
            [self.delegate photoCoosedAtIndex:control.tag withItems:@[self.bigView]];
        }
    }
}

- (void)setType:(TTExpandUserInfoType)type {
    UIImage *placeHolder;
    if (type == TTExpandUserInfoTypeOther) {
        self.bigView.hidden = NO;
    }else {
        self.bigView.hidden = YES;
        placeHolder = [UIImage imageNamed:@"kuoquan_edit_icon_add"];
    }
    for (TTExpandPhotoItem *img in self.imagesViewArray) {
        [img setPlaceHolder:placeHolder];
    }
}

- (void)setBigImage:(UIImage *)image {
    if (image) {
        self.bigView.hidden = NO;
        [self.bigView setImage:image];
    }else {
        self.bigView.hidden = YES;
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
