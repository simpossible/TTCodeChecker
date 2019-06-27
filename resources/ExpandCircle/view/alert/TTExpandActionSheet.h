//
//  TTExpandActionSheet.h
//  TT
//
//  Created by simp on 2017/11/3.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTExpandActionSheet : UIView

- (instancetype)init __unavailable; 

- (instancetype)initWithItems:(NSArray<NSString *> *)buttons andCancelTitle:(NSString *)cancelTitle;

- (void)showOnView:(UIView *)view;

@end
