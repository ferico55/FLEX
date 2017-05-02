//
//  GoogleDistanceMatrixRows.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/2/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "GoogleDistanceMatrixRows.h"

@implementation GoogleDistanceMatrixRows

+ (NSDictionary *)attributeMappingDictionary {
    return nil;
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"row" toKeyPath:@"row" withMapping:[GoogleDistanceMatrixRow mapping]]];
    return mapping;
    
}

@end
