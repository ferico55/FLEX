//
//  GoogleDistanceMatrixElement.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/2/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "GoogleDistanceMatrixElement.h"

@implementation GoogleDistanceMatrixElement

+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[@"status"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"distance" toKeyPath:@"distance" withMapping:[GoogleDistanceMatrixDetail mapping]];
    [mapping addPropertyMapping: relMapping];
    
    RKRelationshipMapping *relDurationMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"duration" toKeyPath:@"duration" withMapping:[GoogleDistanceMatrixDuration mapping]];
    [mapping addPropertyMapping: relDurationMapping];
    
    return mapping;
    
}

@end
