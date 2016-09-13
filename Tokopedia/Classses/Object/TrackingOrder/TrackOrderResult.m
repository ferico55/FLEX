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

-(void)setTrack_shipping:(TrackOrder *)track_shipping{
    _track_order = track_shipping;
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"track_order" toKeyPath:@"track_order" withMapping:[TrackOrder mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"track_shipping" toKeyPath:@"track_shipping" withMapping:[TrackOrder mapping]]];
    return mapping;
}

@end
