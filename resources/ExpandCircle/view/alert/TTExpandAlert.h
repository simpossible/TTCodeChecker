//
//  TTExpandAlert.h
//  TT
//
//  Created by simp on 2017/11/7.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTExpandAlert;
typedef void  (^TTExpandAlertCallBcak)();

@interface TTExpandAlert : UIView

@property (nonatomic, copy) NSString * _Nonnull info;

@property (nonatomic, copy) NSString * _Nonnull buttonTitle;

@property (nonatomic, strong) UIImage * image;

- (void)showOnView:(UIView * _Nonnull)view;

@property (nonatomic, copy, nullable) TTExpandAlertCallBcak callback;

@property (nonatomic, copy, nullable) TTExpandAlertCallBcak cancelCallBack;

@end
