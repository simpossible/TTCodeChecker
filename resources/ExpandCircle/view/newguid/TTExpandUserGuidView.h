//
//  TTExpandUserGuidView.h
//  TT
//
//  Created by simp on 2017/11/3.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LOTAnimationView+TT.h"

@protocol TTExpandUserGuidProtocl <NSObject>

- (void)pageButtonClickedAtIndex:(NSInteger)index;

@end

@interface TTExpandUserGuidView : UIView

- (instancetype)initWithIndex:(NSInteger)index;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, weak) id<TTExpandUserGuidProtocl> delegate;

- (void)playAnimation;
@end
