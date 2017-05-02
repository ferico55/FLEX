//
//  TxOrderPaymentEditOrder.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/13/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderPaymentEditOrder.h"

@implementation TxOrderPaymentEditOrder
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"order_invoice_string",
                      @"order_invoice"
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
