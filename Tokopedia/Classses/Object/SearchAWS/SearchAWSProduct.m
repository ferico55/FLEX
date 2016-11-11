//
//  SearchAWSProduct.m
//  Tokopedia
//
//  Created by Tonito Acen on 8/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "SearchAWSProduct.h"
#import "ProductModelView.h"
#import "CatalogModelView.h"

@implementation SearchAWSProduct

- (NSString*)shop_name {
    return [_shop_name kv_decodeHTMLCharacterEntities];
}

- (NSString*)product_name {
    return [_product_name kv_decodeHTMLCharacterEntities];
}

- (BOOL)is_product_wholesale {
    return _product_wholesale == 1? YES : NO;
}

- (BOOL)is_product_preorder {
    return _product_preorder == 1? YES : NO;
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
        [viewModel setShopLocation:self.shop_location];
        [viewModel setIsProductPreorder:self.is_product_preorder];
        [viewModel setIsWholesale:self.is_product_wholesale];
        [viewModel setBadges:self.badges];
        [viewModel setLabels:self.labels];
        _viewModel = viewModel;
    }
    
    return _viewModel;
}

- (CatalogModelView *)catalogViewModel {
    if(_catalogViewModel == nil) {
        CatalogModelView *viewModel = [[CatalogModelView alloc] init];
        [viewModel setCatalogName:self.catalog_name];
        [viewModel setCatalogPrice:self.catalog_price];
        [viewModel setCatalogSeller:self.catalog_count_product];
        [viewModel setCatalogThumbUrl:self.catalog_image_300];
        _catalogViewModel = viewModel;
    }
    
    return _catalogViewModel;
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

+ (RKObjectMapping *)mapping {
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:self];
    //product
    [listMapping addAttributeMappingsFromArray:@[@"product_image", @"product_image_full", @"product_price", @"product_name", @"product_shop", @"product_id", @"product_review_count", @"product_talk_count", @"shop_gold_status", @"shop_name", @"is_owner",@"shop_location", @"shop_lucky", @"product_preorder", @"product_wholesale" ]];
    //catalog
    [listMapping addAttributeMappingsFromArray:@[@"catalog_id", @"catalog_name", @"catalog_price", @"catalog_uri", @"catalog_image", @"catalog_image_300", @"catalog_description", @"catalog_count_product"]];
    
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"badges" toKeyPath:@"badges" withMapping:[ProductBadge mapping]]];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"labels" toKeyPath:@"labels" withMapping:[ProductLabel mapping]]];
    
    
    return listMapping;

}

@end
