//
//  WholesalePrice.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "WholesalePrice.h"

@implementation WholesalePrice
+(RKObjectMapping *)mappingForPromo{
    RKObjectMapping* wholesalePromoMapping = [RKObjectMapping mappingForClass:[WholesalePrice class]];
    [wholesalePromoMapping addAttributeMappingsFromDictionary:@{@"quantity_min_format":@"wholesale_min",
                                                                @"quantity_max_format":@"wholesale_max",
                                                                @"price_format":@"wholesale_price"
                                                                }];
    return wholesalePromoMapping;
}

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"wholesale_min",
                      @"wholesale_max",
                      @"wholesale_price",];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

@end
