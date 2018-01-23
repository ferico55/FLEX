                                                                              //
//  RateProduct.m
//  Tokopedia
//
//  Created by Renny Runiawati on 2/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RateProduct.h"

@implementation RateProduct

-(NSString *)insurance_price{
    return _insurancePrice ?: @"0";
}

-(NSString *)insuranceType {
    return _insuranceType ?: @"0";
}

-(NSString *)insuranceUsedType {
    return _insuranceUsedType ?: @"1";
}

-(NSString *)insuranceUsedDefault {
    NSString *productPrice = [_price integerValue]>=1000000 ? @"2" : @"1";
    return _insuranceUsedDefault ?: productPrice;
}

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
    [mapping addAttributeMappingsFromDictionary:@{@"insurance_price": @"insurancePrice",
                                                  @"insurance_type_info": @"insuranceTypeInfo",
                                                  @"insurance_type": @"insuranceType",
                                                  @"insurance_used_type": @"insuranceUsedType",
                                                  @"insurance_used_default": @"insuranceUsedDefault",
                                                  @"insurance_used_info": @"insuranceUsedInfo"}];
    return mapping;
}


@end
