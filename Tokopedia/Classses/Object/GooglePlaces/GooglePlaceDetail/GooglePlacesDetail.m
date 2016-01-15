//
//  GooglePlacesDetail.m
//  Tokopedia
//
//  Created by Renny Runiawati on 10/30/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "GooglePlacesDetail.h"

@implementation GooglePlacesDetail

+ (NSDictionary *)attributeMappingDictionary {
    return nil;
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"result" toKeyPath:@"result" withMapping:[GoogleplaceDetailResult mapping]]];
    RKRelationshipMapping *resultsRelMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"results" toKeyPath:@"results" withMapping:[GoogleplaceDetailResult mapping]];
    [mapping addPropertyMapping: resultsRelMapping];
    return mapping;
    
}

@end
