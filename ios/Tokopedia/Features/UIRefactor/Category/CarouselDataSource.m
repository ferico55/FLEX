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

@import SwiftOverlays;

const CGSize bannerIPadSize = {.width = 450, .height = 225};
const CGSize bannerIPhoneSize = {.width = 375, .height = 175};

@interface CarouselDataSource ()
    
@property(nullable, nonatomic, weak) StyledPageControl *pageControl;
@end

@implementation CarouselDataSource {
    NSArray *_banners;
}

- (instancetype)initWithBanner:(NSArray <Slide*>*)banners withPageControl: (StyledPageControl*) pageControl{
    self = [super init];
    if(!self) {
        return nil;
    }
    
    _banners = banners;
    _pageControl = pageControl;
    return self;
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return _banners.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    
    CGSize bannerSize = IS_IPAD && (_isCategoryBanner == NO) ? bannerIPadSize : bannerIPhoneSize;
    
    view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bannerSize.width, bannerSize.height)];
    
    Slide *banner = _banners[index];
    [(UIImageView *)view setImageWithURL:[NSURL URLWithString:banner.image_url] placeholderImage:nil];
    
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
    self.didSelectBanner(banner);

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
    [_timer invalidate];
    _timer = nil;
}

@end
