                                                                              //
//  RateProduct.m
//  Tokopedia
//
//  Created by Renny Runiawati on 2/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RateProduct.h"

@implementation RateProduct

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"shipper_product_id",
                      @"shipper_product_name",
                      @"shipper_product_desc",
                      @"price",
                      @"formatted_price",
                      @"ut",
                      @"check_sum",
                      @"is_show_map",
                      @"max_hours_id",
                      @"max_hours",
                      @"desc_hours_id",
                      @"desc_hours"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}


@end
