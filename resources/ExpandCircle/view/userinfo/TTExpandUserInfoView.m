//
//  TTExpandUserInfoView.m
//  TT
//
//  Created by simp on 2017/11/2.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandUserInfoView.h"
#import "TTExpandPhotosView.h"
#import <TTThirdPartTools/Masonry.h>
#import "TTExpandVoiceButton.h"
#import "UIColor+TTColor_Generated.h"
#import "TTCollectionTextLayout.h"
#import "TTCollectionTextCell.h"
#import "UIColor+Extension.h"
#import "TTTagChooseView.h"
#import <TTService/AudioService.h>
#import <TTService/AudioServiceClient.h>
#import <TTFoundation/TTFoundation.h>

@interface TTExpandUserInfoView ()<TTExpandUserProtocol,UICollectionViewDelegate,UICollectionViewDataSource,TTExpandPhotosViewProtocol,TTTagChooseViewProtocol>

@property (nonatomic, strong) TTExpandPhotosView * photosView;

@property (nonatomic, strong) UILabel * nameLabel;

@property (nonatomic, strong) UILabel * locationLabel;

@property (nonatomic, strong) TTExpandVoiceButton * voiceButton;

@property (nonatomic, strong) UICollectionView * playGames;

@property (nonatomic, strong) UIImageView * gengerView;

@property (nonatomic, strong) UIImageView * genderView;

/**动心过的*/
@property (nonatomic, strong) UILabel * hearBeated;

@property (nonatomic, assign) TTExpandUserInfoType type;

@property (nonatomic, strong) UIButton * likeImageIcon;

@property (nonatomic, strong) UIButton * disLikeImageIcon;

/**举报按钮*/
@property (nonatomic, strong) UIButton * reportButton;

@property (nonatomic, strong) TTTagChooseView * chooseView;

/**一张手的图片*/
@property (nonatomic, strong) UIButton * handGuildButton;

@end

@implementation TTExpandUserInfoView

- (instancetype)initWithType:(TTExpandUserInfoType)type {
    if (self = [super init]) {
        _type = type;
        [self initialUI];
    }
    return self;
}


- (void)initialUI {
    [self initialPhotosView];
    [self initialVoiceButton];
    
    [self initialLocationView];
    [self initialNameLabel];
    [self initialGenderView];
    [self initialCollections];
    [self initialHeartBeated];
    [self initialDisLikeIcon];
    [self initialLikeIcon];
    [self initialReportButton];
    
    if (self.type == TTExpandUserInfoTypeMe) {
        [self initialHandGuidView];
    }
    
    self.layer.cornerRadius = 14;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderColor = [UIColor TTGray4].CGColor;
    self.layer.borderWidth = 1;
}


- (void)initialPhotosView {
    self.photosView = [[TTExpandPhotosView alloc] init];
    self.photosView.type = self.type;
    self.photosView.delegate = self;
    [self addSubview: self.photosView];
    [self.photosView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom).offset(-91);
    }];
}

- (void)initialVoiceButton {

    self.voiceButton = [[TTExpandVoiceButton alloc] initWithType:(TTExpandVoiceButtonType)self.type];
    [self addSubview:self.voiceButton];
    
    [self.voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.photosView.mas_bottom);
        make.height.mas_equalTo(40);
    }];
    
    self.voiceButton.backgroundColor = [UIColor whiteColor];
    self.voiceButton.layer.cornerRadius = 20;
    self.voiceButton.layer.masksToBounds = YES;
    [self.voiceButton addRecortTarget:self andSel:@selector(toRecord)];
}

/**重新录制声音*/
- (void)toRecord {
    if ([self.delegate respondsToSelector:@selector(toReRecordVoice)]) {
        [self.delegate toReRecordVoice];
    }
}

- (void)initialNameLabel {
    self.nameLabel = [[UILabel alloc] init];
    [self addSubview:self.nameLabel];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(12);
        make.top.equalTo(self.voiceButton.mas_bottom).offset(2);
        make.height.mas_equalTo(28);
        make.right.lessThanOrEqualTo(self.locationLabel.mas_left).offset(-26);
    }];
    self.nameLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightSemibold];
    self.nameLabel.textColor = [UIColor TTGray1];
    [self.nameLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)initialGenderView {
    self.genderView = [[UIImageView alloc] init];
    [self addSubview:self.genderView];
    
    [self.genderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(24);
        make.height.mas_equalTo(24);
        make.left.equalTo(self.nameLabel.mas_right);
        make.centerY.equalTo(self.nameLabel.mas_centerY);
    }];
}

- (void)initialLocationView {
    self.locationLabel = [[UILabel alloc] init];
    [self addSubview:self.locationLabel];
    
    [self.locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-12);
        make.top.equalTo(self.voiceButton.mas_bottom).offset(2);
        make.height.mas_equalTo(17);
    }];
    
    self.locationLabel.font = [UIFont systemFontOfSize:12];
    self.locationLabel.textColor = [UIColor TTGray2];
    [self.locationLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];

}

- (void)initialCollections {
    
    /******使用新组建替换这个******/
    
    self.chooseView = [[TTTagChooseView alloc] initWithItems:nil];
    self.chooseView.delegate = self;
    self.chooseView.maxSelectNumber = 3;
    self.chooseView.fontSize = 8;
    self.chooseView.tagSelectType = TTCollectionTextCellSelectStypeCircle;
    
    [self addSubview:self.chooseView];
    [self.chooseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.height.mas_equalTo(17);
        make.bottom.equalTo(self.mas_bottom).offset(-12);
    }];
     [self.chooseView layoutView];
    self.chooseView.userInteractionEnabled = NO;

}

- (void)initialHandGuidView {
    if (!self.handGuildButton) {
        self.handGuildButton = [[UIButton alloc] init];
        [self addSubview:self.handGuildButton];
        
        [self.handGuildButton setImage:[UIImage imageNamed:@"kuoquan_edit_icon_click"] forState:UIControlStateNormal];
        [self.handGuildButton setTitle:@"点击更换图片" forState:UIControlStateNormal];
        [self.handGuildButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(18);
            make.left.equalTo(self.mas_left).offset(10);
            make.top.equalTo(self.mas_top).offset(10);
        }];
        
        self.handGuildButton.layer.cornerRadius = 9;
        self.handGuildButton.backgroundColor = [UIColor ARGB:0xCC000000];
        self.handGuildButton.titleLabel.font = [UIFont systemFontOfSize:10];
        [self.handGuildButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.handGuildButton.userInteractionEnabled = NO;
        self.handGuildButton.contentEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
    }
}

#pragma mark - tagChooseView的代理

- (CGFloat)heightForTag {
    return 17;
}

- (UIEdgeInsets)marginForTag {
    return UIEdgeInsetsMake(0, 2, 0, 2);
}

- (UIEdgeInsets)marginForChooseView {
    return UIEdgeInsetsMake(0, 12, 0, 0);
}

/**目前支持左右padding*/
- (UIEdgeInsets)paddingForTag {
    return UIEdgeInsetsMake(0, 6, 0, 6);
}


- (CGFloat)widhtForChooseView {
    return [UIScreen mainScreen].bounds.size.width;
}

- (UIColor *)defaultBgColorForChooseView {
    return  [UIColor whiteColor];
}

- (UIColor *)selectedBgColorForChooseView {
    return  [UIColor whiteColor];
}

- (UIColor *)selectedTextColorForChooseView {
      return [UIColor ARGB:0x4594FF];
    
}
- (UIColor *)defaultTextColorForChooseView {
    return [UIColor TTGray2];
}

/**----------------------*/

- (void)initialLikeIcon {
    self.likeImageIcon = [[UIButton alloc] init];
    [self.likeImageIcon setImage:[UIImage imageNamed:@"kuoquan_icon_flower"] forState:UIControlStateNormal];
    [self addSubview:self.likeImageIcon];
    CGFloat sheight = [UIScreen mainScreen].bounds.size.height;
    CGFloat Width = 74 *(sheight/667.0f);
    Width=Width>74?74:Width;//小屏幕缩小 大屏幕不变
    [self.likeImageIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(20);;
        make.top.equalTo(self.mas_top).offset(20);
        make.height.mas_equalTo(Width);
        make.width.mas_equalTo(Width);
    }];
    self.likeImageIcon.hidden = YES;
    
    self.likeImageIcon.backgroundColor = [UIColor whiteColor];
    self.likeImageIcon.layer.cornerRadius = Width/2;
    self.likeImageIcon.layer.masksToBounds = YES;
}

- (void)initialDisLikeIcon {
    self.disLikeImageIcon = [[UIButton alloc] init];
    [self.disLikeImageIcon setImage:[UIImage imageNamed:@"kuoquan_icon_dislike-1"] forState:UIControlStateNormal];
    [self addSubview:self.disLikeImageIcon];
    CGFloat sheight = [UIScreen mainScreen].bounds.size.height;
    CGFloat Width = 74 *(sheight/667.0f);
    Width=Width>74?74:Width;//小屏幕缩小 大屏幕不变
    [self.disLikeImageIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-20);;
        make.top.equalTo(self.mas_top).offset(20);
        make.height.mas_equalTo(Width);
        make.width.mas_equalTo(Width);
    }];
    self.disLikeImageIcon.hidden = YES;
    self.disLikeImageIcon.backgroundColor = [UIColor whiteColor];
    self.disLikeImageIcon.layer.cornerRadius = Width/2;
    self.disLikeImageIcon.layer.masksToBounds = YES;
}

- (void)initialReportButton {
    self.reportButton = [[UIButton alloc] init];
    [self addSubview:self.reportButton];
    
    [self.reportButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-8);
        make.top.equalTo(self.mas_top).offset(8);
    }];
    
    [self.reportButton setImage:[UIImage imageNamed:@"kuoquan_icon_more"] forState:UIControlStateNormal];
    [self.reportButton addTarget:self action:@selector(reportButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.reportButton.hidden = YES;
}

- (void)reportButtonClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(toReportUser:)]) {
        [self.delegate toReportUser:self.user];
    }
}

- (void)initialHeartBeated {
    self.hearBeated = [[UILabel alloc] init];
    [self addSubview:self.hearBeated];
    
    [self.hearBeated mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-12);
        make.height.mas_equalTo(14);
        make.bottom.equalTo(self.mas_bottom).offset(-12);
    }];
    
    self.hearBeated.font = [UIFont systemFontOfSize:10];
    self.hearBeated.textColor = [UIColor TTYellowMain];
    self.hearBeated.hidden = YES;
    self.hearBeated.text = @"TA曾经对你心动过";
}


- (void)setUser:(TTExpandUser *)user {
    _user = user;
    [self loadUserInfo];
    if (user == nil) {
        [self.voiceButton clearState];
    }
}

- (void)loadUserInfo {
//    self.user.delegate = self;
    
    UIImage *current;//记录只有一个image的情况
    for (int i= 0; i < 4; i ++) {
        UIImage *image = [self.user.photosDic objectForKey:@(i)];
        [self.photosView setImage:image AtIndex:i];
        if (image) {
            current = image;
        }
    }
    
    if (self.type == TTExpandUserInfoTypeOther && _user.avilableUrlCount == 1) {
        [self.photosView setBigImage:current];
    }else {
        [self.photosView setBigImage:nil];
    }
    
    [self.nameLabel setText: self.user.nickName];
    NSString *province = self.user.location.province;
    province = province==nil?@"":province;
    NSString *city = self.user.location.city;
    city = city == nil?@"":city;
    NSString *location = [NSString stringWithFormat:@"%@.%@",province,city];
    
    [self.locationLabel setText:location];
    [self.playGames reloadData];
    
    [self changeGender:self.user.gender];
    
    self.voiceButton.totoalLength = self.user.voiceDurition/1000;
    [self.voiceButton resetVoiceButtonWithUrl:self.user.voiceUrl];
    self.hearBeated.hidden = !self.user.likeMe;

    NSMutableArray *array = [NSMutableArray array];
    for (TTExpandGame *ttgame in _user.playGames) {
         TTTagChooseItem *item = [[TTTagChooseItem alloc] initWithTag:ttgame.gameName andUserInfo:nil];
        if (ttgame.isSameWithME) {
            item.selected = YES;
        }else {
            item.selected = NO;
        }
        [array addObject:item];
    }
    [self.chooseView resetItems:array];
}

- (void)photoDownloadOk:(TTExpandUser*)user AtIndex:(NSInteger)index {
    UIImage *image = [user.photosDic objectForKey:@(index)];
    [self.photosView setImage:image AtIndex:index];
}

#pragma mark - 图片点击事件
- (void)setPhotosDelegate:(id<TTExpandPhotosViewProtocol>)phtosDelegate {
    self.photosView.delegate = phtosDelegate;
}

- (void)changeGender:(TTExpandUserGender)gender {
    if (gender == TTExpandUserGenderFemale) {
        [self.genderView setImage:[UIImage imageNamed:@"kuoquan_icon_woman"]];
    }else {
        [self.genderView setImage:[UIImage imageNamed:@"kuoquan_icon_man"]];
    }
}

#pragma mark - 音频事件

- (void)audioReset {
    [self.voiceButton clearState];
}

- (void)pauseCurrentAudio {
    NOTIFY_SERVICE_CLIENT(AudioServiceClient, @selector(onAudioPlayAllFileCompleted), onAudioPlayAllFileCompleted);
    [self.voiceButton stop];
}

#pragma mark  喜欢不喜欢的状态

- (void)dealCurrentDirection:(TTExpandCircleDirection)direction {
    if (direction == TTExpandCircleDirectionLeft) {
        self.disLikeImageIcon.hidden = NO;
        self.likeImageIcon.hidden = YES;
    }else {
        self.disLikeImageIcon.hidden = YES;
        self.likeImageIcon.hidden = NO;
    }
}

- (void)clearDirection {
    self.disLikeImageIcon.hidden = YES;
    self.likeImageIcon.hidden = YES;
}

- (void)showReportButton {
    self.reportButton.hidden = NO;
}

- (void)playAudio {
    [self.voiceButton play];
}

@end
