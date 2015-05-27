//
//  CatalogShops.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ProductList.h"

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


@interface CatalogShops : NSObject

@property (nonatomic, strong) NSString *shop_id;
@property (nonatomic, strong) NSString *shop_name;
@property (nonatomic, strong) NSString *shop_total_address;
@property (nonatomic, strong) NSString *shop_image;
@property (nonatomic, strong) NSString *shop_location;

@property (nonatomic) NSInteger shop_total_product;
@property (nonatomic) NSInteger shop_rate_service;
@property (nonatomic) NSInteger shop_rate_accuracy;
@property (nonatomic) NSInteger shop_rate_speed;
@property (nonatomic) NSInteger is_gold_shop;

@property (nonatomic, strong) NSArray *product_list;

@end
