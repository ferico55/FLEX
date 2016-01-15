//
//  GooglePlaceDetailGeometry.m
//  Tokopedia
//
//  Created by Renny Runiawati on 10/30/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "GooglePlaceDetailGeometry.h"

@implementation GooglePlaceDetailGeometry

+ (NSDictionary *)attributeMappingDictionary {
    return nil;
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"location" toKeyPath:@"location" withMapping:[GooglePlaceDetailLocation mapping]]];
    return mapping;
    
}

@end
