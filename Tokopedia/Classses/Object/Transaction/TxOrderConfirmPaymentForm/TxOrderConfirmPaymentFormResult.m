//
//  TxOrderConfirmPaymentFormResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderConfirmPaymentFormResult.h"

@implementation TxOrderConfirmPaymentFormResult
+(NSDictionary *)attributeMappingDictionary
{
    return nil;
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"form" toKeyPath:@"form" withMapping:[TxOrderConfirmPaymentFormForm mapping]]];

    return mapping;
}

@end
