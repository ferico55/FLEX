//
//  TrackOrderDetail.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TrackOrderDetail.h"

@implementation TrackOrderDetail

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromArray:@[@"shipper_city", @"shipper_name", @"receiver_city", @"send_date", @"receiver_name", @"service_code", @"delivered"]];
    return mapping;
}

- (NSString *)receiver_name {
    return [_receiver_name kv_decodeHTMLCharacterEntities];
}

- (NSString *)shipper_name {
    return [_shipper_name kv_decodeHTMLCharacterEntities];
}

@end
