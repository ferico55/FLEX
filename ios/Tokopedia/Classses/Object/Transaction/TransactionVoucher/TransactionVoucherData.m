//
//  TransactionVoucherData.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionVoucherData.h"

@implementation TransactionVoucherData
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"voucher_amount",
                      @"voucher_id",
                      @"voucher_status",
                      @"voucher_expired_time",
                      @"voucher_minimal_amount",
                      @"voucher_no_other_promotion",
                      @"voucher_promo_desc"
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
