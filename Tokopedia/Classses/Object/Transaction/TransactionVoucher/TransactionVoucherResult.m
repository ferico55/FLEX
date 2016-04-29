//
//  TransactionVoucherResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionVoucherResult.h"

@implementation TransactionVoucherResult
+(NSDictionary *)attributeMappingDictionary
{
    return nil;
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data_voucher" toKeyPath:@"data_voucher" withMapping:[TransactionVoucherData mapping]]];
    
    return mapping;
}

@end
