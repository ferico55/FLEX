//
//  CarouselDataSource.m
//  Tokopedia
//
//  Created by Tonito Acen on 1/20/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "CarouselDataSource.h"
#import "BannerList.h"

@implementation CarouselDataSource {
    NSArray *_banners;
}

- (instancetype)initWithBanner:(NSArray<BannerList *> *)banners {
    self = [super init];
    if(!self) {
        return nil;
    }
    
    _banners = banners;
    
    return self;
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return _banners.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    if(!view) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        [view setBackgroundColor:[UIColor redColor]];
    }
    
    return view;
}




@end
