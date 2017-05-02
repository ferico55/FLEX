//
//  GooglePlaceDetailResults.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/2/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "GooglePlaceDetailResults.h"

@implementation GooglePlaceDetailResults

+ (NSDictionary *)attributeMappingDictionary {
    return nil;
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"result" toKeyPath:@"result" withMapping:[GoogleplaceDetailResult mapping]]];
    return mapping;
    
}

@end
