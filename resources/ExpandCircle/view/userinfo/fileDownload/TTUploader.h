//
//  TTFileUploader.h
//  TT
//
//  Created by simp on 2017/12/22.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TTUploader;

@protocol TTUploaderProtocol <NSObject>

- (void)uploadSucess:(TTUploader *)uploader withInfo:(NSDictionary *)info;

- (void)uploaderFail:(TTUploader *)uploader;

@end

@protocol TTUploaderPrivateProtocol <NSObject>

- (void)uploadinish:(TTUploader *)uploader;

@end

@interface TTUploader : NSObject

@property (nonatomic, weak) id<TTUploaderProtocol> delegate;

@property (nonatomic, weak) id<TTUploaderPrivateProtocol> privateDelegate;

@property (nonatomic, assign) NSInteger tag;

/**
上传数据

 @param upData 将要上传的数据
 @param key 数据存储的key
 @return TTExpandDataUploader
 */
+ (instancetype)expandUploaderWithData:(NSData *)data andKey:(NSString *)key;

/**开始上传*/
- (void)startUploadOnQueue:(dispatch_queue_t)queue;

@end
