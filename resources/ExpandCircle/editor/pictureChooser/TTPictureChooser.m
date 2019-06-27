//
//  TTPictureChooser.m
//  TT
//
//  Created by simp on 2017/12/22.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTPictureChooser.h"
#import <TTFoundation/TTFoundation.h>
#import "UIUtil.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ZLPhotoActionSheet.h"
#import "ZLPhotoModel.h"

@interface TTPictureChooser()

@end

@implementation TTPictureChooser

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}


- (void)showOnController:(UIViewController *)controller {
    
    ZLPhotoActionSheet *actionSheet = [[ZLPhotoActionSheet alloc] init];
    actionSheet.configuration.maxSelectCount = self.maxPictureNumber;
    actionSheet.sender = controller;

    [actionSheet setSelectImageModelBlock:^(NSArray<ZLPhotoModel *> * _Nullable images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
        NSMutableArray *imageList = [NSMutableArray array];
        for (ZLPhotoModel *model in images) {
            if (model.finnalImage) {
                [imageList addObject:model.finnalImage];
            } else if (model.finnalData) {
                [imageList addObject:[UIImage imageWithData: model.finnalData]];
            }
        }
        [self reportResultForArray:imageList];
    }];
    
    [actionSheet showPreviewAnimated:YES];
}

- (void)reportResultForArray:(NSArray *)array {
    if ([self.delegate respondsToSelector:@selector(TTPictureChooseCompleteWithImages:)]) {
        [self.delegate TTPictureChooseCompleteWithImages:array];
    }
}

- (void)reportErrorResultForMessage:(NSString *)msg {
    if ([self.delegate respondsToSelector:@selector(TTPictureChooseErrorWithMessge:)]) {
        [self.delegate TTPictureChooseErrorWithMessge:msg];
    }
}


@end
