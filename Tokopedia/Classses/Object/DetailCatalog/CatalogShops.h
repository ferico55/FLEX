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

#define CShopUri @"shop_uri"
#define CShopRateAccuracy @"shop_rate_accuracy"
#define CShopImage @"shop_image"
#define CShopID @"shop_id"
#define CShopName @"shop_name"
#define CShopTotalAddress @"shop_total_address"
#define CShopLocation @"shop_location"
#define CShopTotalProduct @"shop_total_product"
#define CShopRateService @"shop_rate_service"
#define CShopRateSpeed @"shop_rate_speed"
#define CIsGoldShop @"is_gold_shop"
#define CProductList @"product_list"
#define CShopRating @"shop_rating"
#define CShopIsOwner @"shop_is_owner"
#define CShopRatingDesc @"shop_rating_desc"
#define CShopDomain @"shop_domain"
#define CShopReputation @"shop_reputation"


@interface CatalogShops : NSObject

@property (nonatomic, strong) NSString *shop_id;
@property (nonatomic, strong) NSString *shop_name;
@property (nonatomic, strong) NSString *shop_total_address;
@property (nonatomic, strong) NSString *shop_image;
@property (nonatomic, strong) NSString *shop_location;
@property (nonatomic, strong) NSString *shop_uri;
@property (nonatomic, strong) NSString *shop_rating;
@property (nonatomic, strong) NSString *shop_is_owner;
@property (nonatomic, strong) NSString *shop_rating_desc;
@property (nonatomic, strong) NSString *shop_domain;

@property (nonatomic) NSInteger shop_total_product;
@property (nonatomic) NSInteger shop_rate_service;
@property (nonatomic) NSInteger shop_rate_accuracy;
@property (nonatomic) NSInteger shop_rate_speed;
@property (nonatomic) NSInteger is_gold_shop;
@property (nonatomic, strong) NSString *shop_lucky;

@property (nonatomic, strong) NSArray *product_list;
@property (nonatomic, strong) ShopReputation *shop_reputation_badge;

+ (RKObjectMapping *)mapping;

@end
