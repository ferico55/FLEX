//
//  ReactBannerManager.m
//  Tokopedia
//
//  Created by Billion Goenawan on 9/27/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "ReactBannerManager.h"
@import React;
#import "iCarousel.h"
#import "Tokopedia-Swift.h"

@interface ReactCarousel: iCarousel

@property(nonatomic, copy) RCTBubblingEventBlock onPageChange;

@end

@implementation ReactCarousel

- (void)didUpdateReactSubviews {
    [self reloadData];
}

@end

@interface ReactBannerManager() <iCarouselDataSource, iCarouselDelegate>
@property(nullable, nonatomic, weak) NSTimer *timer;
@end

@implementation ReactBannerManager

RCT_EXPORT_MODULE()

RCT_EXPORT_VIEW_PROPERTY(onPageChange, RCTBubblingEventBlock)

- (UIView *)view {
    iCarousel *carousel = [ReactCarousel new];
    carousel.dataSource = self;
    carousel.delegate = self;
    carousel.type = iCarouselTypeLinear;
    carousel.decelerationRate = 0.5;
    _timer = [TKPDBannerTimer getTimerWithSlider:carousel];
    return carousel;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    return carousel.reactSubviews[index];
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return carousel.reactSubviews.count;
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

- (void)carouselCurrentItemIndexDidChange:(ReactCarousel *)carousel {
    if (carousel.onPageChange) {
        carousel.onPageChange(@{@"page": @(carousel.currentItemIndex)});
    }
}

- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate {
    [_timer invalidate];
    _timer = nil;
}

@end
