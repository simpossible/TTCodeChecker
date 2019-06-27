//
//  TTExpandPhotosView.h
//  TT
//
//  Created by simp on 2017/11/2.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,TTExpandUserInfoType) {
    TTExpandUserInfoTypeOther,
    TTExpandUserInfoTypeMe,
};

@class TTExpandPhotoItem;

@protocol TTExpandPhotosViewProtocol <NSObject>

//- (void)photoCoosedAtIndex:(NSInteger)index haveImage:(BOOL)haveImage;

- (void)photoCoosedAtIndex:(NSInteger)index withItem:(TTExpandPhotoItem*)item;

- (void)photoCoosedAtIndex:(NSInteger)index withItems:(NSArray *)items;

//- (void)photoCoosedAtIndex:(NSInteger)index haveImage:(BOOL)haveImage withView:(UIView *)view;

@end

@interface TTExpandPhotosView : UIView

@property (nonatomic, strong) NSArray<NSString *> * imageUrls;

@property (nonatomic, weak) id<TTExpandPhotosViewProtocol> delegate;

@property (nonatomic, assign) TTExpandUserInfoType type;

- (void)resetALLImage;

- (void)setImage:(UIImage *)image AtIndex:(NSInteger)index;

- (void)setBigImage:(UIImage *)image;

@end
