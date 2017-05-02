//
//  RateResponse.m
//  Tokopedia
//
//  Created by Renny Runiawati on 2/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RateResponse.h"

@implementation RateResponse

+(NSDictionary *)attributeMappingDictionary
{
    return nil;
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:[RateData mapping]]];
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"errors" toKeyPath:@"erros" withMapping:[RateData mapping]];
    [mapping addPropertyMapping:relMapping];
    
    return mapping;
}


@end
