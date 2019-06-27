//
//  TTExpandEmptyController.m
//  TT
//
//  Created by simp on 2018/1/2.
//  Copyright © 2018年 yiyou. All rights reserved.
//

#import "TTExpandEmptyController.h"
#import "TTRoomHomeEmptyView.h"
#import <TTThirdPartTools/Masonry.h>
#import "UIColor+TTColor_Generated.h"
#import "UIColor+Extension.h"

@interface TTExpandEmptyController ()

@property (nonatomic, strong) UIView * containerView;

@property (nonatomic, strong) UIImageView * emptyIcon;

@property (nonatomic, strong) UILabel * titleLabel;

@property (nonatomic, strong) UILabel * subTitleLabel;

@property (nonatomic, strong) UIButton * jumpButton;

@property (nonatomic, strong) TTRoomHomeEmptyView *emptyView;

@end

@implementation TTExpandEmptyController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initialUI];
    self.view.backgroundColor = [UIColor colorWithRed:245.0f/255 green:245.0f/255 blue:245.0f/255 alpha:1];
}

- (void)initialUI {
    
    [self initialContainerView];
    [self initialIcon];
    [self initialTitle];
    [self initialSubTitle];
    [self initialButton];
}

- (void)initialContainerView {
    self.containerView = [[UIView alloc] init];
    [self.view addSubview:self.containerView];
    CGFloat statuHeight = CGRectGetMaxY([[UIApplication sharedApplication]statusBarFrame]);
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(16);
        make.right.equalTo(self.view.mas_right).offset(-16);
        make.top.equalTo(self.view.mas_top).offset(44 + statuHeight + 10);
        make.height.mas_equalTo(428);
    }];
    self.containerView.backgroundColor = [UIColor whiteColor];
    self.containerView.layer.cornerRadius = 14;
    self.containerView.layer.borderWidth =1;
    self.containerView.layer.borderColor = [UIColor TTGray4].CGColor;
}

- (void)initialIcon {
    self.emptyIcon = [[UIImageView alloc] init];
    [self.containerView addSubview:self.emptyIcon];
    
    [self.emptyIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.containerView.mas_centerX);
        make.top.equalTo(self.containerView.mas_top);
    }];
    
    self.emptyIcon.image = [UIImage imageNamed:@"search_icon_blankpage"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialTitle{
    self.titleLabel = [[UILabel alloc] init];
    [self.containerView addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.containerView.mas_centerX);
        make.top.equalTo(self.emptyIcon.mas_bottom).offset(46);
        make.height.mas_equalTo(22);
    }];
    self.titleLabel.text = @"没有帮你找到最合适的人";
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    self.titleLabel.textColor = [UIColor TTGray1];
}

- (void)initialSubTitle {
    self.subTitleLabel = [[UILabel alloc] init];
    [self.view addSubview:self.subTitleLabel];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.containerView.mas_centerX);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(6);
        make.height.mas_equalTo(17);
    }];
    
    self.subTitleLabel.font = [UIFont systemFontOfSize:12];
    self.subTitleLabel.textColor = [UIColor TTGray2];
    self.subTitleLabel.text = @"重新设置下展示要求吧";
}

- (void)initialButton {
    self.jumpButton = [[UIButton alloc] init];
    [self.view addSubview:self.jumpButton];
    [self.jumpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.containerView.mas_centerX);
        make.width.mas_equalTo(246);
        make.height.mas_equalTo(44);
        make.top.equalTo(self.subTitleLabel.mas_bottom).offset(20);
    }];
    
    self.jumpButton.backgroundColor = [UIColor ARGB:0xFF4594FF];
    self.jumpButton.layer.cornerRadius = 22;
    [self.jumpButton setTitle:@"扩圈设置" forState:UIControlStateNormal];
    [self.jumpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.jumpButton addTarget:self action:@selector(jumpToSet) forControlEvents:UIControlEventTouchUpInside];
}

- (void)jumpToSet {
//    [self dismissViewControllerAnimated:YES completion:nil];
//    [self.view removeFromSuperview];
    if (self.jumpCallBack) {
        self.jumpCallBack();
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
