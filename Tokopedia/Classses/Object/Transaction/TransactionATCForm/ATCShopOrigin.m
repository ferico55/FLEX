//
//  ATCShopOrigin.m
//  Tokopedia
//
//  Created by Renny Runiawati on 3/16/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ATCShopOrigin.h"

@implementation ATCShopOrigin
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"is_gojek",
                      @"longitude",
                      @"origin_id",
                      @"device",
                      @"origin_postal",
                      @"ut",
                      @"is_ninja",
                      @"from",
                      @"latitude",
                      @"show_oke",
                      @"token",
                      @"avail_shipping_code",
                      @"name"
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
