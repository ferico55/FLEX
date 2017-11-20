//
//  HotlistBannerResult.m
//  Tokopedia
//
//  Created by Tonito Acen on 9/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "HotlistBannerResult.h"

@implementation HotlistBannerResult

+(NSDictionary *)attributeMappingDictionary
{
    return nil;
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"info" toKeyPath:@"info" withMapping:[HotlistBannerInfo mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"query" toKeyPath:@"query" withMapping:[HotlistBannerQuery mapping]]];
    [mapping addAttributeMappingsFromDictionary:@{@"disable_topads" : @"disableTopAds"}];
    return mapping;
}


@end
