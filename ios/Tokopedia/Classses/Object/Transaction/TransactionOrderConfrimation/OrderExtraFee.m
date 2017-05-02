//
//  OrderExtraFee.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "OrderExtraFee.h"

@implementation OrderExtraFee
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"extra_fee_amount",
                      @"extra_fee_amount_idr",
                      @"extra_fee_type"
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
