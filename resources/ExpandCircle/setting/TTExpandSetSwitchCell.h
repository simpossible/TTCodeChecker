//
//  TTExpandSetSwitchCell.h
//  TT
//
//  Created by simp on 2017/12/25.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandSetCell.h"

@protocol TTExpandSetSwitchCellProtocol <NSObject>

- (void)switcherStateChanged:(BOOL)select;

@end

@interface TTExpandSetSwitchCell : TTExpandSetCell

@property (nonatomic, weak) id<TTExpandSetSwitchCellProtocol> delegate;

- (void)setSwitched:(BOOL)switched;

@end
