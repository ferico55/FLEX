//
//  PromoResult.m
//  Tokopedia
//
//  Created by Tokopedia on 7/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "PromoResult.h"

@implementation PromoResult
+(RKObjectMapping *)mapping{
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[PromoResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"id":@"result_id"}];
    [resultMapping addAttributeMappingsFromArray:@[@"ad_ref_key",
                                                   @"redirect",
                                                   @"sticker_id",
                                                   @"sticker_image",
                                                   @"product_click_url",
                                                   @"shop_click_url",
                                                   @"applinks"
                                                   ]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"product"
                                                                                  toKeyPath:@"product"
                                                                                withMapping:[PromoProduct mapping]]];
     
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shop"
                                                                                  toKeyPath:@"shop"
                                                                                withMapping:[PromoShop mapping]]];
     
    return resultMapping;
}

-(ProductModelView *)viewModel{
    if(_viewModel == nil) {
        ProductModelView *viewModel = [[ProductModelView alloc] init];
        [viewModel setProductName:_product.name];
        [viewModel setProductPrice:_product.price_format];
        
        [viewModel setProductShop:_shop.name];
        [viewModel setProductThumbUrl:_product.image.s_url];
        [viewModel setProductThumbEcs:_product.image.s_ecs];
        [viewModel setProductReview:_product.count_review_format];
        [viewModel setProductTalk:_product.count_talk_format];
        [viewModel setIsGoldShopProduct:_shop.gold_shop];
        [viewModel setLuckyMerchantImageURL:_shop.lucky_shop];
        [viewModel setShopLocation:_shop.location];
        [viewModel setBadges:_shop.badges];
        [viewModel setLabels:_product.labels];
        _viewModel = viewModel;
    }
    
    return _viewModel;
}

- (NSDictionary *)productFieldObjects {
    return [_product productFieldObjects];
}

@end
