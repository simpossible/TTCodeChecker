//
//  TTFileDownloaderManager.m
//  TT
//
//  Created by simp on 2017/12/21.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTFileManager.h"
#import "TTSmallFileDownloader.h"
#import <TTFoundation/TTFoundation.h>

@interface TTFileManager()<TTFileDownloaderPrivateProtocol,TTUploaderPrivateProtocol>

@property (nonatomic, strong) NSMutableArray * smallFileTasks;

@property (nonatomic) dispatch_queue_t smallDownloadQueue;

@property (nonatomic) dispatch_queue_t deleteQueue;

/**上传的queue*/
@property (nonatomic, strong) NSMutableArray * uploaderTasks;

@property (nonatomic) dispatch_queue_t uploaderQueue;

@end

@implementation TTFileManager

+ (instancetype)sharedManager {
    static TTFileManager * downloader;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloader = [[TTFileManager alloc] init];
    });
    return downloader;
}

- (instancetype)init {
    if (self = [super init]) {
        self.smallFileTasks = [NSMutableArray array];
        self.uploaderTasks = [NSMutableArray array];
    }
    return self;
}

- (void)downloadSmallFileForUrl:(NSString *)url delegate:(id<TTFileDownloaderProtocol>)delegate {
    if (!self.smallDownloadQueue) {
        self.smallDownloadQueue = dispatch_queue_create("smalldownload", DISPATCH_QUEUE_CONCURRENT);
    }    
    TTSmallFileDownloader *doownloader = [[TTSmallFileDownloader alloc] initWithUrl:url andDelegate:delegate];
    doownloader.privateDelegate = self;
    [doownloader startDownloadAtQueue:self.smallDownloadQueue];
    [self.smallFileTasks addObject:doownloader];
}

- (void)downladerFinish:(TTFileDownloader *)downloader {
    if ([self.smallFileTasks containsObject:downloader]) {
        [self.smallFileTasks removeObject:downloader];
    }
}

- (void)deleteFileAtPath:(NSString *)path {
    if (!self.deleteQueue) {
        self.deleteQueue = dispatch_queue_create("smalldownload", DISPATCH_QUEUE_SERIAL);
    }
    dispatch_async(self.deleteQueue, ^{
        NSError *deleteError;
        [[NSFileManager defaultManager] removeItemAtPath:path error:&deleteError];
        if (deleteError) {
            [Log info:@"TTFileDownloaderManager" message:@"删除文件失败-%@",path];
        }
    });
}

#pragma mark - 上传

- (void)expandUploadData:(NSData *)data withKey:(NSString *)key andTag:(NSInteger)tag anddelegate:(id<TTUploaderProtocol>)delegate {
    if (!self.uploaderQueue) {
        self.uploaderQueue = dispatch_queue_create("expanduploader", DISPATCH_QUEUE_CONCURRENT);
    }
    TTUploader *uploader = [TTUploader expandUploaderWithData:data andKey:key];
    uploader.tag = tag;
    uploader.delegate = delegate;
    uploader.privateDelegate = self;
    [self.uploaderTasks addObject:uploader];
    [uploader startUploadOnQueue:self.uploaderQueue];

}

- (void)uploadinish:(TTUploader *)uploader {
    if ([self.uploaderTasks containsObject:uploader]) {
        [self.uploaderTasks removeObject:uploader];
    }
}


@end
