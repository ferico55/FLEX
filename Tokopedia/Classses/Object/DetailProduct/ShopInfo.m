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

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"shop_open_since",
                      @"shop_location",
                      @"shop_status",
                      @"shop_id",
                      @"shop_owner_last_login",
                      @"shop_tagline",
                      @"shop_name",
                      @"shop_already_favorited",
                      @"shop_has_terms",
                      @"shop_description",
                      @"shop_avatar",        //shop_image (cart)
                      @"shop_total_favorit",
                      @"shop_cover",
                      @"shop_domain",
                      @"shop_url",
                      @"shop_is_owner",
                      @"shop_lucky",
                      @"shop_is_gold",
                      @"shop_is_closed_note",
                      @"shop_is_closed_reason",
                      @"shop_is_closed_until",
                      @"lucky_merchant"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shop_stats" toKeyPath:@"shop_stats" withMapping:[ShopStats mapping]]];
    
        [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"respond_speed" toKeyPath:@"respond_speed" withMapping:[ResponseSpeed mapping]]];
    
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"shop_pay_gateway" toKeyPath:@"shop_pay_gateway" withMapping:[ResponseSpeed mapping]];
    
    [mapping addPropertyMapping:relMapping];
    return mapping;
}


@end
