//
//  TTExpandController.m
//  TT
//
//  Created by simp on 2017/11/3.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandController.h"
#import "TTExpandLoadingView.h"
#import <TTThirdPartTools/Masonry.h>
#import <TTService.h>
#import <TTFoundation/TTFoundation.h>
#import <TTService/ExpandCircleService.h>
#import "TTExpandEditorController.h"
#import "TTExpandUserGuidView.h"
#import "TTExpandAlert.h"
#import "TTExpandGuildController.h"
#import <TTService.h>
#import "TTExpandCircleRoundView.h"
#import "TTExpandVoiceEditor.h"
#import "UIColor+TTColor_Generated.h"
#import "YYPhotoGroupView.h"
#import "UIUtil.h"
#import "MessageViewController.h"
#import "Constants.h"
#import "NavigationUtil.h"
#import "TTExpandMatchedController.h"
#import "TTExpandRedCoinAnimater.h"
#import "TTExpandUserInfoView.h"
#import "HZPhotoBrowser.h"
#import "TTExpandEmptyController.h"
#import "TTExpandSetController.h"
#import "NavigationClientAPI.h"
#import "MyMissionWebViewController.h"
#import "TTExpandPhotoItem.h"
#import <TTService/ConversationService.h>
#import <TTService/TTLocationCenter.h>

@interface TTExpandController ()<UICollectionViewDelegate, UICollectionViewDataSource,ExpandCircleClent,TTExpandCircleRoundProtocol,TTExpandGuildProtocl,TTExpandMatchedControllerProtocol,TTExpandInfoProtocol,HZPhotoBrowserDelegate>

@property (nonatomic, strong) TTExpandLoadingView * loadingView;

/**装其他人卡片的视图*/
@property (nonatomic, strong) UICollectionView * personsCollectionView;

@property (nonatomic, strong) TTExpandUserGuidView * guideView;

@property (nonatomic, strong) TTExpandGuildController * guildController;

@property (nonatomic, strong) NSMutableArray * users;

/**循环滚动视图*/
@property (nonatomic, strong) TTExpandCircleRoundView * roundView;

@property (nonatomic, assign) NSInteger numberOfDislikeItem;

@property (nonatomic, strong) UIButton * likeButton;

@property (nonatomic, strong) UIButton * disLikeButton;

@property (nonatomic, strong) UIButton * hideCardButton;//官方人员专用

@property (nonatomic, strong) UILabel * titleLabel;
/*-------------------------------这一堆属性都是为了控制那个增加红钻的动画。。。------------------------------------------------*/
@property (nonatomic, assign) UInt32 currentDiamendCount;

@property (nonatomic, assign) UInt32 temRedCoint;

/**红钻动画增加的时候数字跳动的速度*/
@property (nonatomic, assign) UInt32 currentCointAnimateSpeed;

@property (nonatomic, strong) TTExpandMatchedController * matchedController;

/**获得红钻的播放动画*/
@property (nonatomic, strong) TTExpandRedCoinAnimater * redCoinAnimater;

@property (nonatomic, strong) NSTimer * redCoinTimer;

@property (nonatomic, assign) CFAbsoluteTime redCoindStartTime;

@property (nonatomic, assign) NSInteger redTimerCount;

/**是否正在执行红钻动画*/
@property (nonatomic, assign) BOOL isPlayRedCoin;
/*-------------------------------------------------------------------------------*/

@property (nonatomic, strong) NSArray * currentImages;

@property (nonatomic, assign) NSInteger flowerHaveSent;

@property (nonatomic, strong) UIButton * rightNavItem;

/**这里控制自动播放的逻辑*/
@property (nonatomic, assign) BOOL alreadyLoaded;

@property (nonatomic, assign) BOOL isFirstAppear;

@property (nonatomic, strong) TTExpandEmptyController * emptycontroller;

@property (nonatomic, strong) UIButton * freeQuoteButton;

@property (nonatomic, assign) BOOL isAppear;

@property (nonatomic, assign) BOOL oldViewBarIsHidden;

@end

@implementation TTExpandController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    [self initialNavigation];
    [self loadData];
    [self initialUI];
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
   
    [[TTLocationCenter center] getLoacation:^(CLLocation *location) {
        [Log info:@"TTExpandController" message:@"get location :%@",location];
    }];
    // Do any additional setup after loading the view.
}

- (void)initialUI {
    
    [self initialLikeButton];
    [self initialDisLikeButton];
    [self initialFreeLikeLabel];
    if ([ContactHelper isTTOfficialAccount:[GET_SERVICE(AuthService) myAccount]]){
//        [self initialHideCardButton];//todo...做这个功能的时候再打开
    }
    [self initialLoadingView];
    [self initialRoundView];
    //    [self initialCollectionView];
}

- (void)loadData {

    self.users = [NSMutableArray array];
    ADD_SERVICE_CLIENT(ExpandCircleClent, self);
    ADD_SERVICE_CLIENT(GrowthServiceClient, self);
    ExpandCircleService *service = GET_SERVICE(ExpandCircleService);
    [service initialService];
    
    self.alreadyLoaded = NO;
    
    GrowthService *gservice = GET_SERVICE(GrowthService);
    self.currentDiamendCount = gservice.myGrowInfo.redDiamonds;
    self.temRedCoint = self.currentDiamendCount;
    
    self.isFirstAppear = YES;
    
    
    TTExpandLikedState *likeState = [GET_SERVICE(ExpandCircleService) likeState];
    likeState.isReaded = YES;
    
    [GET_SERVICE(ConversationService) clearExpandLikeHime];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIImage *transparent = [UIImage imageNamed:@"transparent"];
    [self.navigationController.navigationBar setBackgroundImage:transparent forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:transparent];
     self.navigationController.navigationBar.tintColor = [UIColor TTGray2];
    self.navigationController.navigationBar.hidden = NO;
    self.oldViewBarIsHidden = self.navigationController.tabBarController.tabBar.hidden;
    self.navigationController.tabBarController.tabBar.hidden = YES;
    self.isAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    
      self.isAppear = NO;
    TTExpandUserInfoView *infoView = [self.roundView FirstItem].infoView;
    [infoView pauseCurrentAudio];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.isFirstAppear) {
        
         ExpandCircleService *service = GET_SERVICE(ExpandCircleService);
        if (service.shouldUpdateCards) {
            //应该重新去拉取
            self.alreadyLoaded = NO;
            [self.roundView removeFromSuperview];
            if (self.emptycontroller.view.superview) {
                [self.emptycontroller.view removeFromSuperview];
                self.emptycontroller = nil;
            }
            [self initialRoundView];
            [self initialLoadingView];
            [self.loadingView startAnimate];
            [self.users removeAllObjects];
             self.rightNavItem.hidden = YES;
            [service reInitialService];
            
        }
    }
    self.isFirstAppear = NO;
}

#pragma mark - 初始化navigation
- (void)initialNavigation {
    
    UIImage *transparent = [UIImage imageNamed:@"transparent"];
    [self.navigationController.navigationBar setBackgroundImage:transparent forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor TTGray2];
    
    //初始化title
    UILabel *label = [[UILabel alloc] init];
    self.navigationItem.titleView = label;
    label.numberOfLines = 0;
    [label sizeToFit];
    label.textAlignment = NSTextAlignmentCenter;
    self.titleLabel = label;
    [self growth_onMyGrowInfoUpdate:nil];
    
    //初始化右边按钮
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [button setImage:[UIImage imageNamed:@"navbar_icon_mycard"] forState:UIControlStateNormal];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(rightItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = right;
    
    
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [leftBtn setImage:[UIImage imageNamed:@"navbar_icon_back"] forState:UIControlStateNormal];
    UIBarButtonItem * left = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    [leftBtn addTarget:self action:@selector(leftItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = left;
    
    self.navigationController.navigationBar.shadowImage = transparent;
    
    self.rightNavItem = button;
    button.hidden = YES;
    
    
}

- (void)leftItemClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
     self.navigationController.tabBarController.tabBar.hidden = self.oldViewBarIsHidden;
}

- (void)rightItemClicked:(id)sender {
    
    ExpandCircleService *service = GET_SERVICE(ExpandCircleService);
    TTExpandMeUser *meinfo = [service meUser];
    if (!meinfo || meinfo.voiceUrl==nil || [meinfo.voiceUrl isEqualToString:@""] || meinfo.voiceDurition == 0) {//这些都表示没有声音
        [self toVoiceEditor];
    }else {
        TTExpandEditorController *editor = [[TTExpandEditorController alloc] init];
        [self.navigationController pushViewController:editor animated:YES];
    }
}

- (NSMutableAttributedString *)attributeStringWithRedDiamond:(NSInteger)diamonds {
    NSString *diamondNumber = [NSString stringWithFormat:@"%ld\n",diamonds];
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    NSTextAttachment * attach = [[NSTextAttachment alloc] init];
    attach.image = [UIImage imageNamed:@"navbar_icon_diamond"];
    attach.bounds = CGRectMake(0, 0, 16, 16);
    NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attach];
    NSMutableAttributedString *string1 = [[NSMutableAttributedString alloc] initWithString:diamondNumber];
    [string1 addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, diamondNumber.length)];
    [string1 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, diamondNumber.length)];
    
    NSMutableAttributedString *string2 = [[NSMutableAttributedString alloc] initWithString:@"我的红钻"];
    [string2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.73 green:0.73 blue:0.73 alpha:1] range:NSMakeRange(0, 4)];
    [string2 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:9] range:NSMakeRange(0, 4)];
    
    [attr appendAttributedString:string];
    [attr appendAttributedString:string1];
    [attr appendAttributedString:string2];
    return attr;
    
}


- (void)initialLoadingView {
    self.loadingView = [[TTExpandLoadingView alloc] init];
    [self.view addSubview:self.loadingView];
    
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
}

- (void)initialGuideView {
    self.guideView = [[TTExpandUserGuidView alloc] init];
    [self.view addSubview:self.guideView];
    
    [self.guideView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)initialRoundView {
    self.roundView = [[TTExpandCircleRoundView alloc] init];
    [self.view addSubview:self.roundView];
    
    CGFloat height = [UIScreen mainScreen].bounds.size.height * (427.0f/667);
    
    CGFloat nacHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
    CGFloat statuHeight = CGRectGetMaxY([[UIApplication sharedApplication]statusBarFrame]);
    [self.roundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_top).offset(statuHeight+nacHeight);
        //        make.bottom.equalTo(self.view.mas_bottom).offset(-200);
        make.height.mas_equalTo(height + 20);
    }];
    
    self.view.backgroundColor = [UIColor colorWithRed:245.0f/255 green:245.0f/255 blue:245.0f/255 alpha:1];
    self.roundView.delegate = self;
    self.roundView.hidden = YES;
}

- (void)initialDisLikeButton {
    self.disLikeButton = [[UIButton alloc] init];
    [self.view addSubview:self.disLikeButton];
    CGFloat sheight = [UIScreen mainScreen].bounds.size.height;
    CGFloat height = 83 * (sheight/667.0f); //button的中心距离底部
    CGFloat Width = 74 *(sheight/667.0f);
    Width=Width>74?74:Width;//小屏幕缩小 大屏幕不变
    [self.disLikeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view.mas_bottom).offset(-height);
        make.right.equalTo(self.view.mas_centerX).offset(-10);
        make.width.mas_equalTo(Width);
        make.height.mas_equalTo(Width);
    }];
    
    [self.disLikeButton setImage:[UIImage imageNamed:@"kuoquan_icon_dislike-1"] forState:UIControlStateNormal];
    self.disLikeButton.backgroundColor = [UIColor whiteColor];
    self.disLikeButton.layer.borderWidth = 4;
    self.disLikeButton.layer.borderColor = [UIColor TTGray4].CGColor;
    self.disLikeButton.layer.cornerRadius = Width/2;
    self.disLikeButton.layer.masksToBounds = YES;
    
    [self.disLikeButton addTarget:self action:@selector(dislikeCurrent:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)initialLikeButton {
    self.likeButton = [[UIButton alloc] init];
    [self.view addSubview:self.likeButton];
     CGFloat sheight = [UIScreen mainScreen].bounds.size.height;
     CGFloat height = 83 * (sheight/667.0f); //button的中心距离底部
    CGFloat Width = 74 *(sheight/667.0f);
    Width=Width>74?74:Width;//小屏幕缩小 大屏幕不变
    [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view.mas_bottom).offset(-height);
        make.left.equalTo(self.view.mas_centerX).offset(10);
        make.width.mas_equalTo(Width);
        make.height.mas_equalTo(Width);
    }];
    
    [self.likeButton setImage:[UIImage imageNamed:@"kuoquan_icon_flower"] forState:UIControlStateNormal];
    self.likeButton.backgroundColor = [UIColor whiteColor];
    self.likeButton.layer.borderWidth = 4;
    self.likeButton.layer.borderColor = [UIColor TTGray4].CGColor;
    self.likeButton.layer.cornerRadius = Width/2;
    self.likeButton.layer.masksToBounds = YES;
    [self.likeButton addTarget:self action:@selector(likeCurrent:) forControlEvents:UIControlEventTouchUpInside];
    
  
}

- (void)initialFreeLikeLabel {
    self.freeQuoteButton = [[UIButton alloc] init];
    [self.view addSubview:self.freeQuoteButton];
    
    [self.freeQuoteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.likeButton.mas_centerX);
        make.centerY.equalTo(self.likeButton.mas_top);
        make.height.mas_equalTo(20);
    }];
    
    [self.freeQuoteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.freeQuoteButton.titleLabel.font = [UIFont systemFontOfSize:10];
    self.freeQuoteButton.contentEdgeInsets = UIEdgeInsetsMake(3, 4, 3, 4);
    self.freeQuoteButton.backgroundColor = [UIColor TTRed];
    self.freeQuoteButton.layer.cornerRadius = 10;
    self.freeQuoteButton.userInteractionEnabled = NO;
    self.freeQuoteButton.hidden = YES;
}

- (void)initialHideCardButton{
    self.hideCardButton = [[UIButton alloc] init];
    [self.view addSubview:self.hideCardButton];
    CGFloat height = 22; //button的中心距离底部
    CGFloat Width = 64;
    [self.hideCardButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.likeButton.mas_centerY);
        make.right.equalTo(self.view.mas_right).offset(-12);
        make.width.mas_equalTo(Width);
        make.height.mas_equalTo(height);
    }];
    
    [self.hideCardButton setTitle:@"隐藏卡片" forState:UIControlStateNormal];
    [self.hideCardButton setTitleColor:[UIColor TTRedMain] forState:UIControlStateNormal];
    self.hideCardButton.titleLabel.font = [UIFont systemFontOfSize:12];
    self.hideCardButton.layer.borderWidth = 1;
    self.hideCardButton.layer.borderColor = [UIColor TTRedMain].CGColor;
    self.hideCardButton.layer.cornerRadius = 11;
    self.hideCardButton.layer.masksToBounds = YES;
    [self.hideCardButton addTarget:self action:@selector(hideCurrent:) forControlEvents:UIControlEventTouchUpInside];
    
}

/**初始化获得红钻后的动画*/
- (void)initialAnimaterWithRedCoin:(UInt32)coin {
    
    if (!self.redCoinAnimater) {
        self.redCoinAnimater = [[TTExpandRedCoinAnimater alloc] initWithRedCoin:coin];
        [self.view addSubview:self.redCoinAnimater];
        
        [self.redCoinAnimater mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.roundView.mas_left);
            make.right.equalTo(self.roundView.mas_right);
            make.bottom.equalTo(self.roundView.mas_bottom).offset(-20);
            make.top.equalTo(self.view.mas_top);
        }];
    }else {
        [self.redCoinAnimater resetRedCon:coin];
    }
   
}

- (void)animateRedCoin {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [self.loadingView startAnimate];
}

#pragma mark - 喜欢不喜欢事件

- (void)likeCurrent:(UIButton *)sender {
    TTExpandCircleRoundItem * item = [self.roundView FirstItem];
    if ([self canRoundItemDisappear:item atDirection:TTExpandCircleDirectionRight]) {
        [self expandCircleRoundItem:item WillDisappearAt:TTExpandCircleDirectionRight];
        [item toRightDisappear];
    }
}

- (void)dislikeCurrent:(UIButton *)sender {
    TTExpandCircleRoundItem * item = [self.roundView FirstItem];
    if ([self canRoundItemDisappear:item atDirection:TTExpandCircleDirectionLeft]) {
        [self expandCircleRoundItem:item WillDisappearAt:TTExpandCircleDirectionLeft];
        [item toLeftDisappear];
    }
}

#pragma mark - 审核事件

- (void)hideCurrent:(UIButton *)sender{
    //todo...
}

#pragma mark 圈子事件-

- (void)serviceInitialed:(NSError *)error {
    self.rightNavItem.hidden = NO;
    __weak typeof(self)wself = self;
    [self.loadingView stopAnimate];
    self.navigationController.navigationBar.hidden = NO;
    if (!error) {
        //消失加载页面
        [UIView animateWithDuration:0.5 animations:^{
//            [self.loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.centerX.equalTo(self.view.mas_centerX);
//                make.centerY.equalTo(self.view.mas_centerY);
//                make.width.mas_equalTo(0);
//                make.height.mas_equalTo(0);
//            }];
            wself.loadingView.alpha = 0;
            [wself.loadingView layoutIfNeeded];
        } completion:^(BOOL finished) {
            [wself showMainContents];
            [wself.loadingView removeFromSuperview];
        }];
        if (false) {//todo...判断自己的卡片是否被官方人员隐藏掉
            TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"你的卡片声音不太清晰哦,请重新编辑一下卡片吧~" message:@""];
            [alert addButtonWithTitle:@"暂不编辑" block:^{
            }];
            
            [alert addButtonWithTitle:@"编辑卡片" block:^{
                [self toVoiceEditor];
            }];
            [alert show];
        }
    }else {//出现了问题
        [wself.loadingView showErrorWithCallBack:^{
            [wself.loadingView startAnimate];
            [wself loadData];
        }];
    }
}

//加载内容
- (void)showMainContents {
    //加载内容
    [self refreshFreeCount];
    
     ExpandCircleService *service = GET_SERVICE(ExpandCircleService);
    for (int i = 0 ; i < 3; i ++) {
        TTExpandUser *user = [service popuser];
        if (user) {
            [self.users addObject:user];
        }else {
            //已经没有下一条了
            break;
        }
    }
    self.roundView.hidden = NO;
    [self.roundView loadView];
    
    if (self.users.count == 0) {//没有匹配数量
        [self showEmpty];
    }else {
        if (self.emptycontroller.view.superview) {
            [self.emptycontroller.view removeFromSuperview];
            self.emptycontroller = nil;
        }
        [self showUserGuide];
    }
    self.alreadyLoaded = YES;
    
    [self autoPlay];
}


- (void)showEmpty {
    __weak typeof(self)wself = self;
 
    if (!self.emptycontroller) {
        TTExpandEmptyController *empty = [[TTExpandEmptyController alloc] init];
        self.emptycontroller = empty;
        [empty setJumpCallBack:^{
            [wself rightItemClicked:nil];
        }];
        empty.view.alpha = 0;
        [self.view addSubview:empty.view];
        [UIView animateWithDuration:0.3 animations:^{
            empty.view.alpha = 1;
        }];
    }else {
        if (self.emptycontroller.view.superview == self.view) {
            [self.view bringSubviewToFront:self.emptycontroller.view];
        }
    }
   
    
//    self.definesPresentationContext = YES;
//    empty.modalPresentationStyle = UIModalPresentationOverCurrentContext;
//    [self.navigationController presentViewController:empty animated:YES completion:nil];
}

- (void)jumpToSetController {
    TTExpandSetController *setControoler = [[TTExpandSetController alloc] init];
    [self.navigationController pushViewController:setControoler animated:YES];
}


#pragma mark - CELL动画


#pragma mark - 循环滚动处理

- (UIEdgeInsets)edgeForRoundItem {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (void)roundItem:(TTExpandCircleRoundItem*)item insertAtIndex:(NSInteger)index {
    [GET_SERVICE(ExpandCircleService) delePopCache:item.expandUser];
    item.infoView.delegate = self;
    [item.infoView showReportButton];
    
    for (NSInteger i = 0; i < self.roundView.items.count; i ++) {
        TTExpandCircleRoundItem *citem = [self.roundView.items objectAtIndex:i];
        if (self.users.count >= i+1) {
            TTExpandUser *user = [self.users objectAtIndex:i];
            citem.expandUser = user;
        }else {
            citem.expandUser = nil;
        }
    }
    
    [self autoPlay];
}

- (void)refillUsers {
    ExpandCircleService *service = GET_SERVICE(ExpandCircleService);
    for (NSInteger i = self.users.count; i < 3; i ++) {
        TTExpandUser *user = [service popuser];
        if (user) {
            [self.users addObject:user];
        }
    }
}

-  (void)expandCircleRoundItem:(TTExpandCircleRoundItem *)item WillDisappearAt:(TTExpandCircleDirection)direction {
    ExpandCircleService *service = GET_SERVICE(ExpandCircleService);
    if (self.users.count > 0) {
        if ([self.users containsObject:item.expandUser]) {
            [self.users removeObject:item.expandUser];
        }
        [self refillUsers];
        if (self.users.count == 0) {
            [self showEmpty];
        }
    }
    
    if (direction == TTExpandCircleDirectionLeft) {
         [service dislikeUser:item.expandUser];
        self.numberOfDislikeItem ++;
        [self dealDislikeItems];
    }else {
        TTExpandUser *user = item.expandUser;
        self.flowerHaveSent += 1;
        [self infoCheck];
        __weak typeof(self)wself = self;
        [service likeUser:user expandLikeBlock:^(NSError *error, UInt32 costRedCoin, UInt32 awardRedCoin, BOOL mated) {
            if (!error) {
                if (mated) {
                    [self mateUserSucess:user];
                }else {
                    if (awardRedCoin != 0) {
                        [wself playRedCoinWith:awardRedCoin withCost:costRedCoin];
                    }
                }
            }else {
                if (error.code == -1107) {
                    [UIUtil showError:error];
                }
            }
            
            [wself refreshFreeCount];
        }];
    }
}

- (void)refreshFreeCount {
    ExpandCircleService *service = GET_SERVICE(ExpandCircleService);
    NSInteger freeCOunt = service.freeQuota;
    if (freeCOunt == 0) {
        self.freeQuoteButton.hidden = YES;
    }else {
        self.freeQuoteButton.hidden = NO;
        [self.freeQuoteButton setTitle:[NSString stringWithFormat:@"免费送 x%ld",freeCOunt] forState:UIControlStateNormal];
    }
}

/**每20次的左滑需要做处理*/
- (void)dealDislikeItems {
    if (self.numberOfDislikeItem %20 == 0) {
        ExpandCircleService *service = GET_SERVICE(ExpandCircleService);
        TTExpandMeUser *meinfo = [service meUser];
        if (!meinfo || meinfo.voiceUrl==nil || [meinfo.voiceUrl isEqualToString:@""] || meinfo.voiceDurition == 0) {//这些都表示没有声音
            [self toGuidVoiceRecord];
        }
    }
}

- (void)autoPlay {
    if (self.alreadyLoaded) {
        ExpandCircleService *service = GET_SERVICE(ExpandCircleService);
        TTExpandMeUser *meinfo = [service meUser];
        if (meinfo.autoPlayVoice && !self.matchedController) {//有匹配的界面就不播放了
            if (self.isAppear) {//如果还在当前页面才播放
                if (self.guildController){//如果是第一次进入不播放
                }else {
                    [[self.roundView FirstItem].infoView playAudio];
                }
            }
        }else {
             NOTIFY_SERVICE_CLIENT(AudioServiceClient, @selector(onAudioPlayAllFileCompleted), onAudioPlayAllFileCompleted);
        }
    }
}

/**完备性检查*/
- (void)infoCheck {
    
    if (self.flowerHaveSent == 5) {
        ExpandCircleService *service = GET_SERVICE(ExpandCircleService);
        TTExpandMeUser *meinfo = [service meUser];
        if (meinfo.voiceDurition != 0 && [meinfo isDefaultPic]) {
            [self toGuildInfoComplete];
        }
    }
}



#pragma mark - 播放红钻

- (void)playRedCoinWith:(UInt32)awardRedCoin withCost:(UInt32)cost{
    self.isPlayRedCoin = YES;
    self.redTimerCount = 0;
    [self initialAnimaterWithRedCoin:awardRedCoin];
    self.temRedCoint = self.currentDiamendCount;
      self.currentCointAnimateSpeed = (awardRedCoin-cost)/10;
    __weak typeof(self)wself = self;
    [self.redCoinAnimater playWithCompletion:^(BOOL animationFinished) {
         wself.isPlayRedCoin = NO;
        [self growth_onMyGrowInfoUpdate:nil];
    }];
    if ([self.redCoinAnimater isAvaliable]) {
        if (!self.redCoinTimer) {
            self.redCoinTimer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(redCoinAnimate) userInfo:nil repeats:YES];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.redTimerCount = 0;
                [[NSRunLoop currentRunLoop] addTimer:self.redCoinTimer forMode:NSDefaultRunLoopMode];
            });
        }
    }
}


- (void)redCoinAnimate {
    self.redTimerCount ++;
    self.temRedCoint += self.currentCointAnimateSpeed;
    if (self.redTimerCount > 10) {
        [self.redCoinTimer invalidate];
        self.redCoinTimer = nil;
        [self growth_onMyGrowInfoUpdate:nil];
    }else {
        NSMutableAttributedString *attr = [self attributeStringWithRedDiamond:self.temRedCoint];
        self.titleLabel.attributedText = attr;
        [self.titleLabel sizeToFit];
    }
  
}


#pragma mark - 匹配成功
- (void)mateUserSucess:(TTExpandUser *)user {
    TTExpandMatchedController *match = [[TTExpandMatchedController alloc] initWithMatchedUser:user];
    self.matchedController = match;
    match.delegate = self;
    [self matchedAvatorPreparedOk];
}

- (void)matchedToChatConttroler:(TTExpandUser *)user {
    self.matchedController = nil;
    
    UIStoryboard *imStoryboard = [UIStoryboard storyboardWithName:IM_STORYBOARD bundle:[NSBundle mainBundle]];    
    MessageViewController *messageController = [imStoryboard instantiateViewControllerWithIdentifier:MESSAGE_VIEW_CONTROLLER_ID];
    messageController.account = user.userName;
    messageController.titleTextString = user.nickName;
    messageController.conversationInfo = [GET_SERVICE(ConversationService) conversationInfoWithAccount:user.userName];
    [self.navigationController pushViewController:messageController animated:YES];
}

- (void)matchedAvatorPreparedOk {
    
    self.definesPresentationContext = YES;
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self.navigationController presentViewController:self.matchedController animated:NO completion:nil];
    
    TTExpandUserInfoView *infoView = [self.roundView FirstItem].infoView;
    [infoView pauseCurrentAudio];
}

- (void)matchedGoOn {
     self.matchedController = nil;
}

#pragma mark - 循环视图的交互逻辑

- (BOOL)canExpandRoundItemBedrag:(TTExpandCircleRoundItem *)item {

    return YES;
}

#pragma mark - 流程控制

/**是否可以消失 资料不完善不能喜欢*/
- (BOOL)canRoundItemDisappear:(TTExpandCircleRoundItem *)item atDirection:(TTExpandCircleDirection)direction {
    if (direction == TTExpandCircleDirectionRight) {//这里是喜欢
        ExpandCircleService *service = GET_SERVICE(ExpandCircleService);
        TTExpandMeUser *meinfo = [service meUser];
        if (!meinfo || meinfo.voiceUrl==nil || [meinfo.voiceUrl isEqualToString:@""] || meinfo.voiceDurition == 0) {//这些都表示没有声音
            [self toGuidVoiceRecord];
            return NO;
        }else {
            GrowthService *service = GET_SERVICE(GrowthService);
            ExpandCircleService *eservice = GET_SERVICE(ExpandCircleService);
            UInt32 redCoin = service.myGrowInfo.redDiamonds;
            NSInteger freeCount = eservice.freeQuota;
            if (redCoin<10 && freeCount == 0) {
                [self toDoTasKForRedCoin];
                return NO;
            }
        }
    }
    return YES;
}

/**红钻不足去做红钻任务*/
- (void)toDoTasKForRedCoin {
    __weak typeof(self)wself = self;
    
    TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"你的红钻不够啦，赶紧赚红钻吧！" message:@""];
    [alert addButtonWithTitle:@"取消" block:^{
    }];

    [alert addButtonWithTitle:@"赚红钻" block:^{
        UIStoryboard *sb = [UIStoryboard storyboardWithName:PERSONAL_STORYBOARD bundle:[NSBundle mainBundle]];
        MyMissionWebViewController *myMissionWebViewController = [sb instantiateViewControllerWithIdentifier:@"MyMissionWebViewController"];
        [wself.navigationController pushViewController:myMissionWebViewController animated:YES];
    }];
    [alert show];
}

/**跳转去设置语音*/
- (void)toVoiceEditor {

    TTExpandVoiceEditor *editor = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([TTExpandVoiceEditor class]) owner:nil options:nil] firstObject];
    editor.delegate = self;
    [self.navigationController pushViewController:editor animated:YES];
}

#pragma mark - 首次录音事件

- (void)ttExpandVoiceEditorFirstSaveVoiceComplete:(TTExpandVoiceEditor *)controller {
    __weak typeof(self)wself = self;
    [GET_SERVICE(ExpandCircleService) updateFreeQuotoWithCallBack:^(NSError *error) {
        if (!error) {
            [wself refreshFreeCount];
        }
    }];
}


- (void)expandAlertClicked:(id)sender {
    
}

/**引导去语音录制*/
- (void)toGuidVoiceRecord {
    TTExpandAlert *alert = [[TTExpandAlert alloc] init];
    alert.info =  @"录制你的声音，开始探索扩圈吧！";
    alert.image = [UIImage imageNamed:@"pop_record"];
    alert.buttonTitle = @"去录制";
    [alert showOnView:self.view];
    __weak typeof(self)wself = self;
    [alert setCallback:^{
        [wself toVoiceEditor];
    }];
}

/**引导完善资料*/
- (void)toGuildInfoComplete {
    TTExpandAlert *alert = [[TTExpandAlert alloc] init];
    alert.info =  @"完善资料可以大大提高展示的机会喔！";
    alert.image = [UIImage imageNamed:@"pop_data"];
    alert.buttonTitle = @"完善资料";
    [alert showOnView:self.view];
    __weak typeof(self)wself = self;
    [alert setCallback:^{
        [wself rightItemClicked:nil];
    }];
}


#pragma mark - 新手引导

- (void)showUserGuide {
    ExpandCircleService *service = GET_SERVICE(ExpandCircleService);
    if (![service everUsedExpand]) {//是否是第一次进入
        
        self.guildController = [[TTExpandGuildController alloc] init];
        self.guildController.delegate = self;
        
        self.definesPresentationContext = YES;
        self.guildController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self.navigationController presentViewController:self.guildController animated:YES completion:nil];
    }
}

- (void)guildComplete {
    if (self.guildController.view.superview) {
        [self.guildController.view removeFromSuperview];
    }
    self.guildController = nil;
    [self autoPlay];
}

#pragma mark - 图片点击事件

- (void)expandUser:(TTExpandUser *)user PhotoClickedAtIndex:(NSInteger)index fromViews:(NSArray *)views {
  
    if ([views[index] haveImage]) {
        NSMutableArray * images = [NSMutableArray array];;
        NSInteger currentIndex=0;
        for (int i=0; i < user.photoUrls.count; i ++) {
            UIImage * image = [user.photosDic objectForKey:@(i)];
            if (image) {
                [images addObject:image];
                if (i < index) {
                    currentIndex ++;
                }
            }
            
        }
        NSMutableArray * resumeViews = [NSMutableArray array];
        for (TTExpandPhotoItem * resumeView in views) {
            if ([resumeView haveImage]) {
                [resumeViews addObject:resumeView];
            }
        }
        self.currentImages = images;
        
        HZPhotoBrowser *browserVc = [[HZPhotoBrowser alloc] init];
        browserVc.sourceImagesContainerView = self.view; // 原图的父控件
        browserVc.imageCount = images.count; // 图片总数
        browserVc.currentImageIndex = (int)currentIndex;
        browserVc.delegate = self;
        browserVc.ttSourceView = (UIView *)views[index];
        browserVc.ttSourceViews = resumeViews;
        [browserVc show];
    }

}


- (UIImage *)photoBrowser:(HZPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index {
    return  [self.currentImages objectAtIndex:index];
}
- (NSURL *)photoBrowser:(HZPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index {
    return nil;
}

#pragma mark - 刷新红钻数量

- (void)refreshRedCoinCount {
  
    NSMutableAttributedString *attr = [self attributeStringWithRedDiamond:self.currentDiamendCount];
    self.titleLabel.attributedText = attr;
    [self.titleLabel sizeToFit];
}

- (void)growth_onMyGrowInfoUpdate:(TTMyGrowInfo *)myGrowInfo {
    if (!self.isPlayRedCoin) {
        GrowthService *service = GET_SERVICE(GrowthService);
        self.currentDiamendCount = service.myGrowInfo.redDiamonds;
        [self refreshRedCoinCount];
    }
  
}

- (void)toReportUser:(TTExpandUser *)user {
    TTActionView *alert = [[TTActionView alloc] initWithTitle:nil];
    __weak typeof(self)wself = self;
    [alert addButtonWithTitle:@"举报" block:^{
        [NavigationUtil viewController:self navigationToReportPage:ReportTypeContact parameter:@{@"report_account":user.userName}];
    }];
    [alert addCancelButtonWithTitle:@"取消"];
    [alert showInView:self.view];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)dealloc {
    REMOVE_SERVICE_CLIENT(ExpandCircleClent, self);
    ExpandCircleService *service = GET_SERVICE(ExpandCircleService);
    for (TTExpandCircleRoundItem *item in self.roundView.items) {
        [service delePopCache:item.expandUser];
    }
}

- (void)ttexpandDataRefreshed {
    ExpandCircleService *service = GET_SERVICE(ExpandCircleService);
    if ([service isInitialed]) {
        if (self.emptycontroller) {
            if (self.emptycontroller.view.superview) {
                [self.emptycontroller.view removeFromSuperview];
                self.emptycontroller = nil;
            }
            [self showMainContents];
        }else {
        }
    }   
}

@end
