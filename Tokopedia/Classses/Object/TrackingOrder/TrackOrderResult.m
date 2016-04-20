//
//  TrackOrderResult.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TrackOrderResult.h"

@implementation TrackOrderResult
+(NSDictionary *)attributeMappingDictionary
{
    return nil;
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"track_order" toKeyPath:@"track_order" withMapping:[TrackOrder mapping]];
    [mapping addPropertyMapping:relMapping];
    return mapping;
}

@end
