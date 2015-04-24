//
//  CatalogShops.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "CatalogShops.h"

@implementation CatalogShops

- (NSString*)shop_name {
    return [_shop_name kv_decodeHTMLCharacterEntities];
}

@end
