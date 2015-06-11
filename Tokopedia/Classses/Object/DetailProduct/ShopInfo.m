//
//  ShopInfo.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ShopInfo.h"

@implementation ShopInfo

- (NSString*) shop_description {
    return [_shop_description kv_decodeHTMLCharacterEntities];
}

- (NSString*) shop_name {
    return [_shop_name kv_decodeHTMLCharacterEntities];
}

- (NSString*) shop_tagline {
    return [_shop_tagline kv_decodeHTMLCharacterEntities];
}

@end
