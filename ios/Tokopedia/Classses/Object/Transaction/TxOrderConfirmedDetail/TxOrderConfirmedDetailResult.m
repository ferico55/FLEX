//
//  TxOrderConfirmedDetailResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderConfirmedDetailResult.h"

@implementation TxOrderConfirmedDetailResult
+(NSDictionary *)attributeMappingDictionary
{
    return nil;
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"tx_order_detail" toKeyPath:@"tx_order_detail" withMapping:[TxOrderConfirmedDetailOrder mapping]]];
    return mapping;
}

@end
