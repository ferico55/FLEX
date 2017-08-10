//
//  CatalogShops.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductList.h"
#import "ShopReputation.h"
#import "ShopStats.h"


@interface CatalogShops : NSObject

@property (nonatomic, strong, nonnull) NSString *shop_id;
@property (nonatomic, strong, nonnull) NSString *shop_name;
@property (nonatomic, strong, nonnull) NSString *shop_total_address;
@property (nonatomic, strong, nonnull) NSString *shop_image;
@property (nonatomic, strong, nonnull) NSString *shop_location;
@property (nonatomic, strong, nonnull) NSString *shop_uri;
@property (nonatomic, strong, nonnull) NSString *shop_rating;
@property (nonatomic, strong, nonnull) NSString *shop_is_owner;
@property (nonatomic, strong, nonnull) NSString *shop_rating_desc;
@property (nonatomic, strong, nonnull) NSString *shop_domain;

@property (nonatomic) NSInteger shop_total_product;
@property (nonatomic) NSInteger shop_rate_service;
@property (nonatomic) NSInteger shop_rate_accuracy;
@property (nonatomic) NSInteger shop_rate_speed;
@property (nonatomic) NSInteger is_gold_shop;
@property (nonatomic, strong, nonnull) NSString *shop_lucky;

@property (nonatomic, strong, nonnull) NSArray *product_list;
@property (nonatomic, strong, nonnull) ShopReputation *shop_reputation_badge;
@property (nonatomic, strong, nonnull) ShopStats *shop_reputation;

+ (RKObjectMapping *_Nonnull)mapping;

@end
