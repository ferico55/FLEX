//
//  DetailPriceAlert.m
//  Tokopedia
//
//  Created by Tokopedia on 5/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "DetailPriceAlert.h"

@implementation DetailPriceAlert

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[DetailPriceAlert class]];
    
    [mapping addAttributeMappingsFromArray:@[@"pricealert_total_product",
                                             @"pricealert_shop_domain",
                                             @"pricealert_price_min",
                                             @"pricealert_is_active",
                                             @"pricealert_product_name",
                                             @"pricealert_total_unread",
                                             @"pricealert_shop_location",
                                             @"pricealert_product_status",
                                             @"pricealert_shop_id",
                                             @"pricealert_type",
                                             @"pricealert_price",
                                             @"pricealert_product_image",
                                             @"pricealert_time",
                                             @"pricealert_product_id",
                                             @"pricealert_id",
                                             @"pricealert_item_image",
                                             @"pricealert_item_name",
                                             @"pricealert_product_shop_id",
                                             @"pricealert_catalog_id",
                                             @"pricealert_type_desc",
                                             @"pricealert_item_id",
                                             @"pricealert_product_catalog_id",
                                             @"pricealert_product_department_id",
                                             @"pricealert_catalog_department_id",
                                             @"pricealert_item_uri",
                                             @"pricealert_catalog_name",
                                             @"pricealert_catalog_status"]];
    
    return mapping;
}

@end
