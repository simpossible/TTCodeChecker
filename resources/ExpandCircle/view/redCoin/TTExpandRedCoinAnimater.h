//
//  TTExpandRedCoinAnimater.h
//  TT
//
//  Created by simp on 2017/12/27.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LOTAnimationView+TT.h"

@interface TTExpandRedCoinAnimater : UIView


- (CGFloat)duration;

- (CGFloat)speed;

- (void)playWithCompletion:(nullable LOTAnimationCompletionBlock)completion;

- (instancetype)initWithRedCoin:(UInt32)redCoin;

- (void)resetRedCon:(UInt32)redCoin;

- (BOOL)isAvaliable;

@end
