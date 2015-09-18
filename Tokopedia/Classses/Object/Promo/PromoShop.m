//
//  PromoShop.m
//  Tokopedia
//
//  Created by Tokopedia on 7/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "PromoShop.h"

@implementation PromoShop

- (NSString *)shop_name {
    return [_shop_name kv_decodeHTMLCharacterEntities];
}

- (NSString *)ad_key {
    return _ad_key?:@"";
}

@end
