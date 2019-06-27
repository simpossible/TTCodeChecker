//
//  TTFileUploader.m
//  TT
//
//  Created by simp on 2017/12/22.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTUploader.h"
#import "TTExpandDataUploader.h"

@interface TTUploader ()

@end

@implementation TTUploader


+ (instancetype)expandUploaderWithData:(NSData *)data andKey:(NSString *)key {
    return [[TTExpandDataUploader alloc] initWithData:data andKey:key];
}

- (void)startUploadOnQueue:(dispatch_queue_t)queue {
    
}
@end
