//
//  GoogleplaceDetailResult.m
//  Tokopedia
//
//  Created by Renny Runiawati on 10/30/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "GoogleplaceDetailResult.h"

@implementation GoogleplaceDetailResult

+ (NSDictionary *)attributeMappingDictionary {
    return nil;
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"geometry" toKeyPath:@"geometry" withMapping:[GooglePlaceDetailGeometry mapping]]];
    return mapping;
    
}

@end
