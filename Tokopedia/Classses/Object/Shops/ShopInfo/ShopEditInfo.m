//
//  ShopInfo.m
//  Tokopedia
//
//  Created by Tokopedia on 3/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ShopEditInfo.h"

@implementation ShopEditInfo

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    NSArray *mappings = @[
                          @"shop_already_favorited",
                          @"shop_avatar",
                          @"shop_cover",
                          @"shop_description",
                          @"shop_domain",
                          @"shop_has_terms",
                          @"shop_id",
                          @"shop_is_closed_note",
                          @"shop_is_closed_reason",
                          @"shop_is_closed_until",
                          @"shop_is_gold",
                          @"shop_is_owner",
                          @"shop_location",
                          @"shop_name",
                          @"shop_open_since",
                          @"shop_owner_id",
                          @"shop_owner_last_login",
                          @"shop_status",
                          @"shop_tagline",
                          @"shop_total_favorite",
                          @"shop_url",
                          @"shop_gold_expired_time"
                          ];
    [mapping addAttributeMappingsFromArray:mappings];
    return mapping;
}

- (NSString *)shop_description {
    return [_shop_description kv_decodeHTMLCharacterEntities];
}

- (NSString *)shop_tagline {
    return [_shop_tagline kv_decodeHTMLCharacterEntities];
}

@end
