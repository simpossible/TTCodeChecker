//
//  TTExpandTagChooseController.h
//  TT
//
//  Created by simp on 2017/12/25.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol TTExpandTagChooseControllerProtocol <NSObject>

- (void)playgamesAlreadyChanged;

@end

@interface TTExpandTagChooseController : BaseViewController

@property (nonatomic, weak) id<TTExpandTagChooseControllerProtocol> delegate;

@end
