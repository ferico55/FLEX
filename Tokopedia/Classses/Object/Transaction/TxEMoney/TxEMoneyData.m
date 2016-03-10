//
//  TxEMoneyData.m
//  Tokopedia
//
//  Created by IT Tkpd on 3/23/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxEMoneyData.h"

@implementation TxEMoneyData
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"trace_num",
                      @"status",
                      @"no_hp",
                      @"trx_id",
                      @"id_emoney"
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
