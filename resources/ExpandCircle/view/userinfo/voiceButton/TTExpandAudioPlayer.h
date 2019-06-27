//
//  TTExpandAudioPlayer.h
//  TT
//
//  Created by simp on 2017/12/21.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,TTExpandAudioPlayerState) {
    TTExpandAudioPlayerStateNone,
    TTExpandAudioPlayerStateDownloading,
    TTExpandAudioPlayerStateDownloadComplete,
    TTExpandAudioPlayerStateDownloadingFail,
    TTExpandAudioPlayerStatePlaying,
    TTExpandAudioPlayerStatePause,
    TTExpandAudioPlayerStateStop,//播放完成
};

@protocol TTExpandAudioPlayerProtocol <NSObject>

- (void)stateChangedFrom:(TTExpandAudioPlayerState)old to:(TTExpandAudioPlayerState)newState;

- (void)audiohavePlayed:(CGFloat)time;

@end


@interface TTExpandAudioPlayer : NSObject

- (instancetype)init __unavailable;

- (instancetype)initWithUrl:(NSString *)url;

- (instancetype)initWithPath:(NSString *)path;

@property (nonatomic, weak) id<TTExpandAudioPlayerProtocol> delegate;

@property (nonatomic, assign, readonly) TTExpandAudioPlayerState playerState;

- (void)resetUrl:(NSString *)url;

- (void)play;

- (void)pause;

- (void)resume;

- (void)reset;

- (void)resetWithoutDeleteFile;

- (void)stop;


@end
