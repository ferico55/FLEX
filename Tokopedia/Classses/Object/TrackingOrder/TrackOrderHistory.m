//
//  TrackOrderHistory.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TrackOrderHistory.h"

@implementation TrackOrderHistory

- (NSString *)status {
    return [_status kv_decodeHTMLCharacterEntities];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromArray:@[@"date", @"status", @"city"]];

    return mapping;
}

@end