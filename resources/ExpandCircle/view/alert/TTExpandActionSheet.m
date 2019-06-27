//
//  TTExpandActionSheet.m
//  TT
//
//  Created by simp on 2017/11/3.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandActionSheet.h"
#import <TTThirdPartTools/Masonry.h>

@interface TTExpandActionSheet ()

/**所有的按钮*/
@property (nonatomic, strong) NSArray<NSString *> * buttons;

@property (nonatomic, copy) NSString * cancelTitle;

@property (nonatomic, strong) UIView * containerView;

@property (nonatomic, strong) UIButton * cancelButton;

@end

@implementation TTExpandActionSheet

- (instancetype)initWithItems:(NSArray<NSString *> *)buttons andCancelTitle:(NSString *)cancelTitle {
    if (self = [super init]) {
        self.buttons = buttons;
        self.cancelTitle = cancelTitle;
        [self initialUI];
    }
    return self;
}

- (void)initialUI {
    
    [self initialContainerView];
    [self initialItems];
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
}

- (void)initialContainerView {
    self.containerView = [[UIView alloc] init];
    [self addSubview:self.containerView];
    
    self.containerView.backgroundColor = [UIColor colorWithRed:245.0f/255 green:245.0f/255 blue:245.0f/255 alpha:1];
}

- (void)initialItems {
    [self initialCancelButton];

    CGFloat beginHeight = 10;
    UIView * lastView = self.cancelButton;
    for (int i = 0; i < self.buttons.count; i ++) {
        NSString * str = [self.buttons objectAtIndex:i];
        UIButton * button = [[UIButton alloc] init];
        [self.containerView addSubview:button];
        
        [button setTitle:str forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor whiteColor];
        button.tag = i;
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.containerView.mas_left);
            make.right.equalTo(self.containerView.mas_right);
            make.height.mas_equalTo(48);
            make.bottom.equalTo(lastView.mas_top).offset(beginHeight);
        }];
        beginHeight = 0;
        lastView = button;
    }
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(lastView.mas_top);
    }];
}

- (void)initialCancelButton {
    self.cancelButton = [[UIButton alloc] init];
    [self.containerView addSubview:self.cancelButton];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView.mas_left);
        make.right.equalTo(self.containerView.mas_right);
        make.bottom.equalTo(self.containerView.mas_bottom);
        make.height.mas_equalTo(48);
    }];
}

- (void)buttonClicked:(UIButton *)sender {
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)showOnView:(UIView *)view {
    if (view) {
        [view addSubview:self];
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);;
        }];
    }
}

@end
