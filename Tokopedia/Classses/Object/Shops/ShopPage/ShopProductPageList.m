//
//  ShopProductPageList.m
//  Tokopedia
//
//  Created by Johanes Effendi on 3/24/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ShopProductPageList.h"
#import "ProductModelView.h"

@implementation ShopProductPageList
+(RKObjectMapping *)mapping{
    RKObjectMapping *shopProductPageListMapping = [RKObjectMapping mappingForClass:[ShopProductPageList class]];
    [shopProductPageListMapping addAttributeMappingsFromArray:@[@"shop_lucky",
                                                                @"shop_gold_status",
                                                                @"shop_id",
                                                                @"product_rating_point",
                                                                @"product_department_id",
                                                                @"product_etalase",
                                                                @"shop_url",
                                                                @"shop_featured_shop",
                                                                @"product_status",
                                                                @"product_id",
                                                                @"product_image_full",
                                                                @"product_currency_id",
                                                                @"product_rating_desc",
                                                                @"product_currency",
                                                                @"product_talk_count",
                                                                @"product_price_no_idr",
                                                                @"product_image",
                                                                @"product_price",
                                                                @"product_sold_count",
                                                                @"product_returnable",
                                                                @"shop_location",
                                                                @"product_preorder",
                                                                @"product_normal_price",
                                                                @"product_image_300",
                                                                @"shop_name",
                                                                @"product_review_count",
                                                                @"shop_is_owner",
                                                                @"product_url",
                                                                @"product_name"]];
    return shopProductPageListMapping;
}
- (ProductModelView *)viewModel {
    if(!_viewModel) {
        ProductModelView *viewModel = [[ProductModelView alloc] init];
        [viewModel setProductName:self.product_name];
        [viewModel setProductPrice:self.product_price];
        [viewModel setProductShop:self.shop_name];
        [viewModel setProductThumbUrl:self.product_image];
        [viewModel setProductReview:self.product_review_count];
        [viewModel setProductTalk:self.product_talk_count];
        [viewModel setIsGoldShopProduct:[self.shop_gold_status isEqualToString:@"1"]?YES:NO];
        [viewModel setLuckyMerchantImageURL:self.shop_lucky];
        [viewModel setIsProductPreorder:self.product_preorder];
        [viewModel setIsWholesale:self.product_wholesale];
        
        _viewModel = viewModel;
    }
    
    return _viewModel;
}

- (NSDictionary *)productFieldObjects {
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"Rp."];
    NSString *productPrice = [[_product_price componentsSeparatedByCharactersInSet:characterSet]
                              componentsJoinedByString: @""];
    NSDictionary *productFieldObjects = @{
                                          @"name"     : _product_name?:@"",
                                          @"id"       : _product_id?:@"",
                                          @"price"    : productPrice,
                                          @"brand"    : _shop_name?:@"",
                                          @"url"      : _product_url?:@""
                                          };
    return productFieldObjects;
}
@end
