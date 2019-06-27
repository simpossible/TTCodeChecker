//
//  TTExpandVoiceButton.h
//  TT
//
//  Created by simp on 2017/11/10.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,TTExpandVoiceButtonType) {
    TTExpandVoiceButtonTypeNormal,
    TTExpandVoiceButtonTypeFull,
};

typedef NS_ENUM(NSUInteger,TTExpandVoiceButtonLoadState) {
    TTExpandVoiceButtonStateNone,
    TTExpandVoiceButtonStateloading,
    TTExpandVoiceButtonStateloaded,
};

@interface TTExpandVoiceButton : UIControl

- (instancetype)initWithType:(TTExpandVoiceButtonType)type;

@property (nonatomic, copy) NSString * voiceUrl;

@property (nonatomic, assign) TTExpandVoiceButtonLoadState voiceState;

@property (nonatomic, assign) UIEdgeInsets padding;

/**语音的长度*/
@property (nonatomic, assign) UInt32 totoalLength;

/**重置当前的音频链接*/
- (void)resetVoiceButtonWithUrl:(NSString *)voiceUrl;

/**清楚状态*/
- (void)clearState;

- (void)addRecortTarget:(id)target andSel:(SEL)selector;

- (void)play;

- (void)pause;

- (void)stop;

@end
