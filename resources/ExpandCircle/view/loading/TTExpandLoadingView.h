//
//  TTExpandLoadingView.h
//  TT
// 加载视图
//  Created by simp on 2017/11/3.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TTExpandReLoadingCallback)();

@interface TTExpandLoadingView : UIView

@property (nonatomic, strong) UIImageView * avatorView;

- (void)startAnimate;

- (void)stopAnimate;

- (void)showErrorWithCallBack:(TTExpandReLoadingCallback)reloadCallback;
@end
