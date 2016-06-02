//
//  ManageProductList.m
//  Tokopedia
//
//  Created by IT Tkpd on 12/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ManageProductList.h"

@implementation ManageProductList

- (NSString *)product_name {
    return [_product_name kv_decodeHTMLCharacterEntities];
}

- (NSString *)product_etalase {
    return [_product_etalase kv_decodeHTMLCharacterEntities];
}

+ (RKObjectMapping *)objectMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromArray:@[@"product_count_review",
                                             @"product_rating_point",
                                             @"product_etalase",
                                             @"product_count_talk",
                                             @"product_shop_id",
                                             @"product_status",
                                             @"product_id",
                                             @"product_count_sold",
                                             @"product_currency_id",
                                             @"product_shop_owner",
                                             @"product_currency",
                                             @"product_image",
                                             @"product_normal_price",
                                             @"product_image_300",
                                             @"product_department",
                                             @"product_url",
                                             @"product_name",
                                             @"product_currency_symbol",
                                             @"product_no_idr_price",
                                             @"product_etalase_id"]];
    return mapping;
}

@end
