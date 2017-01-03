//
//  JasonSliderComponent.m
//  Tokopedia
//
//  Created by Tonito Acen on 1/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "JasonBannerComponent.h"
#import "Slide.h"

@implementation JasonBannerComponent

+ (UIView *)build:(NSDictionary *)json withOptions:(NSDictionary *)options{
    UIView* wrapper = [[UIView alloc] initWithFrame:CGRectZero];
    [wrapper mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(225));
    }];
    
    HomeSliderView *slider;
    
    UINavigationController* nav = [[UINavigationController alloc] init];
    UINib *nib = [UINib nibWithNibName:@"HomeSliderView" bundle:nil];
    slider = [nib instantiateWithOwner:nil options:nil ][0];
    
    NSMutableArray<Slide*>* banners = [NSMutableArray new];
    [json[@"banner"] bk_each:^(id obj) {
        Slide* banner = [Slide new];
        banner.image_url = obj[@"image_url"];
        banner.redirect_url = obj[@"redirect_url"];
        banner.message = obj[@"message"];
        banner.title = obj[@"title"];
        
        [banners addObject:banner];
    }];
    
    [slider generateSliderViewWithBanner:banners withNavigationController:nav];
    [wrapper addSubview:slider];
    
    [slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(wrapper);
    }];

    return wrapper;
}

@end
