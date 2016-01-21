//
//  CarouselDataSource.m
//  Tokopedia
//
//  Created by Tonito Acen on 1/20/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "CarouselDataSource.h"
#import "BannerList.h"
#import "WebViewController.h"

NSInteger const bannerHeight = 175;
NSInteger const bannerIpadWidth = 350;

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
    CGFloat bannerWidth;
    if(IS_IPAD) {
        bannerWidth = bannerIpadWidth;
    } else {
        bannerWidth = [UIScreen mainScreen].bounds.size.width;
    }

    view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bannerWidth, bannerHeight)];
    BannerList *banner = _banners[index];
    [(UIImageView *)view setImageWithURL:[NSURL URLWithString:banner.img_uri] placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"]];
    
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
    BannerList *banner = _banners[index];

    WebViewController *webViewController = [WebViewController new];
    webViewController.strTitle = @"Promo";
    webViewController.strURL = banner.url;

    if(_delegate != nil) {
        [((UIViewController*)_delegate).navigationController pushViewController:webViewController animated:YES];
    }
}


@end
