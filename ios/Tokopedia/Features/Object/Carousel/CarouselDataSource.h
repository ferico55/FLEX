//
//  CarouselDataSource.h
//  Tokopedia
//
//  Created by Tonito Acen on 1/20/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iCarousel.h"
#import "StyledPageControl.h"
#import "BannerType.h"

@class Slide;

@interface CarouselDataSource : NSObject <iCarouselDataSource, iCarouselDelegate>

- (instancetype _Nonnull )initWithBanner:(NSArray <Slide*>*_Nonnull)banners pageControl: (StyledPageControl*_Nonnull) pageControl type:(BannerType) type slider:(iCarousel *_Nonnull) slider;

- (void)endBannerAutoScroll;
- (void)startBannerAutoScroll;
- (void)resetBannerCounter;

@property(nullable, nonatomic, weak) UINavigationController *navigationDelegate;
@property(nonatomic) CGSize bannerIPadSize;
@property(nonatomic) CGSize bannerIPhoneSize;

@property (nonatomic, copy) void (^_Nullable didSelectBanner)(Slide * _Nonnull slide, NSInteger index);

@end
