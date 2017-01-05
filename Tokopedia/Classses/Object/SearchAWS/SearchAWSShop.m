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

+ (RKObjectMapping *)mapping {
    
    RKObjectMapping *shopMapping = [RKObjectMapping mappingForClass:[SearchAWSShop class]];
    [shopMapping addAttributeMappingsFromArray:@[@"shop_id",
                                                 @"shop_name",
                                                 @"shop_domain",
                                                 @"shop_url",
                                                 @"shop_is_img",
                                                 @"shop_image",
                                                 @"shop_image_300",
                                                 @"shop_description",
                                                 @"shop_tag_line",
                                                 @"shop_location",
                                                 @"shop_total_transaction",
                                                 @"shop_total_favorite",
                                                 @"shop_gold_shop",
                                                 @"shop_is_owner",
                                                 @"shop_rate_speed",
                                                 @"shop_rate_accuracy",
                                                 @"shop_rate_service",
                                                 @"shop_status",
                                                 @"shop_lucky",
                                                 @"reputation_image_uri",
                                                 @"reputation_score"
                                                 ]];
    
    return shopMapping;
}



@end
