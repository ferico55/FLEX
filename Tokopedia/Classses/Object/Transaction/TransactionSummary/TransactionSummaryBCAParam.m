//
//  TransactionSummaryBCAParam.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionSummaryBCAParam.h"

@implementation TransactionSummaryBCAParam
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"bca_descp",
                      @"bca_code",
                      @"bca_amt",
                      @"bca_url",
                      @"currency",
                      @"miscFee",
                      @"bca_date",
                      @"signature",
                      @"callback",
                      @"payment_id",
                      @"payType"
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
