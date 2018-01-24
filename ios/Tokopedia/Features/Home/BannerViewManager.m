//
//  BannerViewManager.m
//  Tokopedia
//
//  Created by Ferico Samuel on 04/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "BannerViewManager.h"
#import <UIKit/UIKit.h>
#import "Tokopedia-Swift.h"
@import NativeNavigation;

@implementation BannerViewManager {
    HomeSliderView *_homeSliderView;
}

RCT_EXPORT_MODULE(HomeSliderView)
RCT_CUSTOM_VIEW_PROPERTY(slides, NSArray<NSDictionary*>*, HomeSliderView) {
    NSMutableArray<Slide*>* slides = [NSMutableArray new];
    for (NSDictionary* banner in json) {
        Slide *slide = [Slide new];
        slide.slideId = [banner objectForKey:@"id"];
        slide.bannerTitle = [banner objectForKey:@"title"];
        slide.image_url = [banner objectForKey:@"image_url"];
        slide.message = [banner objectForKey:@"message"];
        slide.redirect_url = [banner objectForKey:@"redirect_url"];
        slide.applinks = [banner objectForKey:@"applink"];
        
        [slides addObject:slide];
    }
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topMostViewController = [rootViewController topMostViewController];
    [_homeSliderView generateSliderViewWithBanner:slides withNavigationController:(UINavigationController * _Nonnull)topMostViewController.navigationController];
    [_homeSliderView startBannerAutoScroll];
}

RCT_CUSTOM_VIEW_PROPERTY(autoScroll, BOOL, HomeSliderView) {
    if (json) {
        [_homeSliderView startBannerAutoScroll];
    } else {
        [_homeSliderView endBannerAutoScroll];
    }
}

- (UIView *)view {
    UIView *sliderContainer = [[UIView alloc] init];
    [sliderContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @(175): @(125));
    }];
    
    _homeSliderView = [[NSBundle mainBundle] loadNibNamed:@"HomeSliderView" owner:nil options:nil][0];
    return _homeSliderView;
}

@end
