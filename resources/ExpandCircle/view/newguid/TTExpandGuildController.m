//
//  TTExpandGuildController.m
//  TT
//
//  Created by simp on 2017/11/7.
//  Copyright © 2017年 yiyou. All rights reserved.
//

#import "TTExpandGuildController.h"
#import <TTThirdPartTools/Masonry.h>
#import "TTExpandUserGuidView.h"
#import "LOTAnimationView+TT.h"
#import <TTFoundation/TTFoundation.h>
#import <TTService/ExpandCircleService.h>

@interface TTExpandGuildController ()<TTExpandUserGuidProtocl,UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView * guildView;

@property (nonatomic, strong) UIPageControl * pageControl;

@end

@implementation TTExpandGuildController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialUI];
    // Do any additional setup after loading the view.
}

- (void)initialUI {
    [self initialGuildView];
    [self initialPages];
    [self initialPageControl];

    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
}

- (void)initialGuildView {
    self.guildView = [[UIScrollView alloc] init];
    [self.view addSubview:self.guildView];
    
    [self.guildView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    self.guildView.delegate = self;
    self.guildView.pagingEnabled = YES;
    self.guildView.scrollIndicatorInsets = UIEdgeInsetsZero;
    self.guildView.showsVerticalScrollIndicator = NO;
    self.guildView.showsHorizontalScrollIndicator = NO;
}

- (void)initialPageControl {
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.numberOfPages = 2;
    self.pageControl.currentPage = 0;
    
    [self.view addSubview:self.pageControl];
    
    CGFloat bottomOffset = -148.0 / 667.0 * self.view.bounds.size.height;
    
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(bottomOffset);
        make.width.mas_equalTo(28);
        make.height.mas_equalTo(8);
        
    }];
}

- (void)initialPages {

    NSInteger pagesCount = 2;
    UIView *lastView = nil;
    int all = 0;
    
    for (int i = 0 ; i < pagesCount; i ++) {
        
        TTExpandUserGuidView *view = [[TTExpandUserGuidView alloc]initWithIndex:i];
        view.delegate = self;
        [self.guildView addSubview:view];
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastView) {
                make.left.equalTo(lastView.mas_right);
            }else {
                make.left.equalTo(self.guildView.mas_left);
            }
            make.top.equalTo(self.guildView.mas_top);
            make.width.equalTo(self.guildView.mas_width);
            make.height.equalTo(self.guildView.mas_height);
        }];
        
        lastView =view;
        all = i;
    }
    self.guildView.contentSize = CGSizeMake(self.view.frame.size.width * (all + 1), self.view.frame.size.height);
    TTExpandUserGuidView *view = self.guildView.subviews[0];
    [view playAnimation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)pageButtonClickedAtIndex:(NSInteger)index {
    self.pageControl.currentPage = index + 1;
     CGFloat width = self.guildView.frame.size.width;
    [self.guildView setContentOffset:CGPointMake(width *(index + 1), 0) animated:YES];
    NSLog(@"the contentsize is %@",NSStringFromCGSize(self.guildView.contentSize));
    __weak typeof(self)wself = self;
    if (index == 1) {
        [UIView animateWithDuration:0.3 animations:^{
            wself.guildView.alpha = 0;
        } completion:^(BOOL finished) {
          
            [self dismissViewControllerAnimated:YES completion:nil];
            ExpandCircleService *service = GET_SERVICE(ExpandCircleService);
            [service setEverUsedExpand];
            if ([self.delegate respondsToSelector:@selector(guildComplete)]) {
                [self.delegate guildComplete];
            }
        }];
    }
}

#pragma mark - scrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    CGFloat width = scrollView.frame.size.width;
    NSInteger page = offset.x/width;
    CGFloat resst = offset.x - width*page;
    if (resst > width/2) {
        page ++;
    }
    self.pageControl.currentPage = page;
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    TTExpandUserGuidView *view = self.guildView.subviews[self.pageControl.currentPage];
    [view playAnimation];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    TTExpandUserGuidView *view = self.guildView.subviews[self.pageControl.currentPage];
    [view playAnimation];
}

- (void)viewDidLayoutSubviews {
  
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
   [self scrollViewDidEndDecelerating:self.guildView];
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
