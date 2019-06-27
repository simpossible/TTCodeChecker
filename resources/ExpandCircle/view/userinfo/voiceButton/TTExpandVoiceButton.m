//
//  TTExpandVoiceButton.m
//  TT
//
//  Created by simp on 2017/11/10.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandVoiceButton.h"
#import <TTThirdPartTools/Masonry.h>
#import "UIColor+TTColor_Generated.h"
#import "TTExpandRollingView.h"
#import <AVFoundation/AVFoundation.h>
#import "TTExpandAudioPlayer.h"
#import <TTService/AudioServiceClient.h>
#import <TTFoundation/TTFoundation.h>
#import <TTService/CommonChannelService.h>
#import "AudioHelper.h"


@interface TTExpandVoiceButton ()<TTExpandAudioPlayerProtocol ,AudioServiceClient>

@property (nonatomic, strong) UIButton * playButton;

@property (nonatomic, strong) UILabel * timeLabel;

@property (nonatomic, strong) UIButton * extraButton;

@property (nonatomic, strong) UIView * seperatorView;

/**显示秒的标签*/
@property (nonatomic, strong) UILabel * secondsLabel;

@property (nonatomic, strong) TTExpandRollingView * rollingView;

@property (nonatomic, assign) TTExpandVoiceButtonType type;

@property (nonatomic, strong) TTExpandAudioPlayer * player;

@property (nonatomic, copy) NSString * currentVoiceUrl;

@property (nonatomic, assign) BOOL interrupted;

@property (nonatomic, strong) UIView * animateBgView;

@property (nonatomic, strong) UIImageView * arrowView;

@end

@implementation TTExpandVoiceButton

- (instancetype)initWithType:(TTExpandVoiceButtonType)type {
    if (self = [super init]) {
        self.type = type;
        [self initialData];
        [self initialUI];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self initialData];
        [self initialUI];
    }
    return self;
}

- (void)dealloc
{
    REMOVE_ALL_SERVICE_CLIENT(self);
}
- (void)initialData{
    ADD_SERVICE_CLIENT(AudioServiceClient, self);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onImAudioPlayWillStart) name:onImAudioPlayWillStart object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onImAudioPlayAllFileCompleted) name:onImAudioPlayAllFileCompleted object:nil];
    self.interrupted = NO;
}
- (void)initialUI {
    [self initialAnimateBgView];
    [self initialPlayButton];
    [self initialTimeLabel];
    [self initialSecondsLabel];
    [self initialRollingView];
    if (self.type == TTExpandVoiceButtonTypeNormal) {
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.secondsLabel.mas_right).offset(16);
        }];
    }else {
        [self initialSeperatorView];
        [self initialExtraButton];
        [self initialArrowView];
        
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.arrowView.mas_right).offset(8);
        }];

    }
    self.layer.borderWidth =1;
    self.layer.borderColor = [UIColor TTGray4].CGColor;
    self.layer.masksToBounds = YES;
}

- (void)initialAnimateBgView {
    self.animateBgView = [[UIView alloc] init];
    [self addSubview:self.animateBgView];
    
    [self setBgWithDegree:0];
    self.animateBgView.backgroundColor =  [UIColor colorWithRed:0.94 green:0.95 blue:0.96 alpha:1];
    
}

- (void)setBgWithDegree:(CGFloat)degree {
    [self.animateBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
        make.left.equalTo(self.mas_left);
        make.width.equalTo(self.mas_width).multipliedBy(degree);
    }];
}

- (void)initialRollingView {
    self.rollingView = [[TTExpandRollingView alloc] init];
    [self addSubview:self.rollingView];
    
    [self.rollingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.playButton.mas_centerX);
        make.centerY.equalTo(self.playButton.mas_centerY);
    }];
//    self.rollingView.backgroundColor = [UIColor whiteColor];
    [self.rollingView setImage:[UIImage imageNamed:@"kuoquan_icon_loading_small"]];
}

- (void)initialPlayButton {
    self.playButton = [[UIButton alloc] init];
    [self addSubview:self.playButton];
    
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(self.padding.left).offset(16);
        make.width.mas_equalTo(24);
        make.height.mas_equalTo(24);
        make.centerY.equalTo(self.mas_centerY);
    }];
    UIImage *playImage = [UIImage imageNamed:@"kuoquan_icon_play_small"];
    UIImage *pauseImage = [UIImage imageNamed:@"kuoquan_icon_pause_small"];
    [self.playButton setImage:playImage forState:UIControlStateNormal];
    [self.playButton setImage:pauseImage forState:UIControlStateSelected];
    
    [self.playButton addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self.playButton setImageEdgeInsets:UIEdgeInsetsMake(8, 16, 8, 0)];
}

- (void)initialSecondsLabel {
    self.secondsLabel = [[UILabel alloc] init];
    [self addSubview:self.secondsLabel];
    
    [self.secondsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(8);
        make.width.mas_equalTo(8);
        make.height.mas_equalTo(11);
        make.left.equalTo(self.timeLabel.mas_right).offset(1);
    }];
    self.secondsLabel.text = @"″";
    self.secondsLabel.textColor =[ UIColor blackColor];
    self.secondsLabel.font = [UIFont systemFontOfSize:8];
    self.secondsLabel.textAlignment = NSTextAlignmentCenter;
}



- (void)initialTimeLabel {
    self.timeLabel = [[UILabel alloc] init];
    [self addSubview:self.timeLabel];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playButton.mas_right).offset(10);
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
    }];
    [self.timeLabel setTextColor:[UIColor blackColor]];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
}

- (void)initialSeperatorView {
    self.seperatorView = [[UIView alloc] init];
    [self addSubview:self.seperatorView];
    
    [self.seperatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.secondsLabel.mas_right).offset(6);
        make.centerY.equalTo(self.mas_centerY);
        make.height.mas_equalTo(14);
        make.width.mas_equalTo(2);
    }];
    self.seperatorView.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
    
}

- (void)initialExtraButton {
    self.extraButton = [[UIButton alloc] init];
    [self addSubview:self.extraButton];
    
    [self.extraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.seperatorView.mas_right).offset(24);
        make.centerY.equalTo(self.mas_centerY);
        make.height.mas_equalTo(20);
    }];
    
    self.extraButton.titleLabel.font = [UIFont systemFontOfSize:14];
//    [self.extraButton setImage:arrow forState:UIControlStateNormal];
    [self.extraButton setTitle:@"重录" forState:UIControlStateNormal];
////    [self.extraButton setImageEdgeInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
//    [self.extraButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 16)];
//    [self.extraButton layoutIfNeeded];
//    [self.extraButton setTitleEdgeInsets:UIEdgeInsetsMake(0, - self.extraButton.imageView.image.size.width, 0, self.extraButton.imageView.image.size.width)];
//    [self.extraButton setImageEdgeInsets:UIEdgeInsetsMake(0, self.extraButton.titleLabel.bounds.size.width, 0, -self.extraButton.titleLabel.bounds.size.width)];
    [self.extraButton setTitleColor:[UIColor colorWithRed:0.36 green:0.08 blue:1 alpha:1] forState:UIControlStateNormal];
//    [self.extraButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
}

- (void)initialArrowView {
    self.arrowView = [[UIImageView alloc] init];
    [self addSubview:self.arrowView];
    UIImage *arrow = [UIImage imageNamed:@"kuoquan_edit_icon_arrows"];
    self.arrowView.image = arrow;
    [self.arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.extraButton.mas_right).offset(2);
        make.centerY.equalTo(self.extraButton.mas_centerY);
        make.width.mas_equalTo(12);
        make.height.mas_equalTo(16);
    }];
}

- (void)setTotoalLength:(UInt32)totoalLength {
    if (_totoalLength == totoalLength){
        return;
    }
    _totoalLength = totoalLength;
    self.timeLabel.text = [NSString stringWithFormat:@"%u",totoalLength];
}


#pragma mark - 设置状态

/**playButton点击*/
- (void)playButtonClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        NOTIFY_SERVICE_CLIENT(AudioServiceClient, @selector(onAudioPlayWillStart), onAudioPlayWillStart);//通知给房间
         [self.player play];
    }else {
        NOTIFY_SERVICE_CLIENT(AudioServiceClient, @selector(onAudioPlayAllFileCompleted), onAudioPlayAllFileCompleted);//通知给房间
        [self.player stop];
        [self setBgWithDegree:0];
    }
    
    [self dealPlayerState:self.player.playerState];
}

- (void)play {
    [self playButtonClicked:self.playButton];
}

- (void)setVoiceState:(TTExpandVoiceButtonLoadState)voiceState {
    if (voiceState == TTExpandVoiceButtonStateNone) {
        [self.rollingView stopRolling];
    }else if(voiceState == TTExpandVoiceButtonStateloading){
        if (self.playButton.selected) {
            [self.rollingView startRolling];
        }
    }else if(voiceState == TTExpandVoiceButtonStateloaded){
        [self.rollingView stopRolling];
    }
    _voiceState = voiceState;
}

- (void)resetVoiceButtonWithUrl:(NSString *)voiceUrl {
    self.currentVoiceUrl = voiceUrl;
    self.voiceUrl = voiceUrl;
    [self resetPlayerWithUrl:voiceUrl];
    self.voiceState = TTExpandVoiceButtonStateNone;
    self.playButton.selected = NO;
    [self setBgWithDegree:0];
}

#pragma mark - 新的音频播放

- (void)resetPlayerWithUrl:(NSString *)url {
    [self.player stop];
    self.player = [[TTExpandAudioPlayer alloc] initWithUrl:url];
    self.player.delegate = self;
    [self.player resetUrl:url];
    [self setBgWithDegree:0];
}

#pragma mark - 播放回调

- (void)stateChangedFrom:(TTExpandAudioPlayerState)old to:(TTExpandAudioPlayerState)newState {
    [self dealPlayerState:newState];
}

- (void)audiohavePlayed:(CGFloat)time {
    if (self.player.playerState == TTExpandAudioPlayerStatePlaying) {
        NSInteger second = time;
        CGFloat degree = time/_totoalLength;
        [self setBgWithDegree:degree];
        NSLog(@"the degree is %f",degree);
    }
//    self.timeLabel.text = [NSString stringWithFormat:@"%ld",second];
}

- (void)dealPlayerState:(TTExpandAudioPlayerState)state {
    if (state == TTExpandAudioPlayerStateNone) {
        [self.rollingView stopRolling];
        self.playButton.selected = NO;
    }else if (state == TTExpandAudioPlayerStateDownloading) {
        [self.rollingView startRolling];
        self.playButton.hidden = YES;
    }else if (state == TTExpandAudioPlayerStateDownloadComplete) {
        [self.rollingView stopRolling];
        self.playButton.hidden = NO;
    }else if (state == TTExpandAudioPlayerStateDownloadingFail) {
        [self.rollingView stopRolling];
         self.playButton.hidden = NO;
        self.playButton.selected = NO;
    }else if (state == TTExpandAudioPlayerStatePlaying) {
        [[NSNotificationCenter defaultCenter] postNotificationName:onCardAudioPlayWillStart object:nil];//通知给im
        [self.rollingView stopRolling];
        self.playButton.selected = YES;
    }else if (state == TTExpandAudioPlayerStatePause) {
        [[NSNotificationCenter defaultCenter] postNotificationName:onCardAudioPlayAllFileCompleted object:nil];//通知给im
        self.playButton.selected = NO;
    }else if (state == TTExpandAudioPlayerStateStop) {
        NOTIFY_SERVICE_CLIENT(AudioServiceClient, @selector(onAudioPlayAllFileCompleted), onAudioPlayAllFileCompleted);//注意:如果没有notify来调用player的stop方法,那么此处不会出现通知嵌套,如果后续需求要求使用stop来代替pause,那么此处会出现循环嵌套
        [[NSNotificationCenter defaultCenter] postNotificationName:onCardAudioPlayAllFileCompleted object:nil];//通知给im
        self.playButton.selected = NO;
        [self.animateBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
            make.left.equalTo(self.mas_left);
            make.width.equalTo(self.mas_width).multipliedBy(0);
        }];
    }
//    [self setBgForPlayButton];
}

- (void)setBgForPlayButton{
    if (self.playButton.selected) {
        self.playButton.backgroundColor = [UIColor colorWithRed:0.94 green:0.95 blue:0.96 alpha:1];
    }else {
        self.playButton.backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark - 清除当前的状态

- (void)clearState {
    [self.player reset];
}

#pragma mark - 重录

- (void)addRecortTarget:(id)target andSel:(SEL)selector {
    [self.extraButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -AudioServiceClient

- (void)onImAudioPlayWillStart
{
    if (self.player.playerState == TTExpandAudioPlayerStatePlaying) {
        //播放im语音消息时,暂停card语音
        self.interrupted = YES;
        [self.player pause];
        [self dealPlayerState:self.player.playerState];
    }
}

- (void)onImAudioPlayAllFileCompleted
{
    if (self.player.playerState == TTExpandAudioPlayerStatePause && self.interrupted) {
        //停止im语音消息时,resume card语音
        self.interrupted = NO;
        [self.player resume];
        [self dealPlayerState:self.player.playerState];
    }
}

- (void)onAudioRecordWillStart
{
    if (self.player.playerState == TTExpandAudioPlayerStatePlaying) {
        //播放im语音消息时,暂停card语音
        self.interrupted = YES;
        [self.player pause];
        [self dealPlayerState:self.player.playerState];
    }
}

- (void)onAudioRecordCompleted
{
    if (self.player.playerState == TTExpandAudioPlayerStatePause && self.interrupted) {
        //停止im语音消息时,resume card语音
        self.interrupted = NO;
        [AudioHelper setupGlobalAudioConfig];
        [self.player resume];
        [self dealPlayerState:self.player.playerState];
    }
}


- (void)setPadding:(UIEdgeInsets)padding {
    _padding = padding;
}

- (void)pause {
    [self.player pause];
}

- (void)stop {
    [self.player stop];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


@end
