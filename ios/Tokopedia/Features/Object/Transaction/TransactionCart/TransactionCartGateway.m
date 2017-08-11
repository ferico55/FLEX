//
//  TransactionCartGateway.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionCartGateway.h"

@implementation TransactionCartGateway
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"gateway_image",
                      @"gateway",
                      @"gateway_name",
                      @"toppay_flag",
                      @"gateway_desc"
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
