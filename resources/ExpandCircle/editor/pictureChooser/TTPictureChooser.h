//
//  TTPictureChooser.h
//  TT
//
//  Created by simp on 2017/12/22.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol TTPictureChooserProtocol <NSObject>

- (void)TTPictureChooseErrorWithMessge:(NSString *)message;

- (void)TTPictureChooseCompleteWithImages:(NSArray<UIImage *> *)images;

@end

@interface TTPictureChooser : NSObject

@property (nonatomic, weak) id<TTPictureChooserProtocol> delegate;

@property (nonatomic, assign) NSInteger tag;

/**最多选择的图片数量*/
@property (nonatomic, assign) NSInteger maxPictureNumber;

- (void)showOnController:(UIViewController *)controller;

@end
