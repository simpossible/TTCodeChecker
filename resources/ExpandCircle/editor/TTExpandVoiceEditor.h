//
//  TTExpandVoiceEditor.h
//  TT
//
//  Created by simp on 2017/11/7.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@class TTExpandVoiceEditor;

typedef NS_ENUM(NSUInteger, ListenButtonStatus)
{
    kListenButtonStatusNormal,
    kListenButtonStatusLitening,
    kListenButtonStatusDisabled
};
typedef NS_ENUM(NSUInteger, RecordButtonStatus)
{
    kRecordButtonStatusNormal,
    kRecordButtonStatusRecording,
    kRecordButtonStatusShort,
    kRecordButtonStatusDrop
};
typedef NS_ENUM(NSUInteger, SaveButtonStatus)
{
    kSaveButtonStatusNormal,
    kSaveButtonStatusDisabled
};

@protocol TTExpandVoiceEditorDelegate <NSObject>
- (void)ttExpandVoiceEditorFirstSaveVoiceComplete:(TTExpandVoiceEditor *)controller;
@end

@interface TTExpandVoiceEditor : BaseViewController

@property (nonatomic, weak) id<TTExpandVoiceEditorDelegate> delegate;

@end
