//
//  TTFileDownloaderManager.h
//  TT
//
//  Created by simp on 2017/12/21.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTFileDownloader.h"
#import "TTUploader.h"

@interface TTFileManager : NSObject

+ (instancetype)sharedManager;

- (void)downloadSmallFileForUrl:(NSString *)url delegate:(id<TTFileDownloaderProtocol>)delegate;

- (void)deleteFileAtPath:(NSString *)path;

/**扩圈上传数据-这里用作图片shangc*/
- (void)expandUploadData:(NSData *)data withKey:(NSString *)key andTag:(NSInteger)tag anddelegate:(id<TTUploaderProtocol>)delegate;

@end
