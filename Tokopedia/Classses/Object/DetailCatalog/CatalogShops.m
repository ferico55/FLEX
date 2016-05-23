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

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[CatalogShops class]];
    
    [mapping addAttributeMappingsFromArray:@[@"shop_id",
                                             @"shop_name",
                                             @"shop_total_address",
                                             @"shop_image",
                                             @"shop_location",
                                             @"shop_uri",
                                             @"shop_rating",
                                             @"shop_is_owner",
                                             @"shop_rating_desc",
                                             @"shop_domain",
                                             @"shop_total_product",
                                             @"shop_rate_service",
                                             @"shop_rate_accuracy",
                                             @"shop_rate_speed",
                                             @"is_gold_shop",
                                             @"shop_lucky"]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"product_list"
                                                                            toKeyPath:@"product_list"
                                                                          withMapping:[ProductDetail mapping]]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shop_reputation"
                                                                            toKeyPath:@"shop_reputation"
                                                                          withMapping:[ShopReputation mapping]]];
    
    return mapping;
}

@end
