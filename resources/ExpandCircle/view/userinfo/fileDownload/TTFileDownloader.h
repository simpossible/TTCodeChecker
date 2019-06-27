//
//  TTFileDownloader.h
//  TT
//
//  Created by simp on 2017/12/21.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TTFileDownloader;

@protocol TTFileDownloaderProtocol <NSObject>

- (void)TTFileDownloader:(TTFileDownloader *)downloader completeAtPath:(NSString *)path;

- (void)TTFileDownloaderCanceled;

- (void)TTFileDownloader:(TTFileDownloader *)downloader failed:(NSError *)eroor;

@end

@protocol TTFileDownloaderPrivateProtocol <NSObject>

- (void)downladerFinish:(TTFileDownloader *)downloader;

@end

typedef void (^TTFileDownloaderCompleteCallBack)(TTFileDownloader *downloader,NSString *filePath,NSError *error);
typedef void (^TTFileDownloaderFaileCallBack) (TTFileDownloader *downloader,NSError *eroor);
typedef void (^TTFileDownloaderCancelCallBack) (TTFileDownloader *downloader);

@interface TTFileDownloader : NSObject

/**
 代理
 */
@property (nonatomic, weak, readonly) id<TTFileDownloaderProtocol> delegate;

@property (nonatomic, weak) id<TTFileDownloaderPrivateProtocol> privateDelegate;

/**
 资源地址
 */
@property (nonatomic, copy, readonly) NSString * url;

- (instancetype)init __unavailable; //不允许直接构造

/**
 初始化
 
 @param url 资源地址
 @param dir 保存的目录
 @param fileName 文件名
 @param delegate 代理
 @return TTFileDownloader
 */
- (instancetype)initWithUrl:(NSString *)url andSaveDir:(NSString *)dir withFileName:(NSString *)fileName andDelegate:(id<TTFileDownloaderProtocol>)delegate;



/**
 小文件下载-自动保存

 @param url 资源地址
 @param delegate 代理
 @return TTFileDownloader
 */
- (instancetype)initWithUrl:(NSString *)url andDelegate:(id<TTFileDownloaderProtocol>)delegate;

- (void)startDownload;

- (void)startDownloadAtQueue:(dispatch_queue_t)queue;

- (void)cancel;

@end
