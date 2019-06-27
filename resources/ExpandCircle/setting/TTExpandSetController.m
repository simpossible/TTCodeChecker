//
//  TTExpandSetController.m
//  TT
//
//  Created by simp on 2017/12/20.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandSetController.h"
#import <TTThirdPartTools/Masonry.h>
#import "TTExpandSetCell.h"
#import <TTService/ExpandCircleService.h>
#import <TTService.h>
#import <TTFoundation/TTFoundation.h>
#import "TTExpandsSetGamesCell.h"
#import "TTExpandSetHeaderView.h"
#import "TTExpandSetSwitchCell.h"
#import "UIColor+Extension.h"
#import <TTService/TTExpandMeUser.h>
#import "UIUtil.h"
#import "TTExpandTagChooseController.h"
#import "UIColor+TTColor_Generated.h"

NSString * TTexpandSetAutoPlay = @"TTexpandSetAutoPlay";

NSString * TTexpandSetShowGame = @"TTexpandSetShowGame";

NSString * TTExpandSetShowGender = @"TTExpandSetShowGender";

NSString * TTExpandMeGames = @"TTExpandMeGames";

extern NSString* genderPreferForType(TTExpandPreferGenderType type);

@interface TTExpandSetController ()<UITableViewDelegate,UITableViewDataSource,TTExpandTagChooseControllerProtocol,TTExpandSetSwitchCellProtocol>

@property (nonatomic, strong) UITableView * tableView;

/**数据源*/
@property (nonatomic, strong) NSMutableDictionary * datasources;

@property (nonatomic, strong) NSDictionary * titiles;

@property (nonatomic, strong) NSDictionary * sectionHeaders;

@property (nonatomic, strong) NSDictionary * sectionHeaderHeights;

@property (nonatomic, strong) TTExpandMeUser * meuser;

@property (nonatomic, assign) BOOL currentAutoPlay;

@property (nonatomic, strong) NSArray * playGames;

@property (nonatomic, assign) TTExpandPreferGenderType genderPreferType;

/**这个只有一个直接保存起来*/
@property (nonatomic, strong) TTExpandsSetGamesCell * setGamesCell;

@end

@implementation TTExpandSetController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialData];
    [self initialUI];
    self.title = @"扩圈设置";
    self.view.backgroundColor = [UIColor colorWithRed:245.0f/255 green:245.0f/255 blue:245.0f/255 alpha:1];
    self.tableView.backgroundColor = [UIColor colorWithRed:245.0f/255 green:245.0f/255 blue:245.0f/255 alpha:1];
    // Do any additional setup after loading the view.
}

- (void)initialUI {
    [self initialTableView];
    [self initialNavigation];
}

- (void)initialTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorColor = self.tableView.backgroundColor;
}

#pragma mark - 导航栏设置

- (void)initialNavigation {        
//    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(toSaveSetting)];
//    self.navigationItem.rightBarButtonItem = saveItem;
//    saveItem.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)toSaveSetting {
    __weak typeof(self)wself = self;
    [UIUtil showLoading];
    [GET_SERVICE(ExpandCircleService) updateSettingsWithGenderFillter:self.genderPreferType AutoPlay:self.currentAutoPlay PlayGames:self.playGames callBack:^(NSError *error) {
        [UIUtil dismissLoading];
        if (!error) {
            [UIUtil showHint:@"保存成功"];
            //            [wself.tableView reloadData];
        }else {
            [UIUtil showError:error];
        }
    }];
}

#pragma mark - 初始化数据

- (void)initialData {
    TTExpandMeUser *meuser = [GET_SERVICE(ExpandCircleService) meUser];
    self.meuser = meuser;
    self.datasources = [NSMutableDictionary dictionary];
    
    [self.datasources setObject:@[TTExpandSetShowGender] forKey:@(0)];
    [self.datasources setObject:@[TTexpandSetAutoPlay] forKey:@(2)];
    
    if (meuser.playGames.count == 0) {
        [self.datasources setObject:@[TTexpandSetShowGame] forKey:@(1)];
    }else {
        [self.datasources setObject:@[TTexpandSetShowGame,TTExpandMeGames] forKey:@(1)];
    }
    
    self.titiles = @{TTexpandSetShowGame:@"显示所玩游戏",
                     TTexpandSetAutoPlay:@"自动播放语音",
                     TTExpandSetShowGender:@"显示性别"
                     };
    
    self.sectionHeaders = @{@(0):[[TTExpandSetHeaderView alloc] initWithTitle:@"向我显示"],
                            @(2):[[TTExpandSetHeaderView alloc] initWithTitle:@"应用设置"]
                            };
    self.sectionHeaderHeights = @{@(0):@(32),
                                  @(1):@(10),
                                  @(2):@(42),
                                  };
    
    self.currentAutoPlay = self.meuser.autoPlayVoice;
    self.playGames = self.meuser.playGames;
    self.genderPreferType = self.meuser.preferGender;
}

#pragma mark - tableview 代理

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datasources.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSNumber * height = [self.sectionHeaderHeights objectForKey:@(section)];
    return [height integerValue];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [self.sectionHeaders objectForKey:@(section)];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return  0.001f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arrayIdentifires = [self.datasources objectForKey:@(section)];
    return arrayIdentifires.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *arrayIdentifires = [self.datasources objectForKey:@(indexPath.section)];
    NSString *identifire = [arrayIdentifires objectAtIndex:indexPath.row];
    if ([identifire isEqualToString:TTExpandMeGames]) {
        if (!self.setGamesCell) {
            self.setGamesCell = [[TTExpandsSetGamesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifire];
        }
        if (self.meuser.playGames.count == 0) {
            return 0;
        }
        [self.setGamesCell setTags:self.meuser.playGames];
        return [self.setGamesCell currentHeight];
    }
    return 56;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *arrayIdentifires = [self.datasources objectForKey:@(indexPath.section)];
    NSString *identifire = [arrayIdentifires objectAtIndex:indexPath.row];
   
    if ([identifire isEqualToString:TTExpandMeGames]) {
        if (!self.setGamesCell) {
            self.setGamesCell = [[TTExpandsSetGamesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifire];
        }
        [self.setGamesCell setTags:self.meuser.playGames];
        return self.setGamesCell;
    }else {
        TTExpandSetCell *setCell;
        setCell = [tableView dequeueReusableCellWithIdentifier:identifire];
        if (!setCell) {
            if ([identifire isEqualToString:TTexpandSetAutoPlay]){
                setCell = [[TTExpandSetSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifire];
                TTExpandSetSwitchCell *ssetCell = (TTExpandSetSwitchCell*)setCell;
                ssetCell.delegate = self;
                
            }else {
                setCell = [[TTExpandSetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifire];
            }
        }
        
        if ([identifire isEqualToString:TTexpandSetAutoPlay]){
            TTExpandSetSwitchCell *ssetCell = (TTExpandSetSwitchCell*)setCell;
            ssetCell.delegate = self;
            [ssetCell setSwitched:self.currentAutoPlay];
        }
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        NSString * title = [self.titiles objectForKey:identifire];
        [dic setObject:title forKey:@"title"];

        if ([identifire isEqualToString:TTexpandSetAutoPlay]){
            [dic setObject:@(self.currentAutoPlay) forKey:@"autoPlay"];
        }
        
        if ([identifire isEqualToString:TTExpandSetShowGender]) {
            NSString *genderPrefer = [self ttExpandGenderPreferStringForType:self.genderPreferType];
            [dic setObject:genderPrefer forKey:@"detail"];
        }
        
        [setCell dealJson:dic];
        return setCell;
    }
    return nil;
}

#pragma mark - 跳转事件

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *arrayIdentifires = [self.datasources objectForKey:@(indexPath.section)];
    NSString *identifire = [arrayIdentifires objectAtIndex:indexPath.row];
    
    if ([identifire isEqualToString:TTExpandSetShowGender]) {
        [self toSetGender];
    }else if ([identifire isEqualToString:TTexpandSetAutoPlay]) {

    }else if ([identifire isEqualToString:TTexpandSetShowGame]) {
        [self toSelectGames];
    }
}

#pragma mark - 设置

- (void)toSetGender {
    TTActionView *action = [[TTActionView alloc] initWithTitle:nil];
    __weak typeof(self)wself = self;
    [action addButtonWithTitle:@"女生" block:^{
        [wself preGender:TTExpandPreferGenderTypefamal];
    }];
    [action addButtonWithTitle:@"男生" block:^{
        [wself preGender:TTExpandPreferGenderTypemale];
    }];
    [action addButtonWithTitle:@"不限" block:^{
        [wself preGender:TTExpandPreferGenderTypeNolimit];
    }];
    [action addCancelButtonWithTitle:@"取消"];
    [action showInView:self.view];
}

- (void)toSelectGames {
    TTExpandTagChooseController *chooseTag = [[TTExpandTagChooseController alloc] init];
    chooseTag.delegate = self;
    [self.navigationController pushViewController:chooseTag animated:YES];
}

- (void)toSetAutoPlay {
    self.currentAutoPlay = !self.currentAutoPlay;
    [self.tableView reloadData];
}

- (void)preGender:(TTExpandPreferGenderType)gender {
    self.genderPreferType = gender;

    if (self.genderPreferType != self.meuser.preferGender) {
        ExpandCircleService *service = GET_SERVICE(ExpandCircleService);
        service.shouldUpdateCards = YES;
    }
    [self setttingChanged];
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)ttExpandGenderPreferStringForType:(TTExpandPreferGenderType)type {
    switch (type) {
        case TTExpandPreferGenderTypeNolimit:
            return TTExpandPreferGenderStrNolimit;
            break;
        case TTExpandPreferGenderTypemale:
            return TTExpandPreferGenderStrmale;
            break;
        case TTExpandPreferGenderTypefamal:
            return TTExpandPreferGenderStrfamal;
            break;
            
        default:
            return @"";
            break;
    }
}

#pragma mark - 自动播放改变

- (void)switcherStateChanged:(BOOL)select {
    self.currentAutoPlay = select;
    [self setttingChanged];
}

#pragma mark - 检查设置是否有更改

/**判断当前的设置是更改过了*/
- (BOOL)isSettingsDiffred {
    if (self.currentAutoPlay != self.meuser.autoPlayVoice) {
        return YES;
    }
    if (self.genderPreferType != self.meuser.preferGender) {
        return YES;
    }
    return NO;
}

- (void)setttingChanged {
    BOOL changed = [self isSettingsDiffred];
    if (changed) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self toSaveSetting];
    }else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)showSaveItem {
}

#pragma mark  -设置游戏的回调

- (void)playgamesAlreadyChanged {
    if (self.meuser.playGames.count == 0) {
        [self.datasources setObject:@[TTexpandSetShowGame] forKey:@(1)];
    }else {
        [self.datasources setObject:@[TTexpandSetShowGame,TTExpandMeGames] forKey:@(1)];
    }
     ExpandCircleService *service = GET_SERVICE(ExpandCircleService);
    self.playGames = service.meUser.playGames;
    service.shouldUpdateCards = YES;
    [self.tableView reloadData];
    
}

#pragma mark - 状态栏

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
