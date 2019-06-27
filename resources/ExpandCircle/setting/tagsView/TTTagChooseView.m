//
//  TTTagChooseView.m
//  TT
//
//  Created by simp on 2017/12/25.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTTagChooseView.h"
#import <TTThirdPartTools/Masonry.h>
#import "TTTagChooseCell.h"

@interface TTTagChooseView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView * collectView;
@property (nonatomic, strong) TTCollectionTextLayout * layout;

@property (nonatomic, strong) NSMutableArray * items;

@property (nonatomic, strong) NSMutableArray * selectedItems;

@property (nonatomic, strong) NSMutableArray * orgSelectItems;

/**根据布局计算出来的高度*/
@property (nonatomic, assign) CGFloat dataHeight;

@end

@implementation TTTagChooseView


- (instancetype)initWithItems:(NSArray<TTTagChooseItem *> *)items {
    if (self = [super init]) {
        self.fontSize = 12;
        self.items = [NSMutableArray arrayWithArray:items];
        [self dealSelectItems];
    }
    return self;
}

- (void)dealSelectItems {
    self.selectedItems = [NSMutableArray array];
    for (TTTagChooseItem *item in self.items) {
        if (item.selected) {
            [self.selectedItems addObject:item];
        }
    }
}

- (void)initialUI {
    [self initialCollectionView];
    self.backgroundColor = [UIColor whiteColor];
}

- (void)initialCollectionView {
    TTCollectionTextLayout *textlayout = [[TTCollectionTextLayout alloc] init];
    
    textlayout.itemHeight = [self getCellHeight];;
    textlayout.itemMargin = [self getItemMargin];
    textlayout.edges = [self getSectionMargin];
    textlayout.fontSize = self.fontSize;
    textlayout.layoutWidth = [self getLayoutWidth];
    textlayout.padding = [self getItemPadding];
    
    self.layout = textlayout;
    
    CGFloat height = [self.layout caculateSizeForItems:self.items].height;
    self.dataHeight = height;
//
    if (self.superview) {
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(height);
        }];
    }
    
    self.collectView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:textlayout];
    [self.collectView registerClass:[TTTagChooseCell class] forCellWithReuseIdentifier:@"text"];
    
    [self addSubview:self.collectView];
    
    [self.collectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
    }];
    self.collectView.delegate = self;
    self.collectView.dataSource = self;
    self.collectView.backgroundColor = [UIColor clearColor];
}

- (void)layoutView {
 
    if (!self.collectView) {
        [self initialCollectionView];
    }
}

- (CGFloat)getCellHeight {
    if ([self.delegate respondsToSelector:@selector(heightForTag)]) {
        return [self.delegate heightForTag];
    }
    return 27;
}

- (UIEdgeInsets)getItemMargin {
    if ([self.delegate respondsToSelector:@selector(marginForTag)]) {
        return [self.delegate marginForTag];
    }
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (UIEdgeInsets)getItemPadding {
    if ([self.delegate respondsToSelector:@selector(paddingForTag)]) {
       return [self.delegate paddingForTag];
    }
    return UIEdgeInsetsMake(5, 5, 5, 5);
}


- (UIEdgeInsets)getSectionMargin {
    if ([self.delegate respondsToSelector:@selector(marginForChooseView)]) {
        return [self.delegate marginForChooseView];
    }
  return  UIEdgeInsetsMake(5, 11, 5, 11);
}

- (CGFloat)getLayoutWidth {
    if ([self.delegate respondsToSelector:@selector(widhtForChooseView)]) {
        return  [self.delegate widhtForChooseView];
    }
    return [UIScreen mainScreen].bounds.size.width;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TTTagChooseCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"text" forIndexPath:indexPath];
    cell.selectStyle = self.tagSelectType;
    cell.fontSize = self.fontSize;
    if ([self.delegate respondsToSelector:@selector(defaultBgColorForChooseView)]) {
        cell.defaultBgColor = [self.delegate defaultBgColorForChooseView];
    }
    
    if ([self.delegate respondsToSelector:@selector(selectedBgColorForChooseView)]) {
        cell.selectBgColor = [self.delegate selectedBgColorForChooseView];
    }
    
    if ([self.delegate respondsToSelector:@selector(selectedTextColorForChooseView)]) {
        cell.selectedTextColor = [self.delegate selectedTextColorForChooseView];
    }
    
    if ([self.delegate respondsToSelector:@selector(defaultTextColorForChooseView)]) {
        cell.defaultTextColor = [self.delegate defaultTextColorForChooseView];
    }
    
    TTTagChooseItem *item = [self.items objectAtIndex:indexPath.row];
    cell.chooseItem = item;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TTTagChooseItem *item = [self.items objectAtIndex:indexPath.row];
    if (self.selectedItems.count >= self.maxSelectNumber && !item.selected) {
        BOOL shouldReplace = NO;
        if ([self.delegate respondsToSelector:@selector(canBeSelectAfterMaxWithTag:)]) {
            shouldReplace = [self.delegate canBeSelectAfterMaxWithTag:item];
        }
        
        if (shouldReplace) {
            if (self.selectedItems.count >0) {
                TTTagChooseItem *tempitem = [self.selectedItems objectAtIndex:0];
                tempitem.selected = NO;
                if ([self.delegate respondsToSelector:@selector(tagItemDeChoosed:)]) {
                    [self.delegate tagItemDeChoosed:tempitem];
                }
                [self.selectedItems removeObjectAtIndex:0];
            }
        }else {
            if ([self.delegate respondsToSelector:@selector(maxTagSelectNumberReached)]) {
                [self.delegate maxTagSelectNumberReached];
            }
            return;
        }
    }
    item.selected = !item.selected;
    if (item.selected) {
        if ([self.delegate respondsToSelector:@selector(tagItemChoosed:)]) {
            [self.delegate tagItemChoosed:item];
        }
        [self.selectedItems addObject:item];
    }else {
        if ([self.delegate respondsToSelector:@selector(tagItemDeChoosed:)]) {
            [self.delegate tagItemDeChoosed:item];
        }
        [self.selectedItems removeObject:item];
    }
}

#pragma mark - 重置

- (void)resetItems:(NSArray<TTTagChooseItem *> *)items {  
    self.dataHeight = [self.layout caculateSizeForItems:items].height;
    self.items = [NSMutableArray arrayWithArray:items];
     [self dealSelectItems];
    [self.collectView reloadData];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
