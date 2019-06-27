//
//  TTExpandUserGuidView.m
//  TT
//
//  Created by simp on 2017/11/3.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandUserGuidView.h"
#import <TTThirdPartTools/Masonry.h>
#import "UIKit+Extension.h"

@interface TTExpandUserGuidView ()

@property (nonatomic, strong) LOTAnimationView * mainAnimationView;

@property (nonatomic, strong) LOTAnimationView * subAnimationView;

@property (nonatomic, strong) UIButton * nextButton;

@property (nonatomic, strong) UILabel * tiplabel;

/**保证居中*/
@property (nonatomic, strong) UIView * containerView;
@end

@implementation TTExpandUserGuidView


- (instancetype)initWithIndex:(NSInteger)index{
    if (self = [super init]) {
        
        self.index = index;
        [self initialUI];
    }
    return self;
}


- (void)initialUI {
    [self initialContainerView];
    [self initialAnimationView];
    [self initialTipLabel];
    [self initialNextButton];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainAnimationView.mas_centerY);
        make.bottom.equalTo(self.tiplabel.mas_bottom);
        make.center.equalTo(self);
        make.left.equalTo(self.mas_left).offset(10);
        make.right.equalTo(self.mas_right).offset(-10);
    }];
}

- (void)initialContainerView {
    self.containerView = [[UIView alloc] init];
    [self addSubview:self.containerView];
    
}

- (void)initialAnimationView {
    NSArray * mainAnimations = @[@"expand_guide_1_1",@"expand_guide_2_1"];//主动画
    NSArray * subAnimations = @[@"expand_guide_1_2",@"expand_guide_2_2"];//辅动画
    
    //加载主动画
    NSString *mainAnimation= mainAnimations[self.index];
    self.mainAnimationView = [LOTAnimationView animationNamed:mainAnimation rootDir:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"assets/TTLOTLocalResource/expand_guide"] subDir:mainAnimation];
    self.mainAnimationView.loopAnimation = NO;
    self.mainAnimationView.userInteractionEnabled = NO;
    
    //加载副动画
    NSString *subAnimation = subAnimations[self.index];
    self.subAnimationView = [LOTAnimationView animationNamed:subAnimation rootDir:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"assets/TTLOTLocalResource/expand_guide"] subDir:subAnimation];
    self.subAnimationView.loopAnimation = NO;
    self.subAnimationView.userInteractionEnabled = NO;
    
    [self.containerView addSubview:self.mainAnimationView];
    [self.containerView addSubview:self.subAnimationView];
    
    CGFloat mainRatio = self.mainAnimationView.bounds.size.height / self.mainAnimationView.bounds.size.width;
    CGFloat subRatio = self.subAnimationView.bounds.size.height / self.subAnimationView.bounds.size.width;
    
    //主动画布局
    [self.mainAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.mas_equalTo(350);
        make.height.mas_equalTo(350 * mainRatio);
        make.centerX.equalTo(self.containerView.mas_centerX);
    }];
    
    //副动画布局
    switch (self.index) {
        case 0:{
            [self.subAnimationView makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(350);
                make.height.mas_equalTo(350 * subRatio);
                make.centerX.equalTo(self.mainAnimationView.mas_centerX);
                make.top.equalTo(self.mainAnimationView.mas_bottom);
            }];
            break;
        }
        case 1:{
            [self.subAnimationView makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(350);
                make.height.mas_equalTo(350 * subRatio);
                make.centerX.mas_equalTo(self.mainAnimationView.mas_centerX).offset(5);
                make.centerY.mas_equalTo(self.mainAnimationView.mas_centerY).offset(30);
            }];
            break;
        }
        default:
            break;
    }
}

- (void)initialTipLabel {
    
    NSArray * tips = @[@"左滑表“不喜欢”，右滑表示“喜欢”",@"每天有 3 次免费送花机会，送花还有机会获得100倍红钻回馈噢！"];//所有显示的tip
    
    self.tiplabel = [[UILabel alloc] init];
    [self.containerView addSubview:self.tiplabel];
    
    self.tiplabel.text = tips[self.index];
    self.tiplabel.numberOfLines = 0;    
    self.tiplabel.textColor = [UIColor whiteColor];
    self.tiplabel.textAlignment = NSTextAlignmentCenter;
    self.tiplabel.font = [UIFont systemFontOfSize:15];
    
    switch (self.index) {
        case 0:{
            [self.tiplabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.containerView.mas_centerX);
                make.top.equalTo(self.subAnimationView.mas_bottom).offset(10);
            }];
            break;
        }
        case 1:{
            
            UILabel *titleLabel = [[UILabel alloc]init];
            [self.containerView addSubview:titleLabel];
            
            titleLabel.numberOfLines = 0;
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.font = [UIFont systemFontOfSize:20];
            
            titleLabel.text = [NSString stringWithFormat:@"相互赠花，匹配成功"];
            
            [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.containerView.mas_centerX);
                make.top.equalTo(self.mainAnimationView.mas_bottom).offset(50);
            }];
            
            
            [self.tiplabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.containerView.mas_centerX);
                make.width.mas_equalTo(261);
                make.top.equalTo(titleLabel.mas_bottom).offset(10);
            }];
            break;
        }
        default:
            break;
    }
}

- (void)initialNextButton {
    self.nextButton = [[UIButton alloc] init];
    
    switch (self.index) {
        case 0:
            [self.nextButton setTitle:@"下一步" forState:UIControlStateNormal];
            break;
        case 1:
            [self.nextButton setTitle:@"OK，秒懂" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    
    
    [self.nextButton setBackgroundColor: [UIColor colorWithRed:72/255.0 green:86/255.0 blue:255/255.0 alpha:1/1.0]];
    [self.nextButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
    
    [self addSubview:self.nextButton];
    
    CGRect screen = [[UIScreen mainScreen]bounds];
    CGFloat bottomOffset = -72.0 / 667.0 * screen.size.height;
    
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.bottom.equalTo(self.mas_bottom).offset(bottomOffset);
        make.width.mas_equalTo(206);
        make.height.mas_equalTo(44);
    }];
    self.nextButton.layer.cornerRadius = 20;
    self.nextButton.titleLabel.font = [UIFont systemFontOfSize:16];

    [self.nextButton addTarget:self action:@selector(toNextStep:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)toNextStep:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(pageButtonClickedAtIndex:)]) {
        [self.delegate pageButtonClickedAtIndex:self.index];
        
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)playAnimation{
    [self.mainAnimationView play];
    [self.subAnimationView play];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
}

@end
