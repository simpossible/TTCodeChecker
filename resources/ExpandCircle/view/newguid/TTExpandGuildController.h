//
//  TTExpandGuildController.h
//  TT
//
//  Created by simp on 2017/11/7.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TTExpandGuildProtocl <NSObject>

- (void)guildComplete;

@end

@interface TTExpandGuildController : UIViewController

@property (nonatomic, weak) id<TTExpandGuildProtocl> delegate;

@end
