//
//  TTExpandMatchedController.m
//  TT
//
//  Created by simp on 2017/12/27.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandMatchedController.h"
#import <TTService.h>
#import <TTFoundation/TTFoundation.h>
#import <TTService/ExpandCircleService.h>
#import "LOTAnimationView+TT.h"
#import <TTThirdPartTools/Masonry.h>
#import "UIColor+Extension.h"
#import "UIColor+TTColor_Generated.h"
#import "UIImageView+AvatarService.h"

@interface TTExpandMatchedController ()

@property (nonatomic, strong) TTExpandUser * oppUser;

@property (nonatomic, strong) TTExpandUser * meUser;

@property (nonatomic, strong) UIImageView * meAvatorView;

@property (nonatomic, strong) UIImageView * oppAvatorView;

@property (nonatomic, strong) LOTAnimationView * animateView;

@property (nonatomic, strong) UIButton * beginChatButton;

@property (nonatomic, strong) UIButton * goOnButton;

@property (nonatomic, strong) UILabel * titleLabel;

@property (nonatomic, strong) UILabel * subTitleLabel;

@property (nonatomic, strong) UIImage * oppAvatorImage;

@end

@implementation TTExpandMatchedController

- (instancetype)initWithMatchedUser:(TTExpandUser *)user {
    if (self = [super init]) {
        TTExpandMeUser *meuser = [GET_SERVICE(ExpandCircleService) meUser];
        self.meUser = meuser;
        self.oppUser = user;
    }
    return self;
}

- (void)setDelegate:(id<TTExpandMatchedControllerProtocol>)delegate {
    _delegate = delegate;
    [self reqData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialUI];
    // Do any additional setup after loading the view.
}

- (void)initialUI {
    [self initialLotView];
    [self initialTitleLabel];
    [self initialSubTitleLabel];
    [self initialMeAvator];
    [self initialOppAvator];
    
    [self initialGoOnButton];
    [self initialchatButton];
   [self reqData];
    self.view.backgroundColor = [UIColor ARGB:0xE6FFFFFF];
}

- (void)reqData {
//    if (!self.oppAvatorImage) {
//          AvatarService *avatorService = GET_SERVICE(AvatarService);
        __weak typeof(self)wself = self;
        [self.oppAvatorView setImageWithAvatarForAccount:self.oppUser.userName];
//        if (self.oppUser.userName.length != 0) {
//            NSString *ttaccount = self.oppUser.userName;
//            [avatorService downloadAvatarImageForAccount:ttaccount type:AvatarType_Small completion:^(NSString *outAccount, UIImage *image, NSError *error) {
//                if (image) {
//                    wself.oppAvatorImage = image;
//                    wself.oppAvatorView.image = wself.oppAvatorImage;
//                    if ([wself.delegate respondsToSelector:@selector(matchedAvatorPreparedOk)]) {
//                        [wself.delegate matchedAvatorPreparedOk];
//                    }
//                }else {
//                    [wself reqData];
//                }
//            }];
//        }

//    }
}

- (void)initialTitleLabel {
    self.titleLabel = [[UILabel alloc] init];
    [self.view addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(110);
        make.height.mas_equalTo(33);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    self.titleLabel.font = [UIFont systemFontOfSize:24];
    self.titleLabel.textColor = [UIColor TTGray1];
    self.titleLabel.text = @"你们已经相互喜欢";
}

- (void)initialSubTitleLabel {
    self.subTitleLabel = [[UILabel alloc] init];
    [self.view addSubview:self.subTitleLabel];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(4);
        make.centerX.equalTo(self.titleLabel.mas_centerX);
        make.height.mas_equalTo(22);
    }];
    self.subTitleLabel.font = [UIFont systemFontOfSize:16];
     self.subTitleLabel.textColor = [UIColor TTGray2];
    self.subTitleLabel.text = @"不如打破僵局吧？";
}

- (void)initialOppAvator {
    self.oppAvatorView = [[UIImageView alloc] init];
    [self.view addSubview:self.oppAvatorView];
    
    [self.oppAvatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subTitleLabel.mas_bottom).offset(38);
        make.left.equalTo(self.view.mas_right);
        make.height.mas_equalTo(100);
        make.width.mas_equalTo(100);
    }];
    
    self.oppAvatorView.layer.cornerRadius = 50;
    self.oppAvatorView.layer.borderWidth = 4;
    self.oppAvatorView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.oppAvatorView.image = self.oppAvatorImage;
    self.oppAvatorView.layer.masksToBounds = YES;
}

- (void)initialMeAvator {
    self.meAvatorView = [[UIImageView alloc] init];
    [self.view addSubview:self.meAvatorView];
    [self.meAvatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subTitleLabel.mas_bottom).offset(38);
        make.right.equalTo(self.view.mas_left);
        make.height.mas_equalTo(100);
        make.width.mas_equalTo(100);
    }];
    self.meAvatorView.layer.borderWidth = 4;
    self.meAvatorView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.meAvatorView.layer.cornerRadius = 50;
    self.meAvatorView.backgroundColor = [UIColor redColor];
    [self.meAvatorView setImageWithAvatarForAccount:[GET_SERVICE(AuthService) myAccount]];
    self.meAvatorView.layer.masksToBounds = YES;
}

- (void)animateAvator {
    [self.oppAvatorView layoutIfNeeded];
    [self.meAvatorView layoutIfNeeded];
    CGFloat width = self.view.frame.size.width;
    CGFloat y = self.meAvatorView.center.y;
    
    CAKeyframeAnimation *oppAniMation = [CAKeyframeAnimation animation];
    UIBezierPath *oppPath = [UIBezierPath bezierPath];
    [oppPath moveToPoint:self.oppAvatorView.center];
    [oppPath addLineToPoint:CGPointMake(width/2 -5, y)];
    [oppPath addLineToPoint:CGPointMake(width/2+45, y+0.5)];
 
    oppAniMation.path = oppPath.CGPath;
    oppAniMation.duration = 1;
    oppAniMation.removedOnCompletion = NO;
    oppAniMation.fillMode = kCAFillModeForwards;
    oppAniMation.keyPath = @"position";
    [self.oppAvatorView.layer addAnimation:oppAniMation forKey:nil];
    
    
    CAKeyframeAnimation *meAnimation = [CAKeyframeAnimation animation];
    UIBezierPath *mePath = [UIBezierPath bezierPath];
    [mePath moveToPoint:self.meAvatorView.center];
     [mePath addLineToPoint:CGPointMake(width/2+5, y)];
    [mePath addLineToPoint:CGPointMake(width/2-45, y+0.5)];
   
    meAnimation.path = mePath.CGPath;
    meAnimation.duration = 1;
    meAnimation.removedOnCompletion = NO;
    meAnimation.fillMode = kCAFillModeForwards;
    meAnimation.keyPath = @"position";
    [self.meAvatorView.layer addAnimation:meAnimation forKey:nil];

    [self.animateView play];
//    CAAnimationGroup *group = [CAAnimationGroup animation];
//    group.animations = @[oppAniMation,meAnimation];
//    group.duration = 1;
//    group.removedOnCompletion = NO;
//    group.fillMode = kCAFillModeForwards;
    
}

- (void)initialLotView {
    self.animateView = [LOTAnimationView animationNamed:@"expand_scatter.json" rootDir:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"assets/TTLOTLocalResource/expand_guide"] subDir:@"expand_mate"];//[LOTAnimationView animationNamed:@"expand_ scatter.json"];
    [self.view addSubview:self.animateView];
    
    [self.animateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
}

- (void)initialchatButton {
    self.beginChatButton = [[UIButton alloc] init];
    [self.view addSubview:self.beginChatButton];
    
    [self.beginChatButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(40);
        make.right.equalTo(self.view.mas_right).offset(-39);
        make.bottom.equalTo(self.goOnButton.mas_top).offset(-20);
        make.height.mas_equalTo(44);
    }];
    self.beginChatButton.layer.cornerRadius = 22;
    self.beginChatButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.beginChatButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.beginChatButton.backgroundColor = [UIColor ARGB:0xFF4594FF];
    [self.beginChatButton setTitle:@"开始聊天" forState:UIControlStateNormal];
    [self.beginChatButton addTarget:self action:@selector(toChat) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initialGoOnButton {
    self.goOnButton = [[UIButton alloc] init];
    [self.view addSubview:self.goOnButton];
    
    [self.goOnButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(40);
        make.right.equalTo(self.view.mas_right).offset(-39);
        make.bottom.equalTo(self.view.mas_bottom).offset(-100);;
        make.height.mas_equalTo(44);
    }];
    
    [self.goOnButton setTitle:@"继续探索" forState:UIControlStateNormal];
    self.goOnButton.layer.cornerRadius = 22;
    self.goOnButton.layer.borderWidth =1;
    self.goOnButton.layer.borderColor = [UIColor ARGB:0xFF4594FF].CGColor;
    self.goOnButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.goOnButton setTitleColor:[UIColor ARGB:0xFF4594FF] forState:UIControlStateNormal];
    [self.goOnButton addTarget:self action:@selector(toGoOn) forControlEvents:UIControlEventTouchUpInside];
    self.goOnButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.001];
    
}

- (void)toGoOn {
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([self.delegate respondsToSelector:@selector(matchedGoOn)]) {
        [self.delegate matchedGoOn];
    }
}

- (void)toChat {
     [self dismissViewControllerAnimated:YES completion:nil];
    if ([self.delegate respondsToSelector:@selector(matchedToChatConttroler:)]) {
        [self.delegate matchedToChatConttroler:self.oppUser];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [self animateAvator];
}

- (void)showOnController:(UIViewController *)controller {
    controller.definesPresentationContext = YES;
    controller.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [controller.navigationController presentViewController:self animated:YES completion:nil];
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
