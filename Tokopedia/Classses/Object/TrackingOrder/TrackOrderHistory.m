//
//  TrackOrderHistory.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TrackOrderHistory.h"

@implementation TrackOrderHistory
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"date",
                      @"status",
                      @"city"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

- (NSString *)status {
    return [_status kv_decodeHTMLCharacterEntities];
}

@end