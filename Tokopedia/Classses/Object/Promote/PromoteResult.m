//
//  GeneralActionResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "PromoteResult.h"

@implementation PromoteResult

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:@{
        @"p_name_enc" : @"product_name",
        @"is_dink"      : @"is_dink"
    }];
    return mapping;
}

@end
