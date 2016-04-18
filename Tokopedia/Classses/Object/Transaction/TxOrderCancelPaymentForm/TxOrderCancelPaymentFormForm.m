//
//  TxOrderCancelPaymentFormForm.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderCancelPaymentFormForm.h"

@implementation TxOrderCancelPaymentFormForm
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"voucher_used",
                      @"refund",
                      @"vouchers",
                      @"total_refund"
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
