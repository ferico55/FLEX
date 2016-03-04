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

NSInteger const bannerIpadWidth = 450;

@implementation CarouselDataSource {
    NSArray *_banners;
}

- (instancetype)initWithBanner:(NSArray<Slide *> *)banners {
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
    CGFloat bannerWidth;
    if(IS_IPAD) {
        bannerWidth = bannerIpadWidth;
    } else {
        bannerWidth = 375;
    }

    view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bannerWidth, IS_IPAD ? 225 : 175)];
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

    WebViewController *webViewController = [WebViewController new];
    webViewController.strTitle = @"Promo";
    webViewController.strURL = banner.redirect_url;

    if(_delegate != nil) {
        [((UIViewController*)_delegate).navigationController pushViewController:webViewController animated:YES];
    }
}


@end
