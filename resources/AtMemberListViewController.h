//
//  AtMemberListViewController.h
//  TT
//
//  Created by 吕旭明 on 16/12/8.
//  Copyright © 2016年 yiyou. All rights reserved.
//

#import "BaseTableViewController.h"
@class TTContact;

typedef NS_ENUM(NSInteger, GroupTypeForAt) {
    kGroupTypeForAtTempGroup = 0,   //临时群
    kGroupTypeForAtInterestedGroup, //兴趣群
    kGroupTypeForAtGuildGroup,      //公会群
    kGroupTypeForAtContact,         //圈子@用户
};

typedef void (^AtMemberListViewBlock)(TTContact *contact);

@protocol AtMemberListDelegate <NSObject>
/**
 * 选择完成时调用
 */
- (void)AtMemberListDidChooseMember:(BOOL)isAtAll accounts:(NSArray<NSString *>*)accountList nickNames:(NSArray<NSString *>*) nickNameList isFromMemberList:(BOOL)isFromMemberList;
@end

@interface AtMemberListViewController : BaseTableViewController

@property (nonatomic, copy) AtMemberListViewBlock selectedCallback;

/**
 * 代理
 */
@property (nonatomic, weak) id<AtMemberListDelegate> delegate;

/**
 * 群组信息
 */
@property(nonatomic, strong) NSString *groupAccount;

- (void)chageGroupType:(GroupTypeForAt)groupType;

@end
