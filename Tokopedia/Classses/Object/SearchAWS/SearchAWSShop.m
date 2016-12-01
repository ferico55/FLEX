//
//  SearchAWSShop.m
//  Tokopedia
//
//  Created by Tonito Acen on 1/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "SearchAWSShop.h"
#import "Tokopedia-Swift.h"

@implementation SearchAWSShop

- (SearchShopModelView*)modelView {
    if(!_modelView) {
        SearchShopModelView* modelView = [[SearchShopModelView alloc] init];
        modelView.shopName = self.shop_name;
        modelView.shopImageUrl = self.shop_image;
        modelView.shopLocation = self.shop_location;
        modelView.isGoldShop = (self.shop_gold_status == 1) ? YES : NO;
        modelView.isFavorite = [self.shop_is_fave_shop isEqualToString:@"1"] ? YES : NO;
        modelView.official = self.official;
        
        _modelView = modelView;
    }
    
    return _modelView;
}

@end
