//
//  Address.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Address.h"

@implementation Address

- (NSString *)location_phone {
    if ([_location_phone isEqualToString:@"0"]) {
        return nil;
    } else {
        return _location_phone;
    }
}

- (NSString *)location_address {
    return [_location_address kv_decodeHTMLCharacterEntities];
}

- (NSString *)location_address_name {
    return [_location_address_name kv_decodeHTMLCharacterEntities];
}

@end
