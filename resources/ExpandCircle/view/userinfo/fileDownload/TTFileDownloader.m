//
//  TTFileDownloader.m
//  TT
//
//  Created by simp on 2017/12/21.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTFileDownloader.h"

typedef NS_ENUM(NSUInteger,TTFileDownloaderType) {
    TTFileDownloaderTypeNone,
    TTFileDownloaderForSmall,
    TTFileDownloaderLarge,
};

@interface TTFileDownloader()



/**
 保存路径
 */
@property (nonatomic, copy) NSString * saveDir;


/**
 保存的文件名
 */
@property (nonatomic, copy) NSString * saveFileName;




@property (nonatomic, assign) TTFileDownloaderType type;

@end

@implementation TTFileDownloader

- (instancetype)initWithUrl:(NSString *)url andSaveDir:(NSString *)dir withFileName:(NSString *)fileName andDelegate:(id<TTFileDownloaderProtocol>)delegate {
    if (self = [super init]) {
        _url = url;
        self.saveDir = dir;
        self.saveFileName = fileName;
        _delegate = delegate;
    }
    return self;
}

- (void)download {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:self.url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDataTask * dataTask =  [session dataTaskWithRequest:request
                                                  completionHandler:^(NSData * __nullable data,
                                                                      NSURLResponse * __nullable response,
                                                                      NSError * __nullable error) {
                                                      
                                                  }];
}


- (instancetype)initWithUrl:(NSString *)url andDelegate:(id<TTFileDownloaderProtocol>)delegate {
    if (self = [super init]) {
        _url = url;
        _delegate = delegate;
    }
    return self;
}


- (void)cancel {
    
}

- (void)startDownloadAtQueue:(dispatch_queue_t)queue {
    
}



@end
