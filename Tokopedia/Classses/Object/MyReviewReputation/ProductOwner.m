//
//  ProductOwner.m
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ProductOwner.h"
#import "ShopReputation.h"

@implementation ProductOwner

- (NSString*)shop_name {
    if (_shop_name != nil) {
        return [_shop_name kv_decodeHTMLCharacterEntities];
    } else {
        return [_user_shop_name kv_decodeHTMLCharacterEntities];
    }
}

- (NSString*)shop_img {
    if (_shop_img != nil) {
        return _shop_img;
    } else {
        return _user_shop_image;
    }
}

- (NSString*)user_img {
    if (_user_img != nil) {
        return _user_img;
    } else {
        return _user_image;
    }
}

- (NSString*)full_name {
    if (_full_name != nil) {
        return [_full_name kv_decodeHTMLCharacterEntities];
    } else {
        return [_user_name kv_decodeHTMLCharacterEntities];
    }
}

+ (RKObjectMapping *)mapping{
    RKObjectMapping *productOwnerMapping = [RKObjectMapping mappingForClass:[ProductOwner class]];
    [productOwnerMapping addAttributeMappingsFromDictionary:@{@"user_label_id"          : @"user_label_id",
                                                              @"user_label"             : @"user_label",
                                                              @"user_id"                : @"user_id",
                                                              @"user_shop_name"         : @"shop_name",
                                                              @"user_shop_image"        : @"shop_img",
                                                              @"user_image"             : @"user_img",
                                                              CUserName                 : CFullName,
                                                              CFullName                 : CUserName,
                                                              @"user_image"             : @"user_img",
                                                              
                                                              @"shop_id"                : @"shop_id",                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
                                                              @"user_url"               : @"user_url",
                                                              @"shop_url"               : @"shop_url",
                                                              @"shop_reputation_badge"  : @"shop_reputation_badge",
                                                              @"shop_reputation_score"  : @"shop_reputation_score"}];
    
    [productOwnerMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CUserShopReputation toKeyPath:CUserShopReputation withMapping:[ShopReputation mapping]]];
    return productOwnerMapping;
}

+ (RKObjectMapping *)mappingForInbox {
    RKObjectMapping *productOwnerMapping = [RKObjectMapping mappingForClass:[ProductOwner class]];
    [productOwnerMapping addAttributeMappingsFromArray:@[@"user_label_id",
                                                         @"shop_id",
                                                         @"user_url",
                                                         @"full_name",
                                                         @"shop_name",
                                                         @"shop_url",
                                                         @"shop_img",
                                                         @"user_img",
                                                         @"user_label",
                                                         @"user_id",
                                                         @"shop_reputation_badge",
                                                         @"shop_reputation_score"]];
    
    return productOwnerMapping;
}


@end
