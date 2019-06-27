//
//  TTTagChooseItem.m
//  TT
//
//  Created by simp on 2017/12/25.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTTagChooseItem.h"

@interface TTTagChooseItem ()


@end

@implementation TTTagChooseItem

- (instancetype)initWithTag:(NSString *)tag andUserInfo:(id)userInfo {
    if (self = [super init]) {
        self.tag = tag;
        self.userInfo = userInfo;
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    if ([self.delegate respondsToSelector:@selector(selectChanged)]) {
        [self.delegate selectChanged];
    }
}

@end
