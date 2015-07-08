//
//  NewOrderDestination.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "OrderDestination.h"

@implementation OrderDestination

- (NSString *)receiver_name {
    return [_receiver_name kv_decodeHTMLCharacterEntities];
}

- (NSString *)address_country {
    return [_address_country kv_decodeHTMLCharacterEntities];
}

- (NSString *)address_district {
    return [_address_district kv_decodeHTMLCharacterEntities];
}

- (NSString *)address_street {
    return [_address_street kv_decodeHTMLCharacterEntities];
}

- (NSString *)address_city {
    return [_address_city kv_decodeHTMLCharacterEntities];
}

- (NSString *)address_province {
    return [_address_province kv_decodeHTMLCharacterEntities];
}

@end
