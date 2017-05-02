//
//  TxOrderCancelPaymentResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderCancelPaymentResult.h"


@implementation TxOrderCancelPaymentResult

+(NSDictionary *)attributeMappingDictionary
{
    return nil;
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"form" toKeyPath:@"form" withMapping:[TxOrderCancelPaymentFormForm mapping]]];

    return mapping;
}


@end
