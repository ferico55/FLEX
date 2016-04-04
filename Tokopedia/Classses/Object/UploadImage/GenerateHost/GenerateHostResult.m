//
//  GenerateHostResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "GenerateHostResult.h"

@implementation GenerateHostResult
+(NSDictionary *)attributeMappingDictionary
{
    return nil;
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"generated_host" toKeyPath:@"generated_host" withMapping:[GeneratedHost mapping]]];
    return mapping;
}


@end
