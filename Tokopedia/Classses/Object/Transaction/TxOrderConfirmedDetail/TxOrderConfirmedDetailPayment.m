//
//  TxOrderConfirmedDetailPayment.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderConfirmedDetailPayment.h"

@implementation TxOrderConfirmedDetailPayment
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"payment_id",
                      @"payment_ref",
                      @"payment_date"
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
