//
//  TTExpandSetCell.h
//  TT
//
//  Created by simp on 2017/12/25.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTExpandSetCell : UITableViewCell

- (void)showArrow:(BOOL)showArrow;

- (void)setTitle:(NSString *)title;

- (void)initialUI;

- (void)dealJson:(NSDictionary *)json;
@end
