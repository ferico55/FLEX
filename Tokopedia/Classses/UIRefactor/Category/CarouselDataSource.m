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

NSInteger const bannerIpadWidth = 450;

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

- (void)navigateToIntermediaryPage {
    UIViewController *viewController = [UIViewController new];
    viewController.view.frame = _navigationDelegate.viewControllers.lastObject.view.frame;
    viewController.view.backgroundColor = [UIColor whiteColor];
    viewController.hidesBottomBarWhenPushed = YES;
    
    [_navigationDelegate pushViewController:viewController animated:YES];
}

- (NSString *)shopDomainForUrl:(NSString *)urlString {
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    if (auth.isLogin) {
        NSString *realUrlString = url.parameters[@"url"];
        url = [NSURL URLWithString:realUrlString.stringByRemovingPercentEncoding];
    }
    
    NSString *path = [[url.pathComponents
                       bk_reject:^BOOL(NSString *path) {
                           return [path isEqualToString:@"/"];
                       }]
                      componentsJoinedByString:@"/"];
    return path;
}

#pragma mark - delegate
- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    Slide *banner = _banners[index];
    
    // will use TPRoute when new banner api is up
    [self navigateToIntermediaryPage];
    
    NSString *path = [self shopDomainForUrl:banner.redirect_url];
    
    [TPRoutes isShopExists:path shopExists:^(BOOL exists) {
        [_navigationDelegate popViewControllerAnimated:NO];
        
        if (exists) {
            ShopViewController *shopViewController = [ShopViewController new];
            shopViewController.data = @{
                                        @"shop_domain": path
                                        };
            
            [_navigationDelegate pushViewController:shopViewController animated:NO];
            
        } else {
            WebViewController *webViewController = [WebViewController new];
            webViewController.strTitle = @"Promo";
            webViewController.strURL = banner.redirect_url;
            
            if(_navigationDelegate != nil) {
                [_navigationDelegate pushViewController:webViewController animated:NO];
            }
        }
    }];
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
