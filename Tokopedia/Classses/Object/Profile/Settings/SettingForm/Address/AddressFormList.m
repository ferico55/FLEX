//
//  AddressFormList.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "AddressFormList.h"

@implementation AddressFormList

- (NSString*) address_street {
    return [_address_street kv_decodeHTMLCharacterEntities];
}

@end
