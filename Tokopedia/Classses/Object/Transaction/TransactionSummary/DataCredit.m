//
//  DataCredit.m
//  Tokopedia
//
//  Created by Renny Runiawati on 7/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "DataCredit.h"

@implementation DataCredit
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"user_email",
                      @"payment_id",
                      @"cc_agent",
                      @"cc_type",
                      @"cc_card_bank_type"
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
