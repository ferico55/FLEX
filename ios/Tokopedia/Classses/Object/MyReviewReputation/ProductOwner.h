//
//  ProductOwner.h
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CUserShopReputation @"user_shop_reputation"
@class ShopReputation;

@interface ProductOwner : NSObject
@property (nonatomic, strong) NSString *shop_id;
@property (nonatomic, strong) NSString *user_label_id;
@property (nonatomic, strong) NSString *user_url;
@property (nonatomic, strong) NSString *shop_img;
@property (nonatomic, strong) NSString *shop_url;
@property (nonatomic, strong) NSString *shop_name;
@property (nonatomic, strong) NSString *full_name;
@property (nonatomic, strong) NSString *shop_reputation_score;
@property (nonatomic, strong) NSString *user_img;
@property (nonatomic, strong) NSString *user_label;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *shop_reputation_badge;

@property (nonatomic, strong) NSString *user_shop_name;
@property (nonatomic, strong) NSString *user_name;
@property (nonatomic, strong) NSString *user_shop_image;
@property (nonatomic, strong) NSString *user_image;

@property (nonatomic, strong) ShopReputation *user_shop_reputation;

+ (RKObjectMapping*)mapping;
+ (RKObjectMapping*)mappingForInbox;

@end
