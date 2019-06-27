//
//  TTExpandAudioPlayer.m
//  TT
//
//  Created by simp on 2017/12/21.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandAudioPlayer.h"
#import <TTFoundation/Log.h>
#import <TTService/OpusAudioPlayer.h>
#import <TTService/AudioProfile.h>
#import "TTFileManager.h"



@interface TTExpandAudioPlayer ()<TTFileDownloaderProtocol,OpusAudioPlayerPlayProtocol>

@property (nonatomic, strong) OpusAudioPlayer * player;

@property (nonatomic, strong) NSString * voiceUrl;

@property (nonatomic, copy) NSString * filePath;


@property (nonatomic, assign) BOOL isplay;

@property (nonatomic, assign) CGFloat currentPlayTime;
@end

@implementation TTExpandAudioPlayer

- (instancetype)initWithUrl:(NSString *)url {
    if (self = [super init]) {
        self.voiceUrl = url;
        [self initialPlayer];
    }
    return self;
}

- (instancetype)initWithPath:(NSString *)path {
    if (self = [super init]) {
        self.filePath = path;
        [self initialPlayer];
        self.playerState  = TTExpandAudioPlayerStateDownloadComplete;
    }
    return self;
}

- (void)initialPlayer {
    AudioProfile *profile = [[AudioProfile alloc] initWithSampleRate:16000.0f numChannels:1 pcmFormat:kPCMFormatInt16 isInterleaved:YES];
    self.player = [[OpusAudioPlayer alloc] initWithAudioProfile:profile opusBitRate:12000.0f playbackDuration:0.04];
    self.player.delegate = self;
}

- (void)downloadingUrl {
    self.playerState = TTExpandAudioPlayerStateDownloading;
    [[TTFileManager sharedManager] downloadSmallFileForUrl:self.voiceUrl delegate:self];
}


#pragma mark - download
- (void)TTFileDownloader:(TTFileDownloader *)downloader completeAtPath:(NSString *)path {
    self.filePath = path;
    self.playerState = TTExpandAudioPlayerStateDownloadComplete;
    if (self.isplay) {//是否需要播放
        [self toStartPlayAudio];
    }
}

- (void)toStartPlayAudio {
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
        [Log info:NSStringFromClass(self.class) message:@"file not exist!"];
    }
    [self.player startPlayingFileAtPath:self.filePath error:&error];
    if (error) {
        NSLog(@"播放失败");
        self.playerState = TTExpandAudioPlayerStateDownloadingFail;
    }else {
        self.playerState = TTExpandAudioPlayerStatePlaying;
    }
}

- (void)TTFileDownloaderCanceled {
    self.playerState = TTExpandAudioPlayerStateDownloadingFail;
}

- (void)TTFileDownloader:(TTFileDownloader *)downloader failed:(NSError *)eroor {
    self.playerState = TTExpandAudioPlayerStateDownloadingFail;
}

- (void)play {
    self.isplay = YES;
    if (self.playerState == TTExpandAudioPlayerStateNone) {
        [self downloadingUrl];
    }else if(self.playerState == TTExpandAudioPlayerStatePause) {
        self.playerState = TTExpandAudioPlayerStatePlaying;
        [self.player resume];
    }else if(self.playerState == TTExpandAudioPlayerStateStop) {
        [self toStartPlayAudio];
    }else if(self.playerState == TTExpandAudioPlayerStateDownloadComplete){
        [self toStartPlayAudio];
    }
}

- (void)setPlayerState:(TTExpandAudioPlayerState)playerState {
    if ([self.delegate respondsToSelector:@selector(stateChangedFrom:to:)]) {
        [self.delegate stateChangedFrom:_playerState to:playerState];
    }
    _playerState = playerState;
}


- (void)pause {
    self.isplay = NO;
    if (self.playerState == TTExpandAudioPlayerStatePlaying) {
        self.playerState = TTExpandAudioPlayerStatePause;
        [self.player pause];
    }
}


- (void)resume {
    self.isplay = NO;
    if (self.playerState == TTExpandAudioPlayerStatePause) {
        [self.player resume];
        self.playerState = TTExpandAudioPlayerStatePlaying;
    }
}

#pragma mark - 播放器代理

- (void)timeHavePlayed:(float)time {
    if (self.playerState == TTExpandAudioPlayerStatePlaying) {
        if (time -_currentPlayTime > 0.05) {
            if ([self.delegate respondsToSelector:@selector(audiohavePlayed:)]) {
                [self.delegate audiohavePlayed:time];
            }
            _currentPlayTime = time;
        }
    }
}
- (void)playended {
    self.playerState = TTExpandAudioPlayerStateStop;
    self.currentPlayTime = 0;
}

- (void)reset {
    [self.player stopPlaying];
    if (self.filePath) {
        [[TTFileManager sharedManager] deleteFileAtPath:self.filePath];
    }
    self.currentPlayTime = 0;
    self.playerState = TTExpandAudioPlayerStateNone;
}

- (void)resetWithoutDeleteFile {
    [self.player stopPlaying];
    self.currentPlayTime = 0;
    self.playerState = TTExpandAudioPlayerStateNone;
}

#pragma mark - 重置链接-

- (void)resetUrl:(NSString *)url {
    self.voiceUrl = url;
    self.playerState = TTExpandAudioPlayerStateNone;
    [self reset];
}

- (void)stop {
    if (self.playerState == TTExpandAudioPlayerStatePlaying || self.playerState==TTExpandAudioPlayerStatePause) {
        self.playerState = TTExpandAudioPlayerStateStop;
        self.currentPlayTime = 0;
        [self.player stopPlaying];
    }else {
        self.isplay = NO;
        self.currentPlayTime = 0;
    }
}

@end
