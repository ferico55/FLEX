//
//  CatalogShops.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ProductList.h"

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
