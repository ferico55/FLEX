//
//  PromoResult.m
//  Tokopedia
//
//  Created by Tokopedia on 7/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "PromoResult.h"

@implementation PromoResult
+(RKObjectMapping *)mapping{
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[PromoResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"id":@"result_id"}];
    [resultMapping addAttributeMappingsFromArray:@[@"ad_ref_key",
                                                   @"redirect",
                                                   @"sticker_id",
                                                   @"sticker_image",
                                                   @"product_click_url",
                                                   @"shop_click_url"
                                                   ]];
    /*
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"product"
                                                                                  toKeyPath:@"product"
                                                                                withMapping:[PromoProduct mapping]]];
     
    */
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shop"
                                                                                  toKeyPath:@"shop"
                                                                                withMapping:[PromoShop mapping]]];
     
    return resultMapping;
}
@end
