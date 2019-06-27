//
//  TTExpandRedCoinAnimater.m
//  TT
//
//  Created by simp on 2017/12/27.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandRedCoinAnimater.h"
#import "LOTAnimationView+TT.h"
#import <TTThirdPartTools/Masonry.h>

@interface TTExpandRedCoinAnimater()

@property (nonatomic, strong) LOTAnimationView * animateView;

@property (nonatomic, assign) UInt32 redCoin;

@end

@implementation TTExpandRedCoinAnimater

- (instancetype)initWithRedCoin:(UInt32)redCoin {
    if (self = [super init]) {
        _redCoin = redCoin;
        [self initialUI];
    }
    return self;
}

- (void)initialUI {
    [self initialLotiView];
}

- (void)initialLotiView {
    NSString *subDir =  nil;
    NSString *jsonName= nil;
    if (_redCoin == 500) {
        subDir = @"500";
        jsonName =@"500.json";
    }else if (_redCoin == 20) {
        subDir = @"20";
        jsonName =@"20.json";
    }
    else if (_redCoin == 100) {
        subDir = @"100";
        jsonName =@"100.json";
    }
    else if (_redCoin == 1000) {
        subDir = @"1000";
        jsonName =@"1000.json";
    }
    if (jsonName) {
         self.animateView = [LOTAnimationView animationNamed:jsonName rootDir:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"assets/TTLOTLocalResource/expand_guide/expand_reddiamond"] subDir:subDir];
         [self addSubview:self.animateView];
        
        [self.animateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }

    self.hidden = YES;
}

- (void)resetRedCon:(UInt32)redCoin {
    [self.animateView removeFromSuperview];
    _redCoin = redCoin;
    [self initialLotiView];
}

- (CGFloat)duration {
    return self.animateView.animationDuration;
}

- (CGFloat)speed {
    return self.animateView.animationSpeed;
}
- (void)playWithCompletion:(LOTAnimationCompletionBlock)completion {
    __weak typeof(self)wself = self;
    wself.hidden =NO;
    [self.animateView playToProgress:1 withCompletion:^(BOOL animationFinished) {
        wself.hidden = YES;
        if (completion) {
            completion(animationFinished);
        }
    }];
}

- (BOOL)isAvaliable {
    return self.animateView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
