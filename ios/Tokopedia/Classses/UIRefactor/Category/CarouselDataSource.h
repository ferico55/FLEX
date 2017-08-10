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

@class BannerList;
@class Slide;
@class HomeSliderView;

@interface CarouselDataSource : NSObject <iCarouselDataSource, iCarouselDelegate>

- (instancetype _Nonnull )initWithBanner:(NSArray <Slide*>*_Nonnull)banners withPageControl: (StyledPageControl*_Nonnull) pageControl;

@property(nullable, nonatomic, weak) UINavigationController *navigationDelegate;
@property(nullable, nonatomic, weak) NSTimer *timer;

@property (nonatomic, copy) void (^_Nullable didSelectBanner)(Slide * _Nonnull slide);
@property (nonatomic) BOOL isCategoryBanner;

@end
