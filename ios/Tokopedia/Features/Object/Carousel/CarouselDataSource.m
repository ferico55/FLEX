//
//  CarouselDataSource.m
//  Tokopedia
//
//  Created by Tonito Acen on 1/20/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "CarouselDataSource.h"
#import "Slide.h"
#import "WebViewController.h"
#import "Tokopedia-Swift.h"
#import "iCarousel.h"

@import SwiftOverlays;

@interface CarouselDataSource ()

@property(nullable, nonatomic, weak) StyledPageControl *pageControl;
@property(nonatomic) BannerType bannerType;
@property(nonatomic, strong) NSMutableArray<NSNumber *> *usedBannerIndex;
@property(nullable, nonatomic, weak) NSTimer *timer;
@property(nonatomic, weak) iCarousel * slider;
@end

@implementation CarouselDataSource {
    NSArray<Slide *> *_banners;
}

- (instancetype)initWithBanner:(NSArray <Slide*>*_Nonnull)banners pageControl: (StyledPageControl*_Nonnull) pageControl type:(BannerType) type slider:(iCarousel * _Nonnull) slider {
    self = [super init];
    if(!self) {
        return nil;
    }
    
    _bannerIPadSize = CGSizeMake(450, 225);
    _bannerIPhoneSize = CGSizeMake(375, 125);
    _banners = banners;
    _pageControl = pageControl;
    _bannerType = type;
    _usedBannerIndex = [NSMutableArray new];
    _slider = slider;
    return self;
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return _banners.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    
    CGSize bannerSize = IS_IPAD && (_bannerType == BannerTypeHome) ? self.bannerIPadSize : self.bannerIPhoneSize;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bannerSize.width, bannerSize.height)];
    
    view = imageView;
    
    Slide *banner = _banners[index];
    [imageView setImageWithURL:[NSURL URLWithString:banner.image_url] placeholderImage:nil];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    return view;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    switch (option) {
        case iCarouselOptionWrap :
            return YES;
            break;
        case iCarouselOptionSpacing:
            return value * 1.02f;
            break;
        default:
            return value;
            break;
    }
}

#pragma mark - delegate
- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    Slide *banner = _banners[index];
    self.didSelectBanner(banner, index);
    
    NSURL *url = [NSURL URLWithString:banner.applinks];
    if (url) {
        [TPRoutes routeURL:url];
    }
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    if (_pageControl != nil){
        _pageControl.currentPage = carousel.currentItemIndex;
    }
}

- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate {
    [self endBannerAutoScroll];
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    if (carousel.indexesForVisibleItems.count > 0) {
        NSNumber *currentItemIndex = [NSNumber numberWithInteger:carousel.currentItemIndex];
        if(_bannerType == BannerTypeHome  && ![_usedBannerIndex containsObject:currentItemIndex]) {
            [AnalyticsManager trackHomeBanner:[_banners objectAtIndex:carousel.currentItemIndex] index:carousel.currentItemIndex type: HomeBannerPromotionTrackerTypeView];
            [_usedBannerIndex addObject:currentItemIndex];
        }
    }
}

#pragma mark - Banner control for tracking purpose

- (void)endBannerAutoScroll {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)startBannerAutoScroll {
    [self endBannerAutoScroll];
    _timer = [TKPDBannerTimer getTimerWithSlider:_slider];
}

- (void)resetBannerCounter {
    if (_usedBannerIndex) {
        [_usedBannerIndex removeAllObjects];
    }
}

@end

