//
//  TTExpandMatchedController.h
//  TT
//
//  Created by simp on 2017/12/27.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTExpandUser;

@protocol TTExpandMatchedControllerProtocol <NSObject>

- (void)matchedAvatorPreparedOk;

- (void)matchedToChatConttroler:(TTExpandUser *)user;

- (void)matchedGoOn;

@end

@interface TTExpandMatchedController : UIViewController

- (instancetype)initWithMatchedUser:(TTExpandUser *)user;

@property (nonatomic, weak)id<TTExpandMatchedControllerProtocol> delegate;

@end
