//
//  Address.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Address.h"

@implementation Address

- (NSString *)location_address {
    return [_location_address kv_decodeHTMLCharacterEntities];
}

- (NSString *)location_address_name {
    return [_location_address_name kv_decodeHTMLCharacterEntities];
}

+(RKObjectMapping *)mapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Address class]];
    [mapping addAttributeMappingsFromArray:@[@"location_city_name",
                                             @"location_email",
                                             @"location_address",
                                             @"location_postal_code",
                                             @"location_city_id",
                                             @"location_area",
                                             @"location_phone",
                                             @"location_district_id",
                                             @"location_province_name",
                                             @"location_province_id",
                                             @"location_district_name",
                                             @"location_address_id",
                                             @"location_fax",
                                             @"location_address_name"
                                             ]];
    return mapping;
}

@end
