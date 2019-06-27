//
//  TTTagChooseItem.h
//  TT
//
//  Created by simp on 2017/12/25.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TTTagChooseItemEvent <NSObject>

- (void)selectChanged;

@end

@interface TTTagChooseItem : NSObject

@property (nonatomic) id userInfo;

@property (nonatomic, assign) BOOL selected;
@property (nonatomic, copy) NSString * tag;

- (instancetype)initWithTag:(NSString *)tag andUserInfo:(id)userInfo;

@property (nonatomic, weak) id<TTTagChooseItemEvent> delegate;

@end
