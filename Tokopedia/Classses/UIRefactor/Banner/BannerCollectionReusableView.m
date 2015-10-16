//
//  BannerCollectionReusableView.m
//  Tokopedia
//
//  Created by Tonito Acen on 10/13/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "BannerCollectionReusableView.h"


@implementation BannerCollectionReusableView


- (void)awakeFromNib {
    // Initialization code
    numberOfBanners = 3;
    
    CGFloat positionX = 0;
    for(int i=1;i<=numberOfBanners;i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"banner_%d.jpg", i]]];
        
        CGRect frame = imageView.frame;
        frame.size.width = [UIScreen mainScreen].bounds.size.width;
        frame.size.height = _scrollView.frame.size.height;
        frame.origin.y = 0;
        frame.origin.x = positionX;
        [imageView setFrame:frame];
        
        positionX += imageView.frame.size.width;
        [_scrollView addSubview:imageView];
    }
    
    CGSize scrollSize = CGSizeMake(positionX, _scrollView.frame.size.height);
    
    [_scrollView setDelegate:self];
    [_scrollView setContentSize:scrollSize];
    [_scrollView setPagingEnabled:YES];
    [_scrollView setBounces:NO];
    [_scrollView setCanCancelContentTouches:NO];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setClipsToBounds:YES];

    [_pageControl setNumberOfPages:numberOfBanners];
    [_pageControl setCurrentPage:0];
    
    
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(scrollTimerBased) userInfo:nil repeats:YES];
}


#pragma mark - Delegate ScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = _scrollView.bounds.size.width;
    _pageControl.currentPage = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

- (IBAction)changePage:(id)sender {
    UIPageControl *pager = sender;
    NSInteger page = pager.currentPage;
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _scrollView.contentOffset = CGPointMake(page * _scrollView.frame.size.width, 0);
    } completion:nil];
}

- (void)scrollTimerBased {
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        if(_scrollView.contentOffset.x < _scrollView.frame.size.width * (numberOfBanners - 1)) {
            CGFloat nextPositionX = _scrollView.contentOffset.x;
            nextPositionX += _scrollView.frame.size.width;
            _scrollView.contentOffset = CGPointMake(nextPositionX, 0);
        } else {
            _scrollView.contentOffset = CGPointMake(0, 0);
        }
    } completion:nil];
    
}

@end
