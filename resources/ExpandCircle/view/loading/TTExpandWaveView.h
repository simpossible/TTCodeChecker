//
//  TTExpandWaveView.h
//  TT
// 波浪动画
//  Created by simp on 2017/11/3.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTExpandWaveView : UIView

@property (nonatomic, assign) CGFloat startRadiu;

@property (nonatomic, assign) CGFloat endRadiu;

/**每次增加的速度*/
@property (nonatomic, assign) CGFloat speed;

@property (nonatomic, assign) CGFloat delay;

@property (nonatomic, assign) CGFloat scale;

- (void)startAnimate;

- (void)stopAnimate;

- (void)changeRadiu:(CGFloat)radiu;

@end
