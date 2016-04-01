//
//  TransactionSummaryResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionSummaryResult.h"

@implementation TransactionSummaryResult
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"year_now"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"transaction" toKeyPath:@"transaction" withMapping:[TransactionSummaryDetail mapping]]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"credit_card_data" toKeyPath:@"credit_card_data" withMapping:[CCData mapping]]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"veritrans" toKeyPath:@"veritrans" withMapping:[Veritrans mapping]]];

    return mapping;
}

@end
