//
//  InstallmentTerm.m
//  Tokopedia
//
//  Created by Renny Runiawati on 9/30/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "InstallmentTerm.h"

@implementation InstallmentTerm
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"total_price",
                      @"monthly_price",
                      @"total_price_idr",
                      @"admin_price_idr",
                      @"monthly_price_idr",
                      @"bunga",
                      @"duration",
                      @"is_zero",
                      @"interest_price_idr",
                      @"interest_price",
                      @"admin_price"
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
