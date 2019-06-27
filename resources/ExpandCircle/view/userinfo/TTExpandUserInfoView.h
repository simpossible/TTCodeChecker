//
//  TTExpandUserInfoView.h
//  TT
//
//  Created by simp on 2017/11/2.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTService/ExpandCircleService.h>
#import "TTExpandPhotosView.h"
#import "TTExpandVoiceButton.h"
#import "TTExpandCircleRoundItem.h"

@protocol TTExpandInfoProtocol<NSObject>

- (void)toReRecordVoice;

- (void)toReportUser:(TTExpandUser *)user;

@end


@interface TTExpandUserInfoView : UIView

- (instancetype)initWithType:(TTExpandUserInfoType)type;

@property (nonatomic, weak) id<TTExpandInfoProtocol> delegate;

@property (nonatomic, strong) TTExpandUser * user;

- (void)setPhotosDelegate:(id<TTExpandPhotosViewProtocol>)phtosDelegate;

/**某些情况下需要强制暂停语音*/
- (void)audioReset;

- (void)dealCurrentDirection:(TTExpandCircleDirection)direction;

- (void)clearDirection;

- (void)showReportButton;

- (void)playAudio;

- (void)pauseCurrentAudio;

@end
