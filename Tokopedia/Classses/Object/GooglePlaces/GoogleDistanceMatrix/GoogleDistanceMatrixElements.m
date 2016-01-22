//
//  GoogleDistanceMatrixElements.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/2/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "GoogleDistanceMatrixElements.h"

@implementation GoogleDistanceMatrixElements

+ (NSDictionary *)attributeMappingDictionary {
    return nil;
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"element" toKeyPath:@"" withMapping:[GoogleDistanceMatrixElement mapping]];
    [mapping addPropertyMapping: relMapping];
    
    return mapping;
    
}

@end
