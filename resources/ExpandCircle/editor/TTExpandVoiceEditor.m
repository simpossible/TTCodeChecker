//
//  TTExpandVoiceEditor.m
//  TT
//
//  Created by simp on 2017/11/7.
//  Copyright © 2017年 yiyou. All rights reserved.
//
#define RATIO [UIScreen mainScreen].bounds.size.height/667.f
#import "TTExpandVoiceEditor.h"
#import "UIUtil.h"
#import "UIColor+TTColor_Generated.h"
#import "UIColor+Extension.h"
#import "TTExpandAudioPlayer.h"
#import <TTFoundation/Log.h>
#import <TTFoundation/TTAlertView.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <TTFoundation/TTFoundation.h>
#import <TTService/AudioService.h>
#import <TTService/IMAttachmentHelper.h>
#import <TTService/AuthService.h>
#import <TTService/ExpandCircleService.h>
#import "TTFileManager.h"
#import "UIBarButtonItem+Extension.h"
#import "TTExpandEditorController.h"
#import "AudioHelper.h"

@interface TTExpandVoiceEditor ()<TTExpandAudioPlayerProtocol ,TTUploaderProtocol , AudioServiceClient>
@property (weak, nonatomic) IBOutlet UIView *secondContainerView;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondSymbolLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordingTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *helpTipsLabel;
@property (nonatomic, strong) CAShapeLayer *secondLayer;
@property (nonatomic, strong) UIBezierPath *secondPath;
@property (nonatomic, assign) CGFloat startAngle;
/*************** record view ***************/
@property (weak, nonatomic) IBOutlet UIView *recordContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *recordImageView;
@property (weak, nonatomic) IBOutlet UILabel *recordTitleLabel;
/*************** save view ***************/
@property (weak, nonatomic) IBOutlet UIView *saveContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *saveImageView;
@property (weak, nonatomic) IBOutlet UILabel *saveTitleLabel;
/*************** listen view ***************/
@property (weak, nonatomic) IBOutlet UIView *listenContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *listenImageView;
@property (weak, nonatomic) IBOutlet UILabel *listenTitleLabel;
/*************** cons to adapt screen ***************/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondTopCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tryTipTopCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipTopCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recordTipTopCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recordViewTopCons;
/*************** button status ***************/
@property (nonatomic, assign) RecordButtonStatus recordButtonStatus;
@property (nonatomic, assign) SaveButtonStatus saveButtonStatus;
@property (nonatomic, assign) ListenButtonStatus listenButtonStatus;
/*************** timers ***************/
@property (nonatomic, strong) CADisplayLink *recordTimer;
@property (nonatomic, assign) NSInteger recordDuration;//录音的大概时长,用于UI展示(单位1/60秒)
/*************** touches ***************/
@property (nonatomic, assign) BOOL isTouchDown;
/*************** recorder ***************/
@property (nonatomic, strong) id<IAudioRecorder> audioRecorder;
@property (nonatomic, strong) TTExpandAudioPlayer *audioPlayer;
@property (nonatomic, assign) CFAbsoluteTime startRecordingTime;
@property (nonatomic, strong) NSData *tempAudioData;
@property (nonatomic, assign) BOOL dropCurrentAudioData;//标记:当前录制的这条语音是否在录制结束后直接丢掉
@property (nonatomic, assign) BOOL isListening;
@property (nonatomic, strong) TTExpandMeUser *expandMeUser;
@property (nonatomic, assign) BOOL alreadySaved;//标记:当前最新录的那条语音是否被保存
@property (nonatomic, strong) NSMutableArray *textArray;

@end

@implementation TTExpandVoiceEditor

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupData];
    [self setupScreen];
    [self setupUI];
}
- (void)viewDidLayoutSubviews
{
    self.secondContainerView.layer.cornerRadius = self.secondContainerView.bounds.size.width * 0.5;
    self.secondContainerView.layer.masksToBounds = YES;
    self.recordContainerView.layer.cornerRadius = self.recordContainerView.bounds.size.width * 0.5;
    self.recordContainerView.layer.masksToBounds = YES;
    self.listenContainerView.layer.cornerRadius = self.listenContainerView.bounds.size.width * 0.5;
    self.listenContainerView.layer.masksToBounds = YES;
    self.saveContainerView.layer.cornerRadius = self.saveContainerView.bounds.size.width * 0.5;
    self.saveContainerView.layer.masksToBounds = YES;
}
- (void)popBackIfCan{
    if (!self.alreadySaved) {
        TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"放弃语音设置?" message:@"放弃后会保留原本的语音"];
        [alert addButtonWithTitle:@"继续录音" block:^{
            //do nothing
        }];
        [alert addButtonWithTitle:@"确认" block:^{
            [super popBackIfCan];
        }];
        [alert show];
    }else{
        [super popBackIfCan];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.leftBarButtonItem = self.navigationItem.leftBarButtonItem ?: [UIBarButtonItem backBarButtonItemWithStyle:UIBarButtonItemStylePlain target:self action:@selector(popBackIfCan)];
}
#pragma mark - button status
- (void)setListenButtonStatus:(ListenButtonStatus)listenButtonStatus
{
    _listenButtonStatus = listenButtonStatus;
    switch (listenButtonStatus) {
        case kListenButtonStatusNormal:
        {
            self.listenImageView.image = [UIImage imageNamed:@"kuoquan_icon_play_default"];
            self.listenTitleLabel.text = @"试听";
        }
            break;
        case kListenButtonStatusLitening:
        {
            self.listenImageView.image = [UIImage imageNamed:@"kuoquan_icon_pause_default"];
            self.listenTitleLabel.text = @"暂停";
        }
            break;
        case kListenButtonStatusDisabled:
        {
            self.listenImageView.image = [UIImage imageNamed:@"kuoquan_icon_play_disabled"];
            self.listenTitleLabel.text = @"试听";
        }
            break;
        default:
        {
            self.listenImageView.image = [UIImage imageNamed:@"kuoquan_icon_play_disabled"];
            self.listenTitleLabel.text = @"试听";
        }
            break;
    }
}
- (void)setSaveButtonStatus:(SaveButtonStatus)saveButtonStatus
{
    _saveButtonStatus = saveButtonStatus;
    switch (saveButtonStatus) {
        case kSaveButtonStatusNormal:
        {
            self.saveImageView.image = [UIImage imageNamed:@"kuoquan_icon_save_default"];
        }
            break;
        case kSaveButtonStatusDisabled:
        {
            self.saveImageView.image = [UIImage imageNamed:@"kuoquan_icon_save_disabled"];
        }
            break;
        default:
            self.saveImageView.image = [UIImage imageNamed:@"kuoquan_icon_save_disabled"];
            break;
    }
}
- (void)setRecordButtonStatus:(RecordButtonStatus)recordButtonStatus
{
    _recordButtonStatus = recordButtonStatus;
    switch (recordButtonStatus) {
        case kRecordButtonStatusNormal:
        {
            self.recordImageView.image = [UIImage imageNamed:@"kuoquan_icon_record_default"];
            self.recordContainerView.alpha = 1.f;
            self.recordContainerView.backgroundColor = [UIColor whiteColor];
            self.recordImageView.hidden = NO;
            self.recordTitleLabel.hidden = NO;
            self.recordingTipLabel.hidden = YES;
            //record button status影响左右两个按钮的hidden状态
            self.listenContainerView.hidden = NO;
            self.saveContainerView.hidden = NO;
        }
            break;
        case kRecordButtonStatusRecording:
        {
            self.recordingTipLabel.text = @"正在录音,上滑取消";
            self.recordContainerView.backgroundColor = [UIColor TTGray4];
            self.recordContainerView.alpha = 1.f;
            self.recordingTipLabel.textColor = [UIColor TTGray2];
            self.recordImageView.hidden = YES;
            self.recordTitleLabel.hidden = YES;
            self.recordingTipLabel.hidden = NO;
            //record button status影响左右两个按钮的hidden状态
            self.listenContainerView.hidden = YES;
            self.saveContainerView.hidden = YES;
        }
            break;
        case kRecordButtonStatusDrop:
        {
            self.recordingTipLabel.text = @"松开取消";
            self.recordingTipLabel.textColor = [UIColor TTRedMain];
            self.recordContainerView.backgroundColor = [UIColor TTRedMain];
            self.recordContainerView.alpha = 1.f;
            self.recordImageView.image = [UIImage imageNamed:@"kuoquan_icon_delete"];
            self.recordImageView.hidden = NO;
            self.recordTitleLabel.hidden = YES;
            self.recordingTipLabel.hidden = NO;
            //record button status影响左右两个按钮的hidden状态
            self.listenContainerView.hidden = YES;
            self.saveContainerView.hidden = YES;
        }
            break;
        case kRecordButtonStatusShort:
        {
            self.recordingTipLabel.text = @"录音时长不能少于5秒喔！";
            self.recordingTipLabel.textColor = [UIColor TTRedMain];
            self.recordContainerView.backgroundColor = [UIColor TTRedMain];
            self.recordContainerView.alpha = 0.1;
            self.recordImageView.hidden = YES;
            self.recordTitleLabel.hidden = YES;
            self.recordingTipLabel.hidden = NO;
            //record button status影响左右两个按钮的hidden状态
            self.listenContainerView.hidden = YES;
            self.saveContainerView.hidden = YES;
        }
            break;
        default:
        {
            self.recordImageView.image = [UIImage imageNamed:@"kuoquan_icon_record_default"];
            self.recordImageView.hidden = NO;
            self.recordTitleLabel.hidden = NO;
            self.recordingTipLabel.hidden = YES;
            //record button status影响左右两个按钮的hidden状态
            self.listenContainerView.hidden = NO;
            self.saveContainerView.hidden = NO;
        }
            break;
    }
}

#pragma mark - touch event

- (IBAction)onChangeHelpTipsButtonClicked:(id)sender {
    if (self.textArray && self.textArray.count > 0){
        self.helpTipsLabel.text = [self.textArray objectAtIndex:arc4random_uniform(self.textArray.count)];
    }
}
#pragma mark recordButton event
static CGFloat boundsExtension = 0.0f;
- (IBAction)recordButtonTouchUp:(UIButton *)sender withEvent:(UIEvent *)event{
    if (self.isTouchDown) {
        self.isTouchDown = NO;
    }else{
        return;
    }
    UITouch *touch = [[event allTouches] anyObject];
    CGRect outerBounds = CGRectInset(sender.bounds, -1 * boundsExtension, -1 * boundsExtension);
    BOOL touchOutside = !CGRectContainsPoint(outerBounds, [touch locationInView:sender]);
    if (touchOutside) {
        // UIControlEventTouchUpOutside
        self.recordButtonStatus = kRecordButtonStatusNormal;
        [Log info:NSStringFromClass(self.class) message:@"UIControlEventTouchUpOutside"];
        [self cancelRecording];
    } else {
        // UIControlEventTouchUpInside
        [Log info:NSStringFromClass(self.class) message:@"UIControlEventTouchUpInside"];
        if (self.recordDuration >= minRecordDuration) {
            self.recordButtonStatus = kRecordButtonStatusNormal;
            [self endRecording];
        }else{//录音时间小于5秒
            self.recordButtonStatus = kRecordButtonStatusShort;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.recordButtonStatus = kRecordButtonStatusNormal;
            });
            [self cancelRecording];
        }
    }
}

- (IBAction)recordButtonTouchDown:(id)sender {
    // UIControlEventTouchDown
    [Log info:NSStringFromClass(self.class) message:@"UIControlEventTouchDown"];
    if (self.recordButtonStatus == kRecordButtonStatusShort) {//short展示的那一秒钟不允许touch down
        return;
    }
    self.recordButtonStatus = kRecordButtonStatusRecording;
    self.isTouchDown = YES;
    [self startRecording];
}

- (IBAction)recordButtonDrag:(UIButton *)sender withEvent:(UIEvent *)event{
    if (!self.isTouchDown) {
        return;
    }
    UITouch *touch = [[event allTouches] anyObject];
    CGRect outerBounds = CGRectInset(sender.bounds, -1 * boundsExtension, -1 * boundsExtension);
    BOOL touchOutside = !CGRectContainsPoint(outerBounds, [touch locationInView:sender]);
    if (touchOutside) {
        BOOL previewTouchInside = CGRectContainsPoint(outerBounds, [touch previousLocationInView:sender]);
        if (previewTouchInside) {
            // UIControlEventTouchDragExit
            [Log info:NSStringFromClass(self.class) message:@"UIControlEventTouchDragExit"];
        } else {
            // UIControlEventTouchDragOutside
            [Log info:NSStringFromClass(self.class) message:@"UIControlEventTouchDragOutside"];
            self.recordButtonStatus = kRecordButtonStatusDrop;
        }
    } else {
        BOOL previewTouchOutside = !CGRectContainsPoint(outerBounds, [touch previousLocationInView:sender]);
        if (previewTouchOutside) {
            // UIControlEventTouchDragEnter
            [Log info:NSStringFromClass(self.class) message:@"UIControlEventTouchDragEnter"];
        } else {
            // UIControlEventTouchDragInside
            [Log info:NSStringFromClass(self.class) message:@"UIControlEventTouchDragInside"];
            self.recordButtonStatus = kRecordButtonStatusRecording;
        }
    }
}

#pragma mark listenButton event
- (IBAction)listenButtonClicked:(id)sender {
    switch (self.listenButtonStatus) {
        case kListenButtonStatusNormal:
        {
            NOTIFY_SERVICE_CLIENT(AudioServiceClient, @selector(onAudioPlayWillStart), onAudioPlayWillStart);
            self.listenButtonStatus = kListenButtonStatusLitening;
            if (self.audioPlayer){//上次播放没结束
                [self.audioPlayer resume];
            }else{
                if (self.tempAudioData) {//有临时的播临时的
                    self.audioPlayer = [[TTExpandAudioPlayer alloc] initWithPath:[IMAttachmentHelper fullFilePathForMyExpendVoice:[GET_SERVICE(AuthService) myAccount]]];
                }else{//没有临时的播服务器上以前录好的
                    self.audioPlayer = [[TTExpandAudioPlayer alloc] initWithUrl:self.expandMeUser.voiceUrl];
                }
                self.audioPlayer.delegate = self;
                [self.audioPlayer play];
            }
        }
            break;
        case kListenButtonStatusLitening:
        {
            NOTIFY_SERVICE_CLIENT(AudioServiceClient, @selector(onAudioPlayAllFileCompleted), onAudioPlayAllFileCompleted);
            self.listenButtonStatus = kListenButtonStatusNormal;
            [self.audioPlayer pause];
        }
            break;
        case kListenButtonStatusDisabled:
        default:
            break;
    }
}
#pragma mark saveButton event
- (IBAction)saveButtonClicked:(id)sender {
    switch (self.saveButtonStatus) {
        case kSaveButtonStatusNormal:
        {
            if(self.expandMeUser.voiceDurition > 0) {
                TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"" message:@"保存将会替换原本的语音,确定保存?"];
                [alert addButtonWithTitle:@"取消" block:^{
                    //do nothing
                }];
                [alert addButtonWithTitle:@"保存" block:^{
                    [UIUtil showLoadingWithText:@"保存中..."];
                    NSString *uuid = [[NSUUID UUID] UUIDString];
                    NSString *key = [NSString stringWithFormat:@"expandVoice-account%@-ios%@",[GET_SERVICE(AuthService) myAccount],uuid];
                    [[TTFileManager sharedManager] expandUploadData:self.tempAudioData withKey:key andTag:0 anddelegate:self];
                }];
                [alert show];
            }else{
                [UIUtil showLoadingWithText:@"保存中..."];
                NSString *uuid = [[NSUUID UUID] UUIDString];
                NSString *key = [NSString stringWithFormat:@"expandVoice-account%@-ios%@",[GET_SERVICE(AuthService) myAccount],uuid];
                [[TTFileManager sharedManager] expandUploadData:self.tempAudioData withKey:key andTag:0 anddelegate:self];
            }

        }
            break;
        case kSaveButtonStatusDisabled:
        default:
            //无需保存
            [Log info:NSStringFromClass(self.class) message:@"no record file!"];
            break;
    }
}

#pragma mark - record
- (void)startRecording{
    self.startRecordingTime = CFAbsoluteTimeGetCurrent();
    //ui
    if (self.recordTimer) {
        [self.recordTimer invalidate];
        self.recordTimer = nil;
    }
    self.recordDuration = 0;
    self.recordTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(recording:)];
    [self.recordTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    //record detect
    [self.audioPlayer resetWithoutDeleteFile];
    self.audioPlayer = nil;
    self.isListening = NO;
    
    NOTIFY_SERVICE_CLIENT(AudioServiceClient, @selector(onAudioRecordWillStart), onAudioRecordWillStart);
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(recordPermission)])
    {
        AVAudioSessionRecordPermission permission = audioSession.recordPermission;
        if ('deny' == permission)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                //还原按钮状态,结束录音
                [self endRecording];
                self.isTouchDown = NO;
                //alert
                TTAlertView *alertView = [[TTAlertView alloc] initWithTitle:@"无法录音" message:@"请在iPhone的“设置-隐私-麦克风”选项中，允许TT语音访问你的手机麦克风"];
                [alertView addButtonWithTitle:@"好" block:nil];
                [alertView show];
            });
            return;
        }
    }
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory: AVAudioSessionCategoryRecord error:nil];
    [session setActive: YES error:nil];
    
    //recort start
    self.dropCurrentAudioData = NO;
    __weak typeof(self)wself = self;
    [self.audioRecorder startRecordingWithLevelMeteringBlock:^(CGFloat averagePower, CGFloat peakPower) {
        
    } completion:^(NSData * __nullable audioData, NSTimeInterval audioDuration, AudioRecorderCompleteType completeType, NSError * __nullable error) {
        [AudioHelper setupGlobalAudioConfig];
        [Log info:NSStringFromClass(self.class) message:@"audioData length = %zd",audioData.length];
        if (wself.dropCurrentAudioData) {
            [Log info:NSStringFromClass(self.class) message:@"cancel : drop audio data!"];
            wself.tempAudioData = nil;
        }else{
            [Log info:NSStringFromClass(self.class) message:@"success : save to TEMP audio data! duration = %lf , data length = %zd",audioDuration,audioData.length];
            wself.tempAudioData = audioData;
        }
        wself.dropCurrentAudioData = NO;
        [wself updateSaveAndListenButtonStatus];
    }];
}
- (void)endRecording{
    //ui
    if (self.recordTimer) {
        [self.recordTimer invalidate];
        self.recordTimer = nil;
    }
    self.recordButtonStatus = kRecordButtonStatusNormal;
    //record
    NOTIFY_SERVICE_CLIENT(AudioServiceClient, @selector(onAudioRecordCompleted), onAudioRecordCompleted);
    self.dropCurrentAudioData = NO;
    [self.audioRecorder stopRecording];
}
- (void)cancelRecording{
    //ui
    if (self.recordTimer) {
        [self.recordTimer invalidate];
        self.recordTimer = nil;
    }
    self.recordDuration = 0;
    //record
    NOTIFY_SERVICE_CLIENT(AudioServiceClient, @selector(onAudioRecordCompleted), onAudioRecordCompleted);
    self.dropCurrentAudioData = YES;
    [self.audioRecorder stopRecording];
    
}

static NSInteger maxRecordDuration = 1800;
static NSInteger minRecordDuration = 300;
static CGFloat initStartAngle = 0 - M_PI_2;
- (void)recording:(CADisplayLink *)displayLink{
    if (self.recordDuration >= maxRecordDuration) {//录音超过你30秒,强制停止
        [self endRecording];
        self.isTouchDown = NO;
        return;
    }
    CFAbsoluteTime duration = CFAbsoluteTimeGetCurrent() - self.startRecordingTime;
    self.recordDuration = duration * 60;
}
#pragma mark - setters
- (void)setIsListening:(BOOL)isListening{
    _isListening = isListening;
    [self updateSaveAndListenButtonStatus];
}
- (void)setTempAudioData:(NSData *)tempAudioData
{
    _tempAudioData = tempAudioData;
    if (!tempAudioData) {
        return;
    }
    self.alreadySaved = NO;//audioData有更新,保存按钮状态要重置
    BOOL saveToTempSucceed = [tempAudioData writeToFile:[IMAttachmentHelper fullFilePathForMyExpendVoice:[GET_SERVICE(AuthService) myAccount]] atomically:YES];
    [Log info:NSStringFromClass(self.class) message:@"tempAudioSaveSucceed? %@", saveToTempSucceed ? @"YES" : @"NO"];
}
- (void)setRecordDuration:(NSInteger)recordDuration
{
    _recordDuration = recordDuration;
    if (self.recordDuration / 60 > 0) {//0秒数字颜色为灰,其他时候颜色为蓝
        self.secondLabel.textColor = [UIColor ARGB:0x4594FF];
        self.secondSymbolLabel.textColor = [UIColor ARGB:0x4594FF];
    }else{
        self.secondLabel.textColor = [UIColor TTGray2];
        self.secondSymbolLabel.textColor = [UIColor TTGray2];
    }
    self.secondLabel.text = [NSString stringWithFormat:@"%zd",self.recordDuration / 60];
    
    //画圆
    if (self.recordDuration <= 0) {//开始画圆的第一刻先移除原来画出来的圆
        self.startAngle = initStartAngle;
        if (self.secondLayer) {
            [self.secondLayer removeFromSuperlayer];
            self.secondLayer = nil;
        }
        if (self.secondPath) {
            self.secondPath = nil;
        }
    }
    CGFloat radian = M_PI*2 * ((CGFloat)self.recordDuration / maxRecordDuration) + initStartAngle;
    if (!self.secondLayer) {
        self.secondLayer.lineCap = kCALineCapRound;
        self.secondLayer = [CAShapeLayer layer];
        self.secondLayer.frame = self.view.bounds;
        self.secondLayer.lineWidth = 4.0;
        self.secondLayer.strokeColor = [UIColor ARGB:0x4594FF].CGColor;
        self.secondLayer.fillColor = [UIColor clearColor].CGColor;
    }
    if (!self.secondPath) {
        self.secondPath = [UIBezierPath bezierPath];
    }
    [self.secondPath addArcWithCenter:self.secondContainerView.center radius:self.secondContainerView.bounds.size.width * 0.5 - 1 startAngle:self.startAngle endAngle:radian clockwise:YES];
    self.startAngle = radian;
    [self.secondPath stroke];
    self.secondLayer.path = self.secondPath.CGPath;
    [self.view.layer addSublayer:self.secondLayer];
    [self.view setNeedsDisplay];
}

#pragma mark - TTExpandAudioPlayerProtocol
- (void)audiohavePlayed:(CGFloat)time{
    //do nothing
}
- (void)stateChangedFrom:(TTExpandAudioPlayerState)old to:(TTExpandAudioPlayerState)newState {
    [self dealPlayerState:newState];
}
- (void)dealPlayerState:(TTExpandAudioPlayerState)state {
    if (state == TTExpandAudioPlayerStateNone) {
    }else if (state == TTExpandAudioPlayerStateDownloading) {
        [UIUtil showLoadingWithText:@"下载中..."];
    }else if (state == TTExpandAudioPlayerStateDownloadComplete) {
        [UIUtil dismissLoading];
    }else if (state == TTExpandAudioPlayerStateDownloadingFail) {
        [UIUtil dismissLoading];
        [UIUtil showHint:@"下载语音失败"];
        self.audioPlayer = nil;
        self.isListening = NO;
        NOTIFY_SERVICE_CLIENT(AudioServiceClient, @selector(onAudioPlayAllFileCompleted), onAudioPlayAllFileCompleted);
    }else if (state == TTExpandAudioPlayerStatePlaying) {
        self.isListening = YES;
    }else if (state == TTExpandAudioPlayerStatePause) {
        self.isListening = NO;
        NOTIFY_SERVICE_CLIENT(AudioServiceClient, @selector(onAudioPlayAllFileCompleted), onAudioPlayAllFileCompleted);
    }else if (state == TTExpandAudioPlayerStateStop) {
        self.audioPlayer = nil;
        self.isListening = NO;
        NOTIFY_SERVICE_CLIENT(AudioServiceClient, @selector(onAudioPlayAllFileCompleted), onAudioPlayAllFileCompleted);
    }
}
#pragma mark - TTUploaderProtocol
- (void)uploadSucess:(TTUploader *)uploader withInfo:(NSDictionary *)info{
    [UIUtil showLoadingWithText:@"保存中..."];
    /**这里的事件应该是毫秒为单位*/
    @weakify(self);
    [GET_SERVICE(ExpandCircleService) updateMyVoiceUrlWithKey:info[@"key"] voiceDuration:self.recordDuration / 60 * 1000.f completeBlock:^(NSError *error){
        @strongify(self);
        if (error){
            [UIUtil showError:error];
        }else{
            self.alreadySaved = YES;
            [self updateSaveAndListenButtonStatus];
            [UIUtil showHint:@"保存成功"];
            if (!self.expandMeUser || self.expandMeUser.voiceUrl==nil || [self.expandMeUser.voiceUrl isEqualToString:@""] || self.expandMeUser.voiceDurition == 0) {//如果是第一次设置(这些都表示没有声音)
                [Log info:NSStringFromClass(self.class) message:@"用户第一次录音"];
                if([self.delegate respondsToSelector:@selector(ttExpandVoiceEditorFirstSaveVoiceComplete:)]){
                    [self.delegate ttExpandVoiceEditorFirstSaveVoiceComplete:self];
                }
                TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"" message:@"完善资料可以大大提高展示的机会喔!"];
                [alert addButtonWithTitle:@"取消" block:^{
                    [self popBackIfCan];
                }];
                [alert addButtonWithTitle:@"完善资料" block:^{
                    TTExpandEditorController *editor = [[TTExpandEditorController alloc] init];
                    NSMutableArray * viewControllers =[NSMutableArray arrayWithArray:self.navigationController.childViewControllers];
                    if(self){
                        [viewControllers removeObject:self];
                    }
                    [viewControllers addObject:editor];
                    [self.navigationController setViewControllers:viewControllers animated:YES];
                }];
                [alert show];
            }else{
                [self popBackIfCan];
            }
        }
    }];
}

- (void)uploaderFail:(TTUploader *)uploader{
    [UIUtil showHint:@"保存失败"];
}

#pragma mark - private
#pragma mark private setup
- (void)setupData{
    self.expandMeUser = [GET_SERVICE(ExpandCircleService) meUser];
    self.audioRecorder = [GET_SERVICE(AudioService) instantiateAudioRecoder];
    self.tempAudioData = nil;
    self.audioPlayer = nil;
    self.dropCurrentAudioData = NO;
    self.startAngle = initStartAngle;
    self.recordDuration = 0;
    self.startRecordingTime = 0;
    self.isTouchDown = NO;
    self.isListening = NO;
    self.alreadySaved = YES;
    [self setupTextArray];//试着说的那些数组
    
    //同步取一次
    @weakify(self);
    [GET_SERVICE(ExpandCircleService) getMyInfo:^(NSError *error) {
        @strongify(self);
        if (!error) {
            self.expandMeUser = [GET_SERVICE(ExpandCircleService) meUser];
            [self updateSaveAndListenButtonStatus];
        }
    }];
}
- (void)setupTextArray{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"tryToSay" ofType:nil];
    NSString *str = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray  *array = [str componentsSeparatedByString:@"\n"];
    NSMutableArray * textArray = [NSMutableArray array];
    for (NSString * text in array){
        if (text && ![text isEqualToString:@""] && ![text isEqualToString:@"\n"]){
            [textArray addObject:text];
        }
    }
    self.textArray = textArray;
}

- (void)setupScreen{
    if ([UIScreen mainScreen].bounds.size.height <= 568) {//适配5c 5s 5
        self.secondTopCons.constant = 0;
        self.recordViewTopCons.constant *= 1.2;
    }else{
        self.secondTopCons.constant *= RATIO;
        self.recordViewTopCons.constant *= RATIO;
    }
    self.tryTipTopCons.constant *= RATIO;
    self.tipTopCons.constant *= RATIO;
    self.recordTipTopCons.constant *= RATIO;
    
}
- (void)setupUI{
    self.title = @"语音设置";
    //borders
    self.secondContainerView.layer.borderColor = [UIColor TTGray4].CGColor;
    self.secondContainerView.layer.borderWidth = 4;
    self.listenContainerView.layer.borderColor = [UIColor ARGB:0xE3E3E3].CGColor;
    self.listenContainerView.layer.borderWidth = 0.5;
    self.saveContainerView.layer.borderColor = [UIColor ARGB:0xE3E3E3].CGColor;
    self.saveContainerView.layer.borderWidth = 0.5;
    self.recordContainerView.layer.borderColor = [UIColor ARGB:0xE3E3E3].CGColor;
    self.recordContainerView.layer.borderWidth = 0.5;
    //button status
    self.recordButtonStatus = kRecordButtonStatusNormal;
    [self updateSaveAndListenButtonStatus];
}
- (void)updateSaveAndListenButtonStatus{
    //save button
    if (self.tempAudioData && self.tempAudioData.length > 0 && !self.alreadySaved) {//有数据且没有被保存过
        self.saveButtonStatus = kSaveButtonStatusNormal;
    }else{
        self.saveButtonStatus = kSaveButtonStatusDisabled;
    }
    //listen button
    if (self.isListening) {//正在听,显示暂停
        self.listenButtonStatus = kListenButtonStatusLitening;
    }else{//不是正在听,根据数据展示不同状态
        /*
        //第一版,可以播放自己已经上传的录音
        if (self.tempAudioData || self.expandMeUser.voiceDurition > 0) {
            self.listenButtonStatus = kListenButtonStatusNormal;
        }else{
            self.listenButtonStatus = kListenButtonStatusDisabled;
        }
         */
        //第二版,只能播放临时的录音
        if (self.tempAudioData) {
            self.listenButtonStatus = kListenButtonStatusNormal;
        }else{
            self.listenButtonStatus = kListenButtonStatusDisabled;
        }
    }
}

@end
