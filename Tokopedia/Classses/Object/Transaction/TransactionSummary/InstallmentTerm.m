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
                      @"duration",
                      @"monthly_price",
                      @"monthly_price_idr"
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
