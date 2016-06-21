//
//  AddressResult.m
//  Tokopedia
//
//  Created by Renny Runiawati on 6/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "AddressResult.h"

@implementation AddressResult
+(NSDictionary *)attributeMappingDictionary
{
    return nil;
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];

    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"cities" toKeyPath:@"cities" withMapping:[AddressCity mapping]];
    [mapping addPropertyMapping:relMapping];
    
    RKRelationshipMapping *relMapping1 = [RKRelationshipMapping relationshipMappingFromKeyPath:@"districts" toKeyPath:@"districts" withMapping:[AddressDistrict mapping]];
    [mapping addPropertyMapping:relMapping1];
    
    RKRelationshipMapping *relMapping3 = [RKRelationshipMapping relationshipMappingFromKeyPath:@"shipping_city" toKeyPath:@"shipping_city" withMapping:[AddressDistrict mapping]];
    [mapping addPropertyMapping:relMapping3];
    
    RKRelationshipMapping *relMapping2 = [RKRelationshipMapping relationshipMappingFromKeyPath:@"provinces" toKeyPath:@"provinces" withMapping:[AddressProvince mapping]];
    [mapping addPropertyMapping:relMapping2];
    
    
    return mapping;
}

@end
