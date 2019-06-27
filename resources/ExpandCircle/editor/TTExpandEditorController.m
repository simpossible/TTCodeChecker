//
//  TTExpandEditorController.m
//  TT
//
//  Created by simp on 2017/11/2.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandEditorController.h"
#import <TTService.h>
#import <TTFoundation/TTFoundation.h>
#import <TTService/ExpandCircleService.h>
#import "TTExpandUserInfoView.h"
#import <TTThirdPartTools/Masonry.h>
#import "TTExpandSetButton.h"
#import "TTExpandSetController.h"
#import "TTPictureChooser.h"
#import "UIUtil.h"
#import "TTFileManager.h"
#import "TTExpandVoiceEditor.h"
#import "UIColor+Extension.h"
#import "TTExpandPhotoItem.h"
#import <TTService/ImageUtil.h>

@interface TTExpandEditorController ()<TTExpandPhotosViewProtocol,TTPictureChooserProtocol,TTUploaderProtocol,TTExpandInfoProtocol,TTExpandUserProtocol>

@property (nonatomic, strong) TTExpandUserInfoView * infoView;

@property (nonatomic, strong) UIView * infosView;

@property (nonatomic, strong) TTExpandSetButton * setButton;

/**图片选择器*/
@property (nonatomic, strong) TTPictureChooser * picChooser;

@end

@implementation TTExpandEditorController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:245.0f/255 green:245.0f/255 blue:245.0f/255 alpha:1];
    // Do any additional setup after loading the view.
    
    [self initialUI];
    self.edgesForExtendedLayout = UIRectEdgeAll;
     ADD_SERVICE_CLIENT(ExpandCircleClent, self);
}

- (void)viewWillAppear:(BOOL)animated {
    
       UIImage *gray = [UIImage imageWithColor:[UIColor ARGB:0x7dDEDEDE]];
    [self.navigationController.navigationBar setShadowImage:gray];
    
    TTExpandMeUser *meuser = [GET_SERVICE(ExpandCircleService) meUser];
    meuser.delegate = self;
    [self.infoView setUser:meuser];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.infoView pauseCurrentAudio];
}

- (void)loadData {
   
}


- (void)initialUI {
    [self initialPhotosView];
    [self initialSetButton];
    [self initialNavigation];
}

- (void)initialNavigation {
    self.title = @"我";
}

- (void)initialPhotosView {
    CGFloat barHeight = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
    
    self.infoView = [[TTExpandUserInfoView alloc] initWithType:TTExpandUserInfoTypeMe];
    [self.view addSubview:self.infoView];

    CGFloat screenWidth = self.view.frame.size.width;
    CGFloat photosHeight = screenWidth * (336.0f/360) + 92;//根据比例计算高度
    self.infoView.backgroundColor = [UIColor whiteColor];
    
    [self.infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(10);
        make.top.equalTo(self.view.mas_top).offset(10 + barHeight);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.height.mas_equalTo(photosHeight);
    }];
    
    TTExpandMeUser *meuser = [GET_SERVICE(ExpandCircleService) meUser];
    self.infoView.user = meuser;
    [self.infoView setPhotosDelegate:self];
    self.infoView.delegate = self;
}

- (void)initialSetButton {
    self.setButton = [[TTExpandSetButton alloc] init];

    [self.view addSubview:self.setButton];
    
    [self.setButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.infoView.mas_bottom).offset(20);
        make.left.equalTo(self.infoView.mas_left);
        make.right.equalTo(self.infoView.mas_right);
        make.height.mas_equalTo(48);
    }];
    
    [self.setButton addTarget:self action:@selector(toSetExpand:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 图片点击事件

- (void)photoCoosedAtIndex:(NSInteger)index withItem:(TTExpandPhotoItem *)item{
    if (![item haveImage]) {
        TTActionView *action = [[TTActionView alloc] initWithTitle:nil];
        __weak typeof(self)wself = self;
        [action addButtonWithTitle:@"上传" block:^{
            [wself toUploadPictureAtIndex:index];
        }];
        [action addCancelButtonWithTitle:@"取消"];
        [action showInView:self.view];
    }else {
        TTActionView *action = [[TTActionView alloc] initWithTitle:nil];
        __weak typeof(self)wself = self;
        [action addButtonWithTitle:@"更换" block:^{
            [wself toUploadPictureAtIndex:index];
        }];
        [action addButtonWithTitle:@"删除" block:^{
            [wself toDeletePicTureAtIndex:index];
        }];
        [action addCancelButtonWithTitle:@"取消"];
        [action showInView:self.view];
    }
}

- (void)toUploadPictureAtIndex:(NSInteger)index {
    self.picChooser = [[TTPictureChooser alloc] init];
    self.picChooser.delegate = self;
    self.picChooser.tag = index;
    self.picChooser.maxPictureNumber = 1;
    [self.picChooser showOnController:self];
    
}

- (void)toDeletePicTureAtIndex:(NSInteger)index {
//     [GET_SERVICE(ExpandCircleService) updatePhotourlsForUser:nil atIndex:index withKey:@""];
    __weak typeof(self)wself = self;
    TTExpandMeUser *meuser = [GET_SERVICE(ExpandCircleService) meUser];
    [meuser.photosDic removeObjectForKey:@(index)];
    [self.infoView setUser:meuser];
    [GET_SERVICE(ExpandCircleService) updateMyPhotoUseratIndex:index withKey:@"" callBack:^(NSError *error) {
        [wself dealPhotoUrlUpresult:error];
    }];
}

#pragma mark - 跳转扩圈设置

- (void)toSetExpand:(TTExpandSetButton *)sender {
    TTExpandSetController *set = [[TTExpandSetController alloc] init];
    [self.navigationController pushViewController:set animated:YES];
}

#pragma mark - 图片选择回调

- (void)TTPictureChooseErrorWithMessge:(NSString *)message {
    if (message) {
        [UIUtil showHint:message];
    }
}

- (void)TTPictureChooseCompleteWithImages:(NSArray<UIImage *> *)images {
    if (images.count > 0) {
        UIImage *image = [images objectAtIndex:0];
        NSString *uuid = [[NSUUID UUID] UUIDString];
        NSString *key = [NSString stringWithFormat:@"ios%@",uuid];
        
        UIImage *largeImage = [ImageUtil generateIMLargeImage:image];
        NSData * data = UIImagePNGRepresentation(largeImage);
        
        [[TTFileManager sharedManager] expandUploadData:data withKey:key andTag:self.picChooser.tag anddelegate:self];
        TTExpandMeUser *meuser = [GET_SERVICE(ExpandCircleService) meUser];
        [meuser.photosDic setObject:image forKey:@(self.picChooser.tag)];
        [self.infoView setUser:meuser];
    }
}

#pragma mark - 上传回调

- (void)uploadSucess:(TTUploader *)uploader withInfo:(NSDictionary *)info{
//    [GET_SERVICE(ExpandCircleService) updatePhotourlsForUser:nil atIndex:uploader.tag withKey:info[@"key"]];
    __weak typeof(self)wself = self;
    TTExpandMeUser *meuser = [GET_SERVICE(ExpandCircleService) meUser];
    [GET_SERVICE(ExpandCircleService) updateMyPhotoUseratIndex:uploader.tag withKey:info[@"key"] callBack:^(NSError *error) {
        [wself dealPhotoUrlUpresult:error];
    }];
}

- (void)uploaderFail:(TTUploader *)uploader {
    [UIUtil showHint:@"上传失败"];
}

#pragma mark - 照片修改回调

- (void)dealPhotoUrlUpresult:(NSError *)error {
 
    if (error) {
        TTExpandMeUser *meuser = [GET_SERVICE(ExpandCircleService) meUser];
        [UIUtil showError:error];
        [self.infoView setUser:meuser];
    }
}

#pragma mark -重录声音

- (void)toReRecordVoice {
    TTExpandVoiceEditor *editor = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([TTExpandVoiceEditor class]) owner:nil options:nil] firstObject];
    [self.navigationController pushViewController:editor animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -图片被重置后

- (void)photosDownloadComplete:(TTExpandUser *)use {
    [self.infoView setUser:use];
}

- (void)dealloc{
    REMOVE_ALL_SERVICE_CLIENT(self);
}
@end
