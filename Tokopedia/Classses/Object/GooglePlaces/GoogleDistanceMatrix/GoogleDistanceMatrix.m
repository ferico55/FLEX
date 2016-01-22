//
//  GoogleDistanceMatrix.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/2/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "GoogleDistanceMatrix.h"

@implementation GoogleDistanceMatrix

+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[@"destination_addresses",
                      @"origin_addresses",
                      @"status"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"rows" toKeyPath:@"rows" withMapping:[GoogleDistanceMatrixRow mapping]];
    [mapping addPropertyMapping: relMapping];
    
    return mapping;
    
}

@end
