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
    return [_shop_name kv_decodeHTMLCharacterEntities];
}

+ (RKObjectMapping *)mapping{
    RKObjectMapping *productOwnerMapping = [RKObjectMapping mappingForClass:[ProductOwner class]];
    [productOwnerMapping addAttributeMappingsFromDictionary:@{CUserLabelID:CUserLabelID,
                                                              CUserLabel:CUserLabel,
                                                              CuserID:CuserID,
                                                              @"user_shop_name":CShopName,
                                                              @"user_shop_image":CShopImg,
                                                              @"user_image":CUserImg,
                                                              CUserName:CFullName,
                                                              CFullName:CUserName,
                                                              @"user_image":@"user_img"
                                                              
                                                              }];
    [productOwnerMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CUserShopReputation toKeyPath:CUserShopReputation withMapping:[ShopReputation mapping]]];
    return productOwnerMapping;
}


@end
