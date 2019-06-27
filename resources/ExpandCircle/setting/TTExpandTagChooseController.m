//
//  TTExpandTagChooseController.m
//  TT
//
//  Created by simp on 2017/12/25.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandTagChooseController.h"
#import "UIColor+TTColor_Generated.h"
#import "TTCollectionTextLayout.h"
#import "TTCollectionTextCell.h"
#import "UIColor+Extension.h"
#import "TTTagChooseView.h"
#import <TTThirdPartTools/Masonry.h>
#import <TTService/ExpandCircleService.h>
#import <TTService.h>
#import <TTFoundation/TTFoundation.h>
#import "UIUtil.h"
#import <TTService/CommonChannelService+RoomHome.h>
#import <TTService/TTTagInfo.h>
#import "UIUtil.h"

@interface TTExpandTagChooseController ()<TTTagChooseViewProtocol>

@property (nonatomic, strong) TTTagChooseView * chooseView;

@property (nonatomic, strong) UILabel * titleLabel;

@property (nonatomic, strong) NSArray * tags;

@property (nonatomic, strong) NSMutableArray * orgSelectedItems;

@property (nonatomic, strong) NSMutableArray * selectedItems;

@property (nonatomic, strong) NSMutableArray * chooseItems;

@end

@implementation TTExpandTagChooseController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialData];
    [self initialUI];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // Do any additional setup after loading the view.
}

- (void)initialData {
    [self reqTags];
  
}

- (void)reqTags {
    __weak typeof(self)wself = self;
    NSArray *tags = [GET_SERVICE(ExpandCircleService) games];
    self.tags = tags;
    [self dealselcteItems];
}

- (void)dealselcteItems {
    self.orgSelectedItems = [NSMutableArray array];
    
     self.chooseItems = [NSMutableArray array];
    for (TTExpandGame *ttgame in self.tags) {
        TTTagChooseItem *item = [[TTTagChooseItem alloc] initWithTag:ttgame.gameName andUserInfo:ttgame];
        if (ttgame.isSameWithME) {
            [self.orgSelectedItems addObject:ttgame];
            item.selected = YES;
        }else {
            item.selected = NO;
        }
        [self.chooseItems addObject:item];
    }
    self.selectedItems = [NSMutableArray arrayWithArray:self.orgSelectedItems];
}

/**选中状态是否变化*/
- (BOOL)isSelectChanged {
    if (self.orgSelectedItems.count != self.selectedItems.count) {
        return YES;
    }else {
        for (TTExpandGame *ttgame in self.selectedItems) {
            if (![self.orgSelectedItems containsObject:ttgame]) {
                return YES;
            }
        }
    }
    return NO;
}


- (void)initialUI {
    [self initialChooseView];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initialTitleLabel];
    [self initialNavigation];
}

- (void)initialTitleLabel {
    self.titleLabel = [[UILabel alloc] init];
    [self.view addSubview:self.titleLabel];
    
    CGFloat nacHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
    CGFloat statuHeight = CGRectGetMaxY([[UIApplication sharedApplication]statusBarFrame]);
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(8+nacHeight+statuHeight);
        make.height.mas_equalTo(17);
        make.left.equalTo(self.view.mas_left).offset(16);
    }];
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    self.titleLabel.textColor = [UIColor TTGray2];
    self.titleLabel.text = @"最多可以选择显示3款游戏";
}

- (void)initialChooseView {

    if (!self.chooseView) {
        self.chooseView = [[TTTagChooseView alloc] initWithItems:self.chooseItems];
        self.chooseView.delegate = self;
        self.chooseView.maxSelectNumber = 3;
        self.chooseView.fontSize = 12;
        self.chooseView.tagSelectType = TTCollectionTextCellSelectStypeExpand;
        
        [self.view addSubview:self.chooseView];
        CGFloat nacHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
        CGFloat statuHeight = CGRectGetMaxY([[UIApplication sharedApplication]statusBarFrame]);
        [self.chooseView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left);
            make.right.equalTo(self.view.mas_right);
            make.top.equalTo(self.view.mas_top).offset(nacHeight+statuHeight+32);
        }];
        [self.chooseView layoutView];
    }else {
        [self.chooseView resetItems:self.chooseItems];
    }
   
    
    
}

- (void)initialNavigation {
    self.title = @"选择显示所玩游戏";
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(toSaveSetting)];
    self.navigationItem.rightBarButtonItem = saveItem;
    saveItem.enabled = NO;
    
}

#pragma mark - 保存设置
- (void)toSaveSetting{
      
    TTExpandMeUser *meuser = [GET_SERVICE(ExpandCircleService) meUser];
    __weak typeof(self)wself = self;
    [UIUtil showLoading];
    [GET_SERVICE(ExpandCircleService) updateSettingsWithGenderFillter:meuser.preferGender AutoPlay:meuser.autoPlayVoice PlayGames:self.selectedItems callBack:^(NSError *error) {
        [UIUtil dismissLoading];
        if (!error) {
            wself.orgSelectedItems = [NSMutableArray arrayWithArray:wself.selectedItems];
            wself.navigationItem.rightBarButtonItem.enabled = NO;
            [wself.navigationController popViewControllerAnimated:YES];
            [UIUtil showHint:@"保存完成"];
            if ([wself.delegate respondsToSelector:@selector(playgamesAlreadyChanged)]) {
                [wself.delegate playgamesAlreadyChanged];
            }
        }else {
            [UIUtil showError:error];
        }
    }];
    
    
}

#pragma mark - 标签布局
- (CGFloat)heightForTag {
    return 32;
}

- (UIEdgeInsets)marginForTag {
    return UIEdgeInsetsMake(6, 6, 6, 6);
}

- (UIEdgeInsets)marginForChooseView {
    return UIEdgeInsetsMake(4, 10, 0, 10);
}

/**目前支持左右padding*/
- (UIEdgeInsets)paddingForTag {
    return UIEdgeInsetsMake(0, 22, 0, 22);
}


- (CGFloat)widhtForChooseView {
    return self.view.frame.size.width;
}

/**如果到达最大的数量还选会走这个*/
- (void)maxTagSelectNumberReached {
    [UIUtil showHint:@"最多只能选择显示3款游戏哦～"];
}

- (BOOL)canBeSelectAfterMaxWithTag:(TTTagChooseItem *)item {
    return NO;
}

- (void)tagItemChoosed:(TTTagChooseItem *)item {
    [self.selectedItems addObject:item.userInfo];
    [self checkSaveState];
}

- (void)tagItemDeChoosed:(TTTagChooseItem *)item {
    if ([self.selectedItems containsObject:item.userInfo]) {
        [self.selectedItems removeObject:item.userInfo];
    }
    [self checkSaveState];
}

- (void)checkSaveState {
    if ([self isSelectChanged]) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

#pragma mark - pop 事件

- (void)popBackIfCan {
      [super popBackIfCan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
