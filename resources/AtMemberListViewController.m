//
//  AtMemberListViewController.m
//  TT
//
//  Created by 吕旭明 on 16/12/8.
//  Copyright © 2016年 yiyou. All rights reserved.
//

#import "AtMemberListViewController.h"
#import <TTFoundation/TTFoundation.h>
#import <TTService/ContactService.h>
#import <TTService/CustomStatisticsService.h>
#import <TTService/GuildService.h>
#import <TTService/TTContact.h>
#import <TTService/ContactService.h>
#import <TTService/ConversationService.h>
#import "Constants.h"
#import "ContactUtil.h"
#import "ContactCell.h"
#import "GuildMemberListViewController.h"
#import "MessageViewController.h"
#import "NavigationUtil.h"
#import "AddContactViewController.h"
#import "UIUtil.h"
#import "UIColor+Extension.h"
#import "UIColor+TTColor_Generated.h"
#import "UIScrollView+PullToLoadMore.h"
#import "UGCUserCell.h"
#import "TTRoomHomeEmptyView.h"
#import "NewContactViewController.h"
#import "ContactRecommendAddressViewController.h"

@interface AtMemberListViewController_atAllCell : UITableViewCell

@property (nonatomic, assign) UInt32 remainCount;
@property (weak, nonatomic) IBOutlet UILabel *atCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *atAllIcon;

@end
@implementation AtMemberListViewController_atAllCell
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.atAllIcon.layer.cornerRadius = 2.f;
    self.atAllIcon.layer.masksToBounds = YES;
}
- (void)setRemainCount:(UInt32)remainCount
{
    _remainCount = remainCount;
    NSString * remainCountText = [NSString stringWithFormat:@"剩余 %u 次",(unsigned int)remainCount];
    NSMutableAttributedString * attributedRemainCountText = [[NSMutableAttributedString alloc] initWithString:remainCountText];
    NSString *keyword = [NSString stringWithFormat:@"%u",(unsigned int)remainCount];
    NSRange countRange = [remainCountText rangeOfString:keyword];
    [attributedRemainCountText addAttribute:NSForegroundColorAttributeName value:[UIColor TTPurpleMain] range:countRange];
    self.atCountLabel.attributedText = attributedRemainCountText;
}

@end

@interface AtMemberListViewController ()<UISearchBarDelegate , UISearchDisplayDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButtonItem;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, assign) GroupTypeForAt groupTypeForAt;
@property (nonatomic, assign) UInt32 remainCount;
@property (nonatomic, assign) BOOL isAllowAtEveryone;
@property(nonatomic, assign) UInt32 groupId;
@property (nonatomic, strong) TTContact *myInfo;
@property (nonatomic, assign) GuildMemberListType memberListType;//区分普通群和总群
//选择成员数据
@property (strong, nonatomic) NSMutableArray *selectedAccount;
@property (nonatomic, strong) NSMutableArray *selectedNickName;
//兴趣群初始化数据
@property (nonatomic, strong) NSArray *groupOwnerList;
@property (nonatomic, strong) NSArray *groupCommonMemberList;
@property (nonatomic, strong) NSDictionary *groupMemberDictionary;
@property (nonatomic, strong) NSArray *searchResultMemberList;
@property (nonatomic, strong) NSDictionary *searchContentMap;
//公会群初始化数据
@property (nonatomic, strong) TTGuildGroup *group;
@property (nonatomic, strong) NSMutableSet *muteMemberList;
@property (nonatomic, assign) BOOL isReloading;
@property (nonatomic, assign) UInt32 lastBeginId;
@property (nonatomic, assign) UInt32 lastSearchBeginId;
@property (nonatomic, assign) UInt32 requestListdataType;
@property (nonatomic, strong) NSMutableDictionary *memberDescDic;
@property (nonatomic, strong) NSMutableArray *searchResultList;
@property (nonatomic, strong) NSMutableArray *adminList;
@property (nonatomic, strong) NSMutableArray *memberList;
@property (nonatomic, strong) NSMutableSet *guildMemberUidSet;
//临时群初始化数据
@property(strong, nonatomic) NSMutableArray *members;
@property(strong, nonatomic) TTTempGroupContact *groupContact;
//圈子@用户初始化数据
@property(strong, nonatomic) NSArray *contactList;

@property (nonatomic, strong) TTRoomHomeEmptyView * emptyView;

@end

@implementation AtMemberListViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    TTContact *myInfo = [GET_SERVICE(ContactService) myInfo];
    self.myInfo = myInfo;
    self.searchDisplayController.searchResultsTableView.rowHeight = self.tableView.rowHeight;
    self.tableView.sectionIndexColor = [UIColor ARGB:0x00ACACAC];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    //    self.showAddContactTips = YES;
    self.selectedAccount = [NSMutableArray array];
    self.selectedNickName = [NSMutableArray array];
    self.isReloading = NO;
    
    if(self.groupTypeForAt == kGroupTypeForAtInterestedGroup){//兴趣群
        [self _loadGenericGroupMemberListFromLocalDB];
        [self _loadGenericGroupMemberListFromNetwork];
    }else if(self.groupTypeForAt == kGroupTypeForAtTempGroup){//临时群
        [self _loadTempGroupMemberList];
    }else if(self.groupTypeForAt == kGroupTypeForAtGuildGroup){//公会群
        self.lastBeginId = 0;
        self.requestListdataType = 0;
        self.isReloading = NO;
        
        self.memberList = [NSMutableArray array];
        self.adminList = [NSMutableArray array];
        self.searchResultList = [NSMutableArray array];
        self.muteMemberList = [NSMutableSet set];
        self.memberDescDic = [NSMutableDictionary dictionary];
        self.guildMemberUidSet = [NSMutableSet set];
        [self _loadGuildGroupMemberList];
    }else if (self.groupTypeForAt == kGroupTypeForAtContact) {
//        [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ContactListCell class]) bundle:nil]
//             forCellReuseIdentifier:@"ContactListCell"];
        [self.tableView registerClass:[UGCUserCell class] forCellReuseIdentifier:@"UGCUserCell"];
        self.searchBar.placeholder = @"搜索玩伴";
        self.searchBar.showsScopeBar = NO;
        self.title = @"选择联系人";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBarItemClicked)];
//        self.searchBar.prompt = @"搜索结果";
//        [self.searchBar sizeToFit];
        [self _loadContactList];
//        self.definesPresentationContext = YES;
//        UISearchBar*searchBar =self.searchController.searchBar;
//        UIImageView*barImageView = [[[searchBar.subviewsfirstObject]subviews]firstObject];
//        barImageView.layer.borderColor= [UIColor grayColor].CGColor;
//         barImageView.layer.borderWidth=1;
//        self.tableView.tableHeaderView = searchBar;
//        self.searchBar.scopeButtonTitles = [NSArray arrayWithObject:[UIButton buttonWithType:UIButtonTypeCustom]];
    }
        
    [self initialEmptyView];
    [self _updateDoneBarButtonItemWithSelectedCount:0];
}

- (void)initialEmptyView {
    self.emptyView = [[TTRoomHomeEmptyView alloc] init];
    self.emptyView.tipIconPadding = 10;
    self.emptyView.iconSize = CGSizeMake(160, 160);
    self.emptyView.topMargin = 120;
    self.emptyView.tipText = @"快去认识TT上可爱的小伙伴呀";
    self.emptyView.hidden = NO;
    self.emptyView.icon = [UIImage imageNamed:@"game_icon_blankpage"];
    
    UIButton * moreButtom = [[UIButton alloc] init];
    [moreButtom setBackgroundColor:[UIColor TTPurpleMain]];
    [moreButtom setTitle:@"查看通讯录好友" forState:UIControlStateNormal];
    moreButtom.layer.cornerRadius = 20;
    [moreButtom setTitleColor:[UIColor TTWhite1] forState:UIControlStateNormal];
    moreButtom.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.emptyView addCustom:moreButtom withSize:CGSizeMake(170, 40) padding:14];
    
    [moreButtom addTarget:self action:@selector(toAddFromContacts) forControlEvents:UIControlEventTouchUpInside];
    
    [self.emptyView layoutIfNeeded];
    self.tableView.backgroundView = self.emptyView;
    if ( self.groupTypeForAt == kGroupTypeForAtContact ){
        self.emptyView.hidden = self.contactList.count != 0;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.groupTypeForAt == kGroupTypeForAtInterestedGroup){//兴趣群
    }else if(self.groupTypeForAt == kGroupTypeForAtTempGroup){//临时群
    }else if(self.groupTypeForAt == kGroupTypeForAtGuildGroup){//公会群
        if ([self isMovingToParentViewController]) {
            @weakify(self);
            [self.tableView setPullToLoadMoreAction:^(UIScrollView * _Nonnull scrollView) {
                @strongify(self);
                
                [self _loadMoreMember];
            }];
        }
    }else if (self.groupTypeForAt == kGroupTypeForAtContact) {

    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.groupTypeForAt == kGroupTypeForAtContact) {
        if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    };
}

//- (void)didMoveToParentViewController:(UIViewController *)parent {
//    if (self.groupTypeForAt == kGroupTypeForAtContact) {
////        if (self.selectedCallback) {
////            self.selectedCallback(nil);
////        }
//    }
//}
#pragma mark - setter
- (void)setGroupAccount:(NSString *)groupAccount
{
    _groupAccount = groupAccount;
    if([ContactHelper isGroupAccount:self.groupAccount]){//兴趣群
        _groupTypeForAt = kGroupTypeForAtInterestedGroup;
        self.groupId = [GET_SERVICE(GroupService) groupInfoForAccount:groupAccount].groupId;
    }else if([ContactHelper isTempGroup:self.groupAccount]){//临时群
        _groupTypeForAt = kGroupTypeForAtTempGroup;
        self.groupId = [ContactHelper tempGroupIdWithGroupAccount:groupAccount];
    }else if([ContactHelper isGenericGuildGroup:self.groupAccount]){//公会群
        _groupTypeForAt = kGroupTypeForAtGuildGroup;
    }
    
    if ([ContactHelper isGuildGroup:self.groupAccount]) {
        _memberListType =  GuildMemberListTypeGuild;
        self.groupId = [GET_SERVICE(GuildService) guildGroupForAccount:groupAccount].groupId;
    }else if ([ContactHelper isGuildGameGroup:self.groupAccount]){
        _memberListType = GuildMemberListTypeGroup;
        self.groupId = [GET_SERVICE(GuildService) guildGroupForAccount:groupAccount].groupId;
    }
    //请求是否有@全体成员的权限和次数，赋值后刷新tableView
    [UIUtil showLoadingWithText:@"加载中"];
    [GET_SERVICE(TTIMService) requestCheckAtEveryone:self.groupId callback:^(BOOL isAllowAtEveryone, UInt32 remainCount, NSError *error) {
        [UIUtil dismissLoading];
        if (error) {
            //            [UIUtil showError:error];
            return ;
        }
        
        if (remainCount) {
            self.remainCount = remainCount;
        }
        if (isAllowAtEveryone) {
            self.isAllowAtEveryone = YES;
        }else
        {
            self.isAllowAtEveryone = NO;
        }
        [self.tableView reloadData];
    }];
}

- (void)chageGroupType:(GroupTypeForAt)groupType {
    self.groupTypeForAt = groupType;
    if (self.groupTypeForAt == kGroupTypeForAtContact) {
        self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == self.searchDisplayController.searchResultsTableView){
        return 1;
    }
    if(self.groupTypeForAt == kGroupTypeForAtInterestedGroup){//兴趣群
        NSInteger number = 0;
        self.groupOwnerList.count > 0 ? number++ : 0;
        self.groupCommonMemberList.count > 0 ? number++ : 0;
        self.isAllowAtEveryone ? number++ : 0;
        return number;
    }else if(self.groupTypeForAt == kGroupTypeForAtTempGroup){//临时群
        return 1;
    }else if(self.groupTypeForAt == kGroupTypeForAtGuildGroup){//公会群
        NSInteger number = 0;
        self.adminList.count > 0 ? number++ : 0;
        self.memberList.count > 0 ? number++ : 0;
        self.isAllowAtEveryone ? number++ : 0;
        return number;
    }else if (self.groupTypeForAt == kGroupTypeForAtContact){//圈子@用户
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(self.groupTypeForAt == kGroupTypeForAtInterestedGroup){//兴趣群
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            return self.searchResultMemberList.count;
        }
        if (self.isAllowAtEveryone) {
            section -= 1;
        }
        if (section == (0-1)) { //@全体成员
            return 1;
        }else if (section == 0) {
            if (self.groupOwnerList.count) {
                return self.groupOwnerList.count;
            }else if(self.groupCommonMemberList.count){
                return self.groupCommonMemberList.count;
            }else{
                return 0;
            }
        } else if (section == 1){
            return self.groupCommonMemberList.count;
        } else {
            return 0;
        }
    }else if(self.groupTypeForAt == kGroupTypeForAtTempGroup){//临时群
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            return self.searchResultMemberList.count;
        }else{
            return self.members.count;
        }
    }else if(self.groupTypeForAt == kGroupTypeForAtGuildGroup){//公会群
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            return self.searchResultList.count;
        }
        if (self.isAllowAtEveryone) {
            section -= 1;
        }
        if (section == (0-1)) { //@全体成员
            return 1;
        }else if (section == 0) {
            return self.adminList.count > 0 ? self.adminList.count : self.memberList.count;
        } else {
            return self.memberList.count;
        }
    }else if(self.groupTypeForAt == kGroupTypeForAtContact) {
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            return self.searchResultMemberList.count;
        }else{
            return self.contactList.count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * const kAtContactCellIdentifier = @"atContactCell";
    NSString * const kAtMemberListViewController_atAllCell = @"AtMemberListViewController_atAllCell";
    
    if(self.groupTypeForAt == kGroupTypeForAtInterestedGroup){//兴趣群
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            ContactCell *tempGroupContactCell = [self.tableView dequeueReusableCellWithIdentifier:kAtContactCellIdentifier];
            TTGroupMemberInfo *groupMemberInfo = self.searchResultMemberList[indexPath.row];
            BOOL selected = [self.selectedAccount containsObject:groupMemberInfo.account];
            [tempGroupContactCell showNickName:groupMemberInfo.userNick contactAccount:groupMemberInfo.account withCheckType:selected ? CONTACT_CHECK_TYPE_CHECKED : CONTACT_CHECK_TYPE_UNCHECK];
            
            if (groupMemberInfo.role == kGroupMemberOwner) {
                tempGroupContactCell.adminImageView.image = [UIImage imageNamed:@"chanel_role_group_owner"];
            } else if (groupMemberInfo.role == kGroupMemberAdmin) {
                tempGroupContactCell.adminImageView.image = [UIImage imageNamed:@"chanel_role_group_admin"];
            }
            return tempGroupContactCell;
        }
        TTGroupMemberInfo *groupMemberInfo = nil;
        NSInteger section = indexPath.section;
        if (self.isAllowAtEveryone) {
            section -= 1;
        }
        if (section == (0 - 1)) { //@全体成员
            AtMemberListViewController_atAllCell *atAllCell = [tableView dequeueReusableCellWithIdentifier:kAtMemberListViewController_atAllCell];
            atAllCell.remainCount = self.remainCount;
            return  atAllCell;
        }else if (section == 0) {
            if (self.groupOwnerList.count) {
                groupMemberInfo = self.groupOwnerList[indexPath.row];
            }else{
                groupMemberInfo = self.groupCommonMemberList[indexPath.row];
            }
        } else if (section == 1){
            groupMemberInfo = self.groupCommonMemberList[indexPath.row];
        }
        ContactCell *tempGroupContactCell = [self.tableView dequeueReusableCellWithIdentifier:kAtContactCellIdentifier];
        if (groupMemberInfo.role == kGroupMemberOwner) {
            tempGroupContactCell.adminImageView.hidden = NO;
            tempGroupContactCell.adminImageView.image = [UIImage imageNamed:@"chanel_role_group_owner"];
        } else if (groupMemberInfo.role == kGroupMemberAdmin) {
            tempGroupContactCell.adminImageView.hidden = NO;
            tempGroupContactCell.adminImageView.image = [UIImage imageNamed:@"chanel_role_group_admin"];
        }else
        {
            tempGroupContactCell.adminImageView.hidden = YES;
        }
        BOOL selected = [self.selectedAccount containsObject:groupMemberInfo.account];
        [tempGroupContactCell showNickName:groupMemberInfo.userNick contactAccount:groupMemberInfo.account withCheckType:selected ? CONTACT_CHECK_TYPE_CHECKED : CONTACT_CHECK_TYPE_UNCHECK];
        return tempGroupContactCell;
    }else if(self.groupTypeForAt == kGroupTypeForAtTempGroup){//临时群
        TTGroupMember *groupMember;
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            groupMember = self.searchResultMemberList[indexPath.row];
        }else{
            groupMember = self.members[indexPath.row];
        }
        ContactCell *tempGroupContactCell = [self.tableView dequeueReusableCellWithIdentifier:kAtContactCellIdentifier];
        BOOL selected = [self.selectedAccount containsObject:groupMember.userAccount];
        [tempGroupContactCell showNickName:groupMember.userNickname contactAccount:groupMember.userAccount withCheckType:selected ? CONTACT_CHECK_TYPE_CHECKED : CONTACT_CHECK_TYPE_UNCHECK];
        return tempGroupContactCell;
        
    }else if(self.groupTypeForAt == kGroupTypeForAtGuildGroup){//公会群
        if (self.isAllowAtEveryone && indexPath.section == 0 && tableView != self.searchDisplayController.searchResultsTableView) {
            AtMemberListViewController_atAllCell *atAllCell = [tableView dequeueReusableCellWithIdentifier:kAtMemberListViewController_atAllCell];
            atAllCell.remainCount = self.remainCount;
            return  atAllCell;
        }
        id<IGenericContact> member = [self _memberForIndexPath:indexPath tableView:tableView];
        
        TTGuildMember *guildMember;
        TTGuildGroupMember *guildGroupMember;
        if (self.memberListType == GuildMemberListTypeGuild) {
            guildMember = (TTGuildMember*)member;
        } else if (self.memberListType == GuildMemberListTypeGroup) {
            guildGroupMember = (TTGuildGroupMember*)member;
            guildMember = guildGroupMember.memberInfo;
        }
        
        ContactCell *tempGroupContactCell = [self.tableView dequeueReusableCellWithIdentifier:kAtContactCellIdentifier];
        
        BOOL selected = [self.selectedAccount containsObject:member.account];
        [tempGroupContactCell showNickName:guildMember.name contactAccount:guildMember.account withCheckType:selected ? CONTACT_CHECK_TYPE_CHECKED : CONTACT_CHECK_TYPE_UNCHECK];
        
        if (guildMember.role == kGuildMemberChairman) {
            tempGroupContactCell.roleLabel.text = @"会长";
            tempGroupContactCell.roleLabel.textColor = [UIColor ARGB:0xFF581B];
            tempGroupContactCell.roleLabel.layer.borderColor = [UIColor ARGB:0xFF581B].CGColor;
            tempGroupContactCell.roleLabel.hidden = NO;
            tempGroupContactCell.adminImageView.hidden = YES;
            tempGroupContactCell.roleLabelWidthConstraint.constant = 32;
        } else if (guildMember.role == kGuildMemberAdmin) {
            tempGroupContactCell.roleLabel.text = guildMember.officialName;
            tempGroupContactCell.roleLabel.textColor = [UIColor ARGB:0xAF6FEF];
            tempGroupContactCell.roleLabel.layer.borderColor = [UIColor ARGB:0xAF6FEF].CGColor;
            tempGroupContactCell.roleLabel.hidden = guildMember.officialName.length > 0 ? NO : YES;
            tempGroupContactCell.adminImageView.hidden = YES;
            
            if (guildMember.officialName.length > 0) {
                tempGroupContactCell.roleLabelWidthConstraint.constant = guildMember.officialName.length*8 + (guildMember.officialName.length-1)*1 + 8;
                tempGroupContactCell.roleLabelWidthConstraint.constant = tempGroupContactCell.roleLabelWidthConstraint.constant > 32 ? tempGroupContactCell.roleLabelWidthConstraint.constant : 32;
            } else {
                tempGroupContactCell.roleLabelWidthConstraint.constant = 1;
            }
        } else if (guildGroupMember && guildGroupMember.role == kGuildGroupMemberOwner) {
            tempGroupContactCell.roleLabel.hidden = YES;
            tempGroupContactCell.adminImageView.image =[UIImage imageNamed:@"chanel_role_group_owner"];
            tempGroupContactCell.adminImageView.hidden = NO;
        } else if (guildGroupMember && guildGroupMember.role == kGuildGroupMemberAdmin) {
            tempGroupContactCell.roleLabel.hidden = YES;
            tempGroupContactCell.adminImageView.image = [UIImage imageNamed:@"chanel_role_group_admin"];
            tempGroupContactCell.adminImageView.hidden = NO;
        }else{
            tempGroupContactCell.roleLabel.hidden = YES;
            tempGroupContactCell.adminImageView.hidden = YES;
        }
        return tempGroupContactCell;
    }else if (self.groupTypeForAt == kGroupTypeForAtContact) {
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            UGCUserCell *tempGroupContactCell = [self.tableView dequeueReusableCellWithIdentifier:@"UGCUserCell"];
            TTContact *groupMemberInfo = self.searchResultMemberList[indexPath.row];
            tempGroupContactCell.contact = groupMemberInfo;
            return tempGroupContactCell;
        }
        TTContact *contact = self.contactList[indexPath.row];
        UGCUserCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UGCUserCell"];
        cell.contact = contact;
        return cell;
    }
    
    return nil;
}

#pragma mark tableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(self.groupTypeForAt == kGroupTypeForAtInterestedGroup){//兴趣群
        TTGroupMemberInfo *groupMemberInfo = nil;
        if (tableView == self.searchDisplayController.searchResultsTableView){
            groupMemberInfo = self.searchResultMemberList[indexPath.row];
            [self.searchDisplayController.searchBar resignFirstResponder];
        }else{
            NSInteger section = indexPath.section;
            if (self.isAllowAtEveryone) {
                section -= 1;
            }
            if (section == (0-1)) { //@全体成员
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [self _atEveryone];
                return;
            }else if (section == 0) {
                if (self.groupOwnerList.count) {
                    
                    groupMemberInfo = self.groupOwnerList[indexPath.row];
                }else{
                    groupMemberInfo = self.groupCommonMemberList[indexPath.row];
                }
                //groupMemberInfo = self.groupOwnerList[indexPath.row];
            }else {
                groupMemberInfo = self.groupCommonMemberList[indexPath.row];
            }
        }
        
        ContactCell *cell = (ContactCell*)[tableView cellForRowAtIndexPath:indexPath];
        if ([self.selectedAccount containsObject:groupMemberInfo.account]) {
            [self.selectedAccount removeObject:groupMemberInfo.account];
            [self.selectedNickName removeObject:groupMemberInfo.userNick];
            [cell changeCheckType:CONTACT_CHECK_TYPE_UNCHECK];
        } else {
            if (self.selectedAccount.count >= 10) {
                [UIUtil showHint:@"最多只能@ 10位小伙伴哦"];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                return;
            }
            [self.selectedAccount addObject:groupMemberInfo.account];
            [self.selectedNickName addObject:groupMemberInfo.userNick];
            [cell changeCheckType:CONTACT_CHECK_TYPE_CHECKED];
        }
    }else if(self.groupTypeForAt == kGroupTypeForAtTempGroup){//临时群
        TTGroupMember *groupMember = nil;
        if (tableView == self.searchDisplayController.searchResultsTableView){
            groupMember = self.searchResultMemberList[indexPath.row];
            [self.searchDisplayController.searchBar resignFirstResponder];
        }else{
            groupMember = self.members[indexPath.row];
        }
        ContactCell *cell = (ContactCell*)[tableView cellForRowAtIndexPath:indexPath];
        if ([self.selectedAccount containsObject:groupMember.userAccount]) {
            [self.selectedAccount removeObject:groupMember.userAccount];
            [self.selectedNickName removeObject:groupMember.userNickname];
            [cell changeCheckType:CONTACT_CHECK_TYPE_UNCHECK];
        } else {
            if (self.selectedAccount.count >= 10) {
                [UIUtil showHint:@"最多只能@ 10位小伙伴哦"];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                return;
            }
            [self.selectedAccount addObject:groupMember.userAccount];
            [self.selectedNickName addObject:groupMember.userNickname];
            [cell changeCheckType:CONTACT_CHECK_TYPE_CHECKED];
        }
        
    }else if(self.groupTypeForAt == kGroupTypeForAtGuildGroup){//公会群
        if (self.isAllowAtEveryone && indexPath.section == 0 && tableView != self.searchDisplayController.searchResultsTableView) {  //@全体成员
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self _atEveryone];
            return;
        }
        id<IGenericContact> member = [self _memberForIndexPath:indexPath tableView:tableView];
        ContactCell *cell = (ContactCell*)[tableView cellForRowAtIndexPath:indexPath];
        if ([self.selectedAccount containsObject:member.account]) {
            [self.selectedAccount removeObject:member.account];
            [self.selectedNickName removeObject:member.displayName];
            [cell changeCheckType:CONTACT_CHECK_TYPE_UNCHECK];
        } else {
            if (self.selectedAccount.count >= 10) {
                [UIUtil showHint:@"最多只能@ 10位小伙伴哦"];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                return;
            }
            [self.selectedAccount addObject:member.account];
            [self.selectedNickName addObject:member.displayName];
            [cell changeCheckType:CONTACT_CHECK_TYPE_CHECKED];
        }
        
    }else if (self.groupTypeForAt == kGroupTypeForAtContact){
        if (tableView == self.searchDisplayController.searchResultsTableView){
            [self.searchBar resignFirstResponder];
            TTContact *contact = self.searchResultMemberList[indexPath.row];
            if (self.selectedCallback) {
                self.selectedCallback(contact);
            }
        }else{
            TTContact *contact = self.contactList[indexPath.row];
            if (self.selectedCallback) {
                self.selectedCallback(contact);
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
    [self _updateDoneBarButtonItemWithSelectedCount:self.selectedAccount.count];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        UIView *viewSection = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 20)];
        viewSection.backgroundColor = [UIColor GlobalBackgroundColor];
        UILabel *textSection = [[UILabel alloc] initWithFrame:CGRectMake(12, 17, tableView.bounds.size.width - 10, 20)];
        textSection.backgroundColor = [UIColor clearColor];
        textSection.textColor = [UIColor TableViewSectionTitleColor];
        textSection.font = [UIFont systemFontOfSize:12];
        if(self.groupTypeForAt == kGroupTypeForAtInterestedGroup){//兴趣群
            if (self.isAllowAtEveryone) {
                section -= 1;
            }
            if (section == 0) {
                
                if (self.groupOwnerList.count) {
                    textSection.text = @"群组管理";
                }else{
                    textSection.text = @"群组成员";
                }
            } else if (section == 1){
                textSection.text = @"群组成员";
            } else {
                return nil;
            }
            [viewSection addSubview:textSection];
            return viewSection;
        }else if(self.groupTypeForAt == kGroupTypeForAtTempGroup){//临时群
            return nil;
        }else if(self.groupTypeForAt == kGroupTypeForAtGuildGroup){//公会群
            
            if (self.isAllowAtEveryone) {
                section -= 1;
            }
            if (section == 0) {
                if (self.adminList.count > 0) {
                    textSection.text = self.memberListType == GuildMemberListTypeGuild ? @"公会管理" : @"管理";
                } else {
                    textSection.text = self.memberListType == GuildMemberListTypeGuild ? @"公会成员" : @"成员";
                }
            } else if (section == 1){
                textSection.text = self.memberListType == GuildMemberListTypeGuild ? @"公会成员" : @"成员";
            } else {
                return nil;
            }
            [viewSection addSubview:textSection];
            return viewSection;
        }else if (self.groupTypeForAt == kGroupTypeForAtContact){
            textSection.text = @"我的玩伴";
            textSection.frame = CGRectMake(16, 8, tableView.bounds.size.width - 10, 17);
            [viewSection addSubview:textSection];
            return viewSection;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.groupTypeForAt == kGroupTypeForAtContact) {
        return 68;
    }
    return 56;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0.001;
    } else {
        if(self.groupTypeForAt == kGroupTypeForAtInterestedGroup){//兴趣群
            if (self.isAllowAtEveryone && section == 0) {
                return 0.001;
            }
            return 40;
        }else if(self.groupTypeForAt == kGroupTypeForAtTempGroup){//临时群
            return 0.001;
        }else if(self.groupTypeForAt == kGroupTypeForAtGuildGroup){//公会群
            if (self.isAllowAtEveryone && section == 0) {
                return 0.001;
            }
            return 40;
        }else if (self.groupTypeForAt == kGroupTypeForAtContact) {
            if (self.contactList.count == 0) {
                return 0;
            }
            return 33;
        }
        return 0.001;
    }
}

#pragma mark - UISearchDisplayDelegate
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTitle:@"完成"];
    if(self.groupTypeForAt == kGroupTypeForAtInterestedGroup){//兴趣群
    }else if(self.groupTypeForAt == kGroupTypeForAtTempGroup){//临时群
    }else if(self.groupTypeForAt == kGroupTypeForAtGuildGroup){//公会群
        self.lastSearchBeginId = 0;
        [self.searchResultList removeAllObjects];
        //        [self.searchBackgroundControl removeAllView];
    }else if (self.groupTypeForAt == kGroupTypeForAtContact) {
       
    }
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    [Log verbose:self.tag message:@"searchDisplayControllerDidEndSearch"];
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTitle:@"取消"];
    [self.tableView reloadData];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if(self.groupTypeForAt == kGroupTypeForAtInterestedGroup){//兴趣群
    }else if(self.groupTypeForAt == kGroupTypeForAtTempGroup){//临时群
    }else if(self.groupTypeForAt == kGroupTypeForAtGuildGroup){//公会群
        self.lastSearchBeginId = 0;
        [self.searchResultList removeAllObjects];
        @weakify(self);
        [self.searchDisplayController.searchResultsTableView setPullToLoadMoreAction:^(UIScrollView * _Nonnull scrollView) {
            @strongify(self);
            
            [self _searchLoadMoreMember];
        }];
        
        [self _searchLoadMoreMember];
    }else if (self.groupTypeForAt == kGroupTypeForAtContact) {
        
    }
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    
    if(self.groupTypeForAt == kGroupTypeForAtInterestedGroup){//兴趣群
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", searchString];
        NSMutableArray *searchResultList = [NSMutableArray array];
        for (NSString *key in self.searchContentMap.allKeys) {
            if ([[self.searchContentMap objectForKey:key] filteredArrayUsingPredicate:predicate].count > 0) {
                id groupMember = [self.groupMemberDictionary objectForKey:key];
                if (groupMember) {
                    [searchResultList addObject:groupMember];
                }
            }
        }
        self.searchResultMemberList = searchResultList;
    }else if(self.groupTypeForAt == kGroupTypeForAtTempGroup){//临时群
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", searchString];
        NSMutableArray *searchResultList = [NSMutableArray array];
        for (NSString *key in self.searchContentMap.allKeys) {
            if ([[self.searchContentMap objectForKey:key] filteredArrayUsingPredicate:predicate].count > 0) {
                id groupMember = [self.groupMemberDictionary objectForKey:key];
                if (groupMember) {
                    [searchResultList addObject:groupMember];
                }
            }
        }
        self.searchResultMemberList = searchResultList;
        
    }else if(self.groupTypeForAt == kGroupTypeForAtGuildGroup){//公会群
        self.lastSearchBeginId = 0;
        [self.searchResultList removeAllObjects];
        //        [self.searchBackgroundControl removeAllView];
    }else if (self.groupTypeForAt == kGroupTypeForAtContact) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", searchString];
        NSMutableArray *searchResultList = [NSMutableArray array];
        for (NSString *key in self.searchContentMap.allKeys) {
            if ([[self.searchContentMap objectForKey:key] filteredArrayUsingPredicate:predicate].count > 0) {
                id groupMember = [self.groupMemberDictionary objectForKey:key];
                if (groupMember) {
                    [searchResultList addObject:groupMember];
                }
            }
        }
        self.searchResultMemberList = searchResultList;
    }
    
    return YES;
    
}
- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView{
//    [self.tableView reloadData];
}

#pragma mark - choose complete
- (IBAction)doneBarButtonClicked:(id)sender {
    [GET_SERVICE(CustomStatisticsService) trackEventWithEventId:tempGroupCreatBtn];
    if(self.selectedAccount.count == 0){
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(AtMemberListDidChooseMember:accounts:nickNames:isFromMemberList:)]) {
        [self.delegate AtMemberListDidChooseMember:NO accounts:self.selectedAccount nickNames:self.selectedNickName isFromMemberList:YES];
    }
    [Log info:@"@:" message:@"account:%@ nick:%@ isAtAll:%zd",self.selectedAccount,self.selectedNickName,NO];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - private
- (void)_updateDoneBarButtonItemWithSelectedCount:(NSInteger)selectedCount{
    if (self.groupTypeForAt == kGroupTypeForAtContact) {
        self.doneBarButtonItem.title = nil;
        return;
    }
    [UIView performWithoutAnimation:^{
        [self.doneBarButtonItem setTitle:[NSString stringWithFormat:@"确认(%ld)", (long)selectedCount]];
        [self.doneBarButtonItem setEnabled:selectedCount>0];
    }];
    
    
    
}
- (void)_atEveryone{
    if (self.remainCount <= 0) {
        [UIUtil showHint:@"您的次数已使用完"];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(AtMemberListDidChooseMember:accounts:nickNames:isFromMemberList:)]) {
        [self.delegate AtMemberListDidChooseMember:YES accounts:nil nickNames:nil isFromMemberList:YES];
    }
    [Log info:@"@:" message:@"ALL"];
    [self.navigationController popViewControllerAnimated:YES];

}
#pragma mark - private tempGroup
- (void)_loadTempGroupMemberList{
    ContactService *contactService = GET_SERVICE(ContactService);
    self.groupContact = [contactService tempGroupForAccount:self.groupAccount];
    // 加载本地数据
    [contactService membersInLocalDBForGroup:self.groupAccount completion:^(NSArray * members, NSError * error) {
        
        if (error){
            [UIUtil showError:error];
            return ;
        }
        
        BOOL needUpdateMember = NO;
        
        self.members = [[NSMutableArray alloc] initWithArray:members];

        if (self.members.count != 0) {//移除自己
            for (int i = 0; i < self.members.count; ++i) {
                TTGroupMember * member = self.members[i];
                if ([member.userAccount isEqualToString:_myInfo.account]) {
                    [self.members removeObject:member];
                }
            }
        }
        if (self.members.count == 0){
            needUpdateMember = YES;
        }
        if (!needUpdateMember){
            self.emptyView.hidden = YES;
            needUpdateMember = self.groupContact.needUpdateMember;
        }
        
        if (needUpdateMember){ // 需要远程更新
            @weakify(self);
            [contactService membersForGroup:self.groupAccount completion:^(NSArray * members, NSError * error) {
                if (error) {
                    [UIUtil showError:error];
                    return ;
                }
                @strongify(self);
                self.members = [[NSMutableArray alloc] initWithArray:members];
                if (self.members.count != 0) {//移除自己
                    for (int i = 0; i < self.members.count; ++i) {
                        TTGroupMember * member = self.members[i];
                        if ([member.userAccount isEqualToString:_myInfo.account]) {
                            [self.members removeObject:member];
                        }
                    }
                }
                [self.tableView reloadData];
                [self _loadTempGroupSearchMap:_members];
                
                self.emptyView.hidden = self.members.count > 0;
            }];
        }
        [self _loadTempGroupSearchMap:_members];
        [self.tableView reloadData];
    }];
}

- (void)_loadTempGroupSearchMap:(NSArray *)memberList{
    NSMutableDictionary *searchContentMap = [NSMutableDictionary dictionary];
    NSMutableDictionary *groupMemberDictionary = [NSMutableDictionary dictionary];
    for (TTGroupMember *memberInfo in memberList) {
        
        [groupMemberDictionary setObject:memberInfo forKey:memberInfo.userAccount];
        
        NSMutableArray *contentList = [[NSMutableArray alloc] init];
        [contentList addObject:memberInfo.userAccount];
        [contentList addObject:memberInfo.userNickname];
        [contentList addObject:memberInfo.userNicknamePinyin];
        [searchContentMap setObject:contentList forKey:memberInfo.userAccount];
    }
    self.groupMemberDictionary = groupMemberDictionary;
    self.searchContentMap = searchContentMap;
}
#pragma mark - private GuildGroup
- (id<IGenericContact>)_memberForIndexPath:(NSIndexPath*)indexPath tableView:(UITableView*)tableView
{
    id<IGenericContact> member;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (indexPath.row < self.searchResultList.count) {
            member = [self.searchResultList objectAtIndex:indexPath.row];
        }
    } else {
        NSInteger section = indexPath.section;
        if (self.isAllowAtEveryone) {
            section -= 1;
        }
        if (section == (0-1)) { //@全体成员
            member = nil;
        }else if (section == 0) {
            member = self.adminList.count > 0 ? [self.adminList objectAtIndex:indexPath.row] : [self.memberList objectAtIndex:indexPath.row];
        } else {
            member = [self.memberList objectAtIndex:(indexPath.row)];
        }
    }
    return member;
}

- (void)_loadGuildGroupMemberList{
    if (self.isReloading) {
        return;
    } else {
        self.isReloading = YES;
    }
    
    GuildService *service = GET_SERVICE(GuildService);
    
    if (self.memberListType == GuildMemberListTypeGuild) {
        self.lastBeginId = 0;
        
        NSMutableArray *adminUidList = [NSMutableArray array];
        for (TTGuildMember *member in [GET_SERVICE(GuildService) allGuildAdmins]) {
            if (member.role == kGuildMemberChairman || member.role == kGuildMemberAdmin) {
                [adminUidList addObject:@(member.uid)];
            }
        }
        
        self.emptyView.hidden = adminUidList.count > 0;
        @weakify(self);
        [GET_SERVICE(GuildService) requestGuildMemberListByRankType:GuildMemberRankListTypeContribution
                                                             offset:0
                                                              count:(UInt32)adminUidList.count
                                                         optUidList:adminUidList
                                                           dataType:0
                                                           callback:^(NSArray *memberRankInfoList, NSError *error)
         {
             @strongify(self);
             if (error) {
                 [UIUtil showError:error];
             } else {
                 self.lastBeginId = 0;
                 self.requestListdataType = 0;
                 [self.adminList removeAllObjects];
                 
                 for (TTGuildMemberRankInfo *rankInfo in memberRankInfoList) {
                     if (rankInfo.memberInfo.uid == _myInfo.uid) {//移除自己
                         continue ;
                     }
                     if (rankInfo.memberInfo.role == kGuildMemberChairman) {
                         [self.adminList insertObject:rankInfo.memberInfo atIndex:0];
                     } else if (rankInfo.memberInfo.role == kGuildMemberAdmin) {
                         [self.adminList addObject:rankInfo.memberInfo];
                     }
                     [self.memberDescDic setObject:rankInfo.desc ? rankInfo.desc : @"" forKey:@(rankInfo.memberInfo.uid)];
                 }
                 [self _loadMoreMember];
                 [self.tableView reloadData];
                 self.isReloading = NO;
             }
         }];
    } else if (self.memberListType == GuildMemberListTypeGroup) {
        self.lastBeginId = 0;
        
        self.group = [service guildGroupForAccount:self.groupAccount];
        [self _addGroupMemberList:[service getGuildGroupMemberListFromCache:self.group]];
        
        [[service allGroupMuteMemberList:self.group.groupId] enumerateObjectsUsingBlock:^(TTGuildGroupMember *member, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.muteMemberList addObject:@(member.memberInfo.uid)];
        }];
        
        [service requestGetAllGroupMuteMemberList:self.group.groupId completion:nil];
        
        [self _loadMoreMember];
        [self.tableView reloadData];
        
        self.isReloading = NO;
    }
}

- (void)_loadMoreMember
{
    UInt32 requestCount = 15;
    GuildService *service = GET_SERVICE(GuildService);
    
//    self.emptyView.hidden = self.adminList.count > 0 || self.muteMemberList.count > 0 || self.members.count > 0;
    if (self.memberListType == GuildMemberListTypeGuild) {
        @weakify(self);
        if (self.requestListdataType == 0) {
            // 类型为0表示请求有 贡献值/消费/签到天数 的成员（即在ranklist中）
            requestCount = self.lastBeginId == 0 ? (UInt32)self.adminList.count + requestCount : requestCount;  // 这边拉取超过admin 数量的数据，保证有普通成员
            
            [GET_SERVICE(GuildService) requestGuildMemberListByRankType:GuildMemberRankListTypeContribution
                                                                 offset:self.lastBeginId
                                                                  count:requestCount
                                                             optUidList:nil
                                                               dataType:0
                                                               callback:^(NSArray *memberRankInfoList, NSError *error)
             {
                 @strongify(self);
                 if (error) {
                     [UIUtil showError:error];
                     [self.tableView finishPullToLoadMore];
                     [self.tableView enablePullToLoadMore];
                 }
                 
                 if (self.lastBeginId == 0) {
                     [self.memberList removeAllObjects];
                     [self.guildMemberUidSet removeAllObjects];
                 }
                 
                 // 这边要去重
                 NSMutableArray *memberList = [NSMutableArray array];
                 for (TTGuildMemberRankInfo *rankInfo in memberRankInfoList) {
                     if (rankInfo.memberInfo.uid == _myInfo.uid) {//移除自己
                         continue ;
                     }
                     if (rankInfo.memberInfo.role == kGuildMemberCommon && [self.guildMemberUidSet member:@(rankInfo.memberInfo.uid)] == nil) {
                         [memberList addObject:rankInfo.memberInfo];
                         [self.guildMemberUidSet addObject:@(rankInfo.memberInfo.uid)];
                         [self.memberDescDic setObject:rankInfo.desc ? rankInfo.desc : @"" forKey:@(rankInfo.memberInfo.uid)];
                     }
                 }
                 
                 [self.memberList addObjectsFromArray:memberList];
                 self.emptyView.hidden = memberList.count > 0;
                 self.lastBeginId += requestCount;
                 
                 // 如果这边请求回来的数量小于请求数量，说明ranklist里面的内容拉完，可以开始请求普通列表
                 if (memberRankInfoList.count < requestCount) {
                     self.lastBeginId = (UInt32)self.adminList.count;   // 这边拉取跳过admin数据，节省时间
                     self.requestListdataType = 1;
                     [self _loadMoreMember];
                 } else {
                     [self.tableView reloadData];
                     
                     //这里需要延迟关闭下拉加载，防止tabview提前移动到底部
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                         [self.tableView finishPullToLoadMore];
                         [self.tableView enablePullToLoadMore];
                     });
                 }
             }];
        } else if (self.requestListdataType == 1) {
            // 类型为1表情请求普通成员列表
            [GET_SERVICE(GuildService) requestGuildMemberListByRankType:GuildMemberRankListTypeContribution
                                                                 offset:self.lastBeginId
                                                                  count:requestCount
                                                             optUidList:nil
                                                               dataType:1
                                                               callback:^(NSArray *memberRankInfoList, NSError *error)
             {
                 @strongify(self);
                 if (error) {
                     [UIUtil showError:error];
                     [self.tableView finishPullToLoadMore];
                     [self.tableView enablePullToLoadMore];
                 }
                 
                 // 这边要去重
                 NSMutableArray *memberList = [NSMutableArray array];
                 for (TTGuildMemberRankInfo *rankInfo in memberRankInfoList) {
                     if (rankInfo.memberInfo.uid == _myInfo.uid) { //移除自己
                         continue;
                     }
                     if (rankInfo.memberInfo.role == kGuildMemberCommon && [self.guildMemberUidSet member:@(rankInfo.memberInfo.uid)] == nil) {
                         [memberList addObject:rankInfo.memberInfo];
                         [self.guildMemberUidSet addObject:@(rankInfo.memberInfo.uid)];
                         [self.memberDescDic setObject:rankInfo.desc ? rankInfo.desc : @"" forKey:@(rankInfo.memberInfo.uid)];
                     }
                 }
                 
                 [self.memberList addObjectsFromArray:memberList];
                 self.emptyView.hidden = memberList.count > 0;
                 
                 self.lastBeginId += requestCount;
                 [self.tableView reloadData];
                 
                 //这里需要延迟关闭下拉加载，防止tabview提前移动到底部
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     [self.tableView finishPullToLoadMore];
                     if (memberRankInfoList.count < requestCount) {
                         [self.tableView disablePullToLoadMore];
                     } else {
                         [self.tableView enablePullToLoadMore];
                     }
                 });
             }];
        }
    } else if (self.memberListType == GuildMemberListTypeGroup) {
        @weakify(self);
        [service requestGuildGroupMemberList:self.group beginId:self.lastBeginId count:requestCount callback:^(NSArray *memberList, NSError *error) {
            @strongify(self);
            
            if (!error) {
                if (self.lastBeginId == 0) {
                    [self.adminList removeAllObjects];
                    [self.memberList removeAllObjects];
                }
                [self _addGroupMemberList:memberList];
                self.emptyView.hidden = memberList.count > 0;
                
                self.lastBeginId += requestCount;
                [self.tableView reloadData];
                
                //这里需要延迟关闭下拉加载，防止tabview提前移动到底部
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.tableView finishPullToLoadMore];
                    if (memberList.count < requestCount) {
                        [self.tableView disablePullToLoadMore];
                    } else {
                        [self.tableView enablePullToLoadMore];
                    }
                });
            } else {
                [UIUtil showError:error];
                [self.tableView finishPullToLoadMore];
                [self.tableView enablePullToLoadMore];
            }
        }];
    }
}

- (void)_searchLoadMoreMember
{
    UInt32 requestCount = 100;
    NSString *keyword = self.searchDisplayController.searchBar.text;
    GuildService *service = GET_SERVICE(GuildService);
    
    @weakify(self);
    void (^callback)(NSArray *memberList, NSError *error) = ^(NSArray *memberList, NSError *error) {
        @strongify(self);
        if (!error) {
            //            [self.searchBackgroundControl removeAllView];
            
            if (self.lastBeginId == 0) {
                [self.searchResultList removeAllObjects];
            }
            
            [self.searchResultList addObjectsFromArray:memberList];
            self.lastSearchBeginId += requestCount;
            if (self.memberListType == GuildMemberListTypeGuild) {//移除自己
                if (self.searchResultList.count != 0) {
                    for (int i = 0; i < self.searchResultList.count; ++i) {
                        TTGuildMember *memberInfo = self.searchResultList[i];
                        if (memberInfo.uid == self.myInfo.uid) {
                            [self.searchResultList removeObject:memberInfo];
                        }
                    }
                }
            } else if (self.memberListType == GuildMemberListTypeGroup) {//移除自己
                if (self.searchResultList.count != 0) {
                    for (int i = 0; i < self.searchResultList.count; ++i) {
                        TTGuildGroupMember *member = self.searchResultList[i];
                        if (member.memberInfo.uid == self.myInfo.uid) {
                            [self.searchResultList removeObject:member];
                        }
                    }
                }
            }
            [self.searchDisplayController.searchResultsTableView reloadData];

            if (self.searchResultList.count == 0) {
                for(UIView *subview in self.searchDisplayController.searchResultsTableView.subviews)
                {
                    if([subview isKindOfClass:[UILabel class]])
                    {
                        UILabel *lbl = (UILabel*)subview;
                        lbl.text = @"该成员搜索不存在或者长时间不在线";
                        lbl.font = [UIFont boldSystemFontOfSize:15];
                        
                        break;
                    }
                }
            }
            
            //这里需要延迟关闭下拉加载，防止tabview提前移动到底部
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.searchDisplayController.searchResultsTableView finishPullToLoadMore];
                [self.searchDisplayController.searchResultsTableView disablePullToLoadMore];
            });
        } else {
            [UIUtil showError:error];
        }
    };
    
    if (self.memberListType == GuildMemberListTypeGuild) {
        [service searchGuildMemberList:self.lastSearchBeginId count:requestCount keyword:keyword callback:callback];
    } else if (self.memberListType == GuildMemberListTypeGroup) {
        [service searchGuildGroupMemberList:self.group beginId:self.lastSearchBeginId count:requestCount keyword:keyword callback:callback];
    }
}
- (void)_addGroupMemberList:(NSArray*)members
{
    // 更新群成员列表需要手动筛选管理员
    BOOL adminListUpdated = NO;
    
    for (TTGuildGroupMember *member in members) {
        if (member.memberInfo.uid == _myInfo.uid) { //移除自己
            continue ;
        }
        if (member.memberInfo.role == kGuildMemberChairman
            || member.memberInfo.role == kGuildMemberAdmin
            || member.role == kGuildGroupMemberOwner
            || member.role == kGuildGroupMemberAdmin)
        {
            [self.adminList addObject:member];
            
            adminListUpdated = YES;
        } else {
            [self.memberList addObject:member];
        }
    }
}

#pragma mark - private UGCAtMember
- (void)_loadContactList{
    self.contactList = [GET_SERVICE(ContactService) allContactsSortedByStatus];
    NSMutableDictionary *searchContentMap = [NSMutableDictionary dictionary];
    NSMutableDictionary *groupMemberDictionary = [NSMutableDictionary dictionary];
    for (TTContact *contact in self.contactList) {
        
        [groupMemberDictionary setObject:contact forKey:contact.account];
        
        NSMutableArray *contentList = [[NSMutableArray alloc] init];
        [contentList addObject:contact.account];
        [contentList addObject:contact.nickName];
        [contentList addObject:contact.nickPinyin];
        [contentList addObject:contact.nickRemark];
        [searchContentMap setObject:contentList forKey:contact.account];
    }
    self.searchContentMap = searchContentMap;
    self.groupMemberDictionary = groupMemberDictionary;
    [self.tableView reloadData];
   if ( self.groupTypeForAt == kGroupTypeForAtContact ){
        self.emptyView.hidden = self.contactList.count != 0;
    }
}

- (void)cancelBarItemClicked {
    [self.navigationController popViewControllerAnimated:YES];
    if (self.selectedCallback) {
        self.selectedCallback(nil);
        self.selectedCallback = nil;
        self.delegate = nil;
    }
}

#pragma mark - private genericGroup
- (void)_loadGenericGroupMemberListFromLocalDB{
    GroupService *groupService = GET_SERVICE(GroupService);
    [groupService membersFromLocalDBForGroup:self.groupAccount completion:^(NSArray *members, NSError *error) {
        if (error) {
            [Log error:NSStringFromClass([self class]) message:@"membersFromLocalDBForGroup error:%@", error];
            return ;
        }
        NSMutableArray * tempMembers = [NSMutableArray arrayWithArray:members];//移除自己
        for (int i = 0; i < tempMembers.count; ++i) {
            TTGroupMemberInfo *memberInfo = tempMembers[i];
            if (memberInfo.uid == _myInfo.uid) {
                [tempMembers removeObject:memberInfo];
            }
        }
        [self formatGroupMemberList:tempMembers];
        [self.tableView reloadData];
        
        self.emptyView.hidden = tempMembers.count > 0;
    }];
}

- (void)_loadGenericGroupMemberListFromNetwork{
    GroupService *groupService = GET_SERVICE(GroupService);
    [UIUtil showLoadingWithText:@"加载中..."];
    [groupService reqGroupMembersList:self.groupAccount completion:^(NSString *groupAccount, NSArray *memberList, NSError *error) {
        [UIUtil dismissLoading];
        if (error) {
            [Log error:NSStringFromClass([self class]) message:@"reqGroupMembersList error:%@", error];
            [UIUtil showError:error];
            return ;
        }
        NSMutableArray * tempMembers = [NSMutableArray arrayWithArray:memberList];//移除自己
        for (int i = 0; i < tempMembers.count; ++i) {
            TTGroupMemberInfo *memberInfo = tempMembers[i];
            if (memberInfo.uid == _myInfo.uid) {
                [tempMembers removeObject:memberInfo];
            }
        }
        [self formatGroupMemberList:tempMembers];
        [self.tableView reloadData];
        
        self.emptyView.hidden = tempMembers.count > 0;
    }];
}
- (void)formatGroupMemberList:(NSArray *)memberList{
    NSMutableArray *groupOwnerList = [[NSMutableArray alloc] init];
    NSMutableArray *groupCommonMemberList = [[NSMutableArray alloc] init];
    NSMutableDictionary *groupMemberDictionary = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *searchContentMap = [[NSMutableDictionary alloc] init];
    for (TTGroupMemberInfo *memberInfo in memberList) {
        if (memberInfo.role == kGroupMemberOwner || memberInfo.role == kGroupMemberAdmin) {
            [groupOwnerList addObject:memberInfo];
        } else {
            [groupCommonMemberList addObject:memberInfo];
        }
        [groupMemberDictionary setObject:memberInfo forKey:memberInfo.account];
        
        NSMutableArray *contentList = [[NSMutableArray alloc] init];
        [contentList addObject:memberInfo.account];
        [contentList addObject:memberInfo.userNick];
        [contentList addObject:memberInfo.nickPinyin];
        [searchContentMap setObject:contentList forKey:memberInfo.account];
    }
    self.groupOwnerList = groupOwnerList;
    self.groupCommonMemberList = groupCommonMemberList;
    self.groupMemberDictionary = groupMemberDictionary;
    self.searchContentMap = searchContentMap;
}

- (void)toAddFromContacts {
    //
    UIStoryboard *contactStoryboard = [UIStoryboard storyboardWithName:CONTACT_STORYBOARD bundle:[NSBundle mainBundle]];
    ContactRecommendAddressViewController *viewController = [contactStoryboard instantiateViewControllerWithIdentifier:@"ContactRecommendAddressViewController"];
    if (![self.navigationController.viewControllers.lastObject isKindOfClass:[ContactRecommendAddressViewController class]]) {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

@end
