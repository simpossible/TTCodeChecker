//
//  TTExpandPhotoItem.m
//  TT
//
//  Created by simp on 2017/12/20.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandPhotoItem.h"
#import <TTThirdPartTools/Masonry.h>

@interface TTExpandPhotoItem ()

@property (nonatomic, strong) UIImageView * imageView;

@property (nonatomic, strong) UIImageView * placeHolderView;

@end

@implementation TTExpandPhotoItem


- (instancetype)init {
    if (self = [super init]) {
        [self initialUI];
    }
    return  self;
}

- (void)initialUI{
    [self initialPlaceHolder];
    [self initialImageView];
   
}

- (void)initialImageView {
    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.imageView];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)initialPlaceHolder {
    self.placeHolderView = [[UIImageView alloc] init];
    self.placeHolderView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.placeHolderView];
    [self.placeHolderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
    }];
    self.placeHolderView.hidden = YES;
}

- (void)setPlaceHolder:(UIImage *)placeHolder {
    [self.placeHolderView setImage:placeHolder];
    self.placeHolderView.hidden = NO;
}

- (void)setImage:(UIImage *)image {
    [self.imageView setImage:image];
    self.placeHolderView.hidden = !(image == nil);
}

- (BOOL)haveImage {
    return (self.imageView.image != nil);
}
/*v
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
