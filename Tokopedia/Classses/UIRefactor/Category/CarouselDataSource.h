//
//  CarouselDataSource.h
//  Tokopedia
//
//  Created by Tonito Acen on 1/20/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iCarousel.h"

@class BannerList;
@class Slide;

@interface CarouselDataSource : NSObject <iCarouselDataSource, iCarouselDelegate>

- (instancetype)initWithBanner:(NSArray <Slide*>*)banners;

@property(nonatomic, weak) UIViewController *delegate;

@end
