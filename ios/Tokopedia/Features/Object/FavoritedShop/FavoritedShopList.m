//
//  FavoritedShopList.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "FavoritedShopList.h"
#import "Tokopedia-Swift.h"

@implementation FavoritedShopList

- (NSString*)shop_name {
    return [_shop_name kv_decodeHTMLCharacterEntities];
}

+(NSDictionary *) attributeMappingDictionary {
    NSArray *keys = @[@"shop_image",
                      @"shop_location",
                      @"shop_id",
                      @"shop_name"];
    
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping *) mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass: self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    RKRelationshipMapping *badgeMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"shop_badge" toKeyPath:@"shop_badge" withMapping:[ProductBadge mapping]];
    [mapping addPropertyMapping:badgeMapping];
    
    return mapping;
}

@end
