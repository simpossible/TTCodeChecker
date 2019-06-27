//
//  TTSmallFileDownloader.m
//  TT
//
//  Created by simp on 2017/12/21.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTSmallFileDownloader.h"
#import <TTFoundation/TTFoundation.h>

@interface TTSmallFileDownloader()<NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSessionDownloadTask * task;
@property (nonatomic) dispatch_queue_t queue;

@end

@implementation TTSmallFileDownloader

- (void)downloadForsmall {
    NSURL *netUrl = [NSURL URLWithString:self.url];
    NSOperationQueue *oper = [NSOperationQueue mainQueue];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:oper];
    __weak typeof(self)wself = self;
    NSURLSessionDownloadTask *dataTask = [session downloadTaskWithURL:netUrl completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [wself reportFileDownloadError:error];
        }else {
            
            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSURL *documentsDirectoryURL = [NSURL fileURLWithPath:documentsPath];
            NSURL *fileURL = [documentsDirectoryURL URLByAppendingPathComponent:[[response URL] lastPathComponent]];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:[fileURL path] isDirectory:NULL]) {
                [fileManager removeItemAtURL:fileURL error:nil];
            }
            BOOL a =  [fileManager fileExistsAtPath:[location path]];
            [fileManager moveItemAtURL:location toURL:fileURL error:nil];
            BOOL b =  [fileManager fileExistsAtPath:[fileURL path]];
            [wself reportFileDownloadResultAtUrl:fileURL];
            [wself reportFinish];
        }
     
    }];
    self.task = dataTask;
    [self.task resume];
}

- (void)reportFileDownloadError:(NSError *)error {
    [Log info:@"TTSmallFileDownloader" message:@"reportFileDownloadError:%@",error];
    dispatch_main_sync_safe(^{
        if ([self.delegate respondsToSelector:@selector(TTFileDownloader:failed:)]) {
            [self.delegate TTFileDownloader:self failed:error];
        }
    });
}

- (void)reportFileDownloadResultAtUrl:(NSURL *)url {
    dispatch_main_sync_safe(^{
        if ([self.delegate respondsToSelector:@selector(TTFileDownloader:completeAtPath:)]) {
            [self.delegate TTFileDownloader:self completeAtPath:[url path]];
        }
    });
}

- (void)startDownload {
    [self downloadForsmall];
}

- (void)startDownloadAtQueue:(dispatch_queue_t)queue {
    self.queue = queue;
    dispatch_async(queue, ^{
        [self startDownload];
    });
}

- (void)reportFinish {
    dispatch_main_sync_safe(^{
        if ([self.privateDelegate respondsToSelector:@selector(downladerFinish:)]) {
            [self.privateDelegate downladerFinish:self];
        }
    });
}

- (void)cancel {
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    BOOL a =  [[NSFileManager defaultManager] fileExistsAtPath:[location absoluteString]];
}



@end
