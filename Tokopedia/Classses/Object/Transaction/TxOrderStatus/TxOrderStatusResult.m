//
//  TxOrderStatusResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/17/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderStatusResult.h"

@implementation TxOrderStatusResult
+(NSDictionary *)attributeMappingDictionary
{
    return nil;
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"paging" toKeyPath:@"paging" withMapping:[Paging mapping]]];
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"list" toKeyPath:@"list" withMapping:[TxOrderStatusList mapping]];
    [mapping addPropertyMapping:relMapping];
    return mapping;
}

@end
