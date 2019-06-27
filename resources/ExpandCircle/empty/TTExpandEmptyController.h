//
//  TTExpandEmptyController.h
//  TT
//
//  Created by simp on 2018/1/2.
//  Copyright © 2018年 yiyou. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void  (^TTEmptyBlock)();

@interface TTExpandEmptyController : UIViewController

@property (nonatomic, copy) TTEmptyBlock jumpCallBack;

@end
