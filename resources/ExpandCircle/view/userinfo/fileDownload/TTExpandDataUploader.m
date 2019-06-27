//
//  TTExpandDataUploader.m
//  TT
//
//  Created by simp on 2017/12/22.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandDataUploader.h"
#import <TTThirdPartTools/QiniuSDK.h>
#import <TTFoundation/TTFoundation.h>
#import <TTService/AuthService.h>
#import <TTService/AuthModel.h>

@interface TTExpandDataUploader ()

@property (nonatomic, strong) NSData * dataToUploader;

@property (nonatomic, copy) NSString * key;

@end

@implementation TTExpandDataUploader

- (instancetype)initWithData:(NSData *)upData andKey:(NSString *)key{
    if (self = [super init]) {
        self.dataToUploader = upData;
        self.key = key;
    }
    return self;
}

- (void)startUploadOnQueue:(dispatch_queue_t)queue {
    
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    __weak typeof(self)wself = self;
    AuthModel *myauth = [GET_SERVICE(AuthService) myAuthModel];
    NSString *token = myauth.albumToken;
    [upManager putData:self.dataToUploader key:self.key token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        if (!info.error) {
            [wself reportCompleteWithKey:key];
        }else {
            [Log info:@"TTUploader-TTExpandDataUploader" message:@"上传失败%@",wself.key];
        }
    } option:nil];
}

- (void)reportCompleteWithKey:(NSString *)key {
    if ([self.delegate respondsToSelector:@selector(uploadSucess:withInfo:)]) {
        key = key == nil?@"":key;
        [self.delegate uploadSucess:self withInfo:@{@"key":key}];
    }
}

@end
