//
//  TrackOrderDetail.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TrackOrderDetail.h"

@implementation TrackOrderDetail

- (NSString *)receiver_name {
    return [_receiver_name kv_decodeHTMLCharacterEntities];
}

- (NSString *)shipper_name {
    return [_shipper_name kv_decodeHTMLCharacterEntities];
}

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"shipper_city",
                      @"shipper_name",
                      @"receiver_city",
                      @"send_date",
                      @"receiver_name",
                      @"service_code",
                      @"delivered"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

@end
