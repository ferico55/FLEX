//
//  HistoryProductList.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "HistoryProductList.h"
#import "ProductModelView.h"

@implementation HistoryProductList

- (NSString*)product_name {
    return [_product_name kv_decodeHTMLCharacterEntities];
}

- (NSString*)shop_name {
    return [_shop_name kv_decodeHTMLCharacterEntities];
}

- (BOOL)is_product_wholesale {
    return _product_wholesale == 1? YES : NO;
}

- (BOOL)is_product_preorder {
    return _product_preorder == 1? YES : NO;
}

- (ProductModelView *)viewModel {
    if(_viewModel == nil) {
        ProductModelView *viewModel = [[ProductModelView alloc] init];
        [viewModel setProductName:self.product_name];
        [viewModel setProductPrice:self.product_price];
        [viewModel setProductShop:self.shop_name];
        [viewModel setProductThumbUrl:self.product_image];
        [viewModel setIsGoldShopProduct:[self.shop_gold_status isEqualToString:@"1"]];
        [viewModel setLuckyMerchantImageURL:self.shop_lucky];
        [viewModel setIsProductPreorder:self.is_product_preorder];
        [viewModel setIsWholesale:self.is_product_wholesale];
        [viewModel setShopLocation:self.shop_location];
        
        _viewModel = viewModel;
    }
    
    return _viewModel;
}

+ (NSDictionary *)attributeMappingDictionary{
    NSArray *keys = @[@"product_price",
                      @"product_id",
                      @"shop_gold_status",
                      @"shop_location",
                      @"shop_name",
                      @"product_image",
                      @"product_name",
                      @"shop_lucky",
                      @"product_preorder",
                      @"product_wholesale"];
                      
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    return mapping;
}

@end
