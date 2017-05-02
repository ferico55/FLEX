//
//  IndomaretData.m
//  Tokopedia
//
//  Created by Renny Runiawati on 7/30/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "IndomaretData.h"

@implementation IndomaretData
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"charge_idr",
                      @"total_charge_real_idr",
                      @"total",
                      @"charge_real",
                      @"charge",
                      @"payment_code",
                      @"charge_real_idr",
                      @"total_idr"
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
