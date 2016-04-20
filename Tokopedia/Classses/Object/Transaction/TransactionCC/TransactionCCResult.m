//
//  TransactionCCResult.m
//  Tokopedia
//
//  Created by Renny Runiawati on 7/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionCCResult.h"

@implementation TransactionCCResult
+(NSDictionary *)attributeMappingDictionary
{
    return nil;
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data_credit" toKeyPath:@"data_credit" withMapping:[DataCredit mapping]]];
    return mapping;
}

@end
