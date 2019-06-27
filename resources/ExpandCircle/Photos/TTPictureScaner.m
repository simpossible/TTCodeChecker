//
//  TTPictureScaner.m
//  TT
//
//  Created by simp on 2017/12/18.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTPictureScaner.h"
#import <TTThirdPartTools/Masonry.h>

@interface TTPictureScaner ()

@property (nonatomic, strong) UICollectionView * collection;

@end

@implementation TTPictureScaner

- (instancetype)initWithImages:(NSArray<UIImage *> *)images currentSelect:(NSInteger)currentIndex {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)initialUI {
    [self initialCollect];
}

- (void)initialCollect {
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flow];
    [self.view addSubview:self.collection];
    
    [self.collection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
