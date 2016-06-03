//
//  DetailPriceAlert.h
//  Tokopedia
//
//  Created by Tokopedia on 5/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#define CPriceAlertTotalProduct @"pricealert_total_product"
#define CPriceAlertPriceMin @"pricealert_price_min"
#define CPriceAlertIsActive @"pricealert_is_active"
#define CPriceAlertProductName @"pricealert_product_name"
#define CPriceAlertProductStatus @"pricealert_product_status"
#define CPriceAlertTotalUnread @"pricealert_total_unread"
#define CPriceAlertType @"pricealert_type"
#define CPriceAlertPrice @"pricealert_price"
#define CPriceAlertProductImage @"pricealert_product_image"
#define CPriceAlertID @"pricealert_id"
#define CPriceAlertProductID @"pricealert_product_id"
#define CPriceAlertItemImage @"pricealert_item_image"
#define CPriceAlertItemName @"pricealert_item_name"
#define CPriceAlertProductShopID @"pricealert_product_shop_id"
#define CPriceAlertCatalogID @"pricealert_catalog_id"
#define CPriceAlertTypeDesc @"pricealert_type_desc"
#define CPriceAlertItemID @"pricealert_item_id"
#define CPriceAlertProductCatalogID @"pricealert_product_catalog_id"
#define CPriceAlertProductDepartmentID @"pricealert_product_department_id"
#define CPriceAlertCatalogDepartmentID @"pricealert_catalog_department_id"
#define CPriceAlertItemURI @"pricealert_item_uri"
#define CPriceAlertCatalogName @"pricealert_catalog_name"
#define CPriceAlertCatalogStatus @"pricealert_catalog_status"
#define CPriceAlertTime @"pricealert_time"

@interface DetailPriceAlert : NSObject
@property (nonatomic, strong) NSString *pricealert_total_product;
@property (nonatomic, strong) NSString *pricealert_price_min;
@property (nonatomic, strong) NSString *pricealert_is_active;
@property (nonatomic, strong) NSString *pricealert_product_name;
@property (nonatomic, strong) NSString *pricealert_product_status;
@property (nonatomic, strong) NSString *pricealert_total_unread;
@property (nonatomic, strong) NSString *pricealert_type;
@property (nonatomic, strong) NSString *pricealert_price;
@property (nonatomic, strong) NSString *pricealert_product_image;
@property (nonatomic, strong) NSString *pricealert_id;
@property (nonatomic, strong) NSString *pricealert_product_id;
@property (nonatomic, strong) NSString *pricealert_time;
@property (nonatomic, strong) NSString *pricealert_shop_domain;
@property (nonatomic, strong) NSString *pricealert_shop_location;
@property (nonatomic, strong) NSString *pricealert_shop_id;

@property (nonatomic, strong) NSString *pricealert_item_image;
@property (nonatomic, strong) NSString *pricealert_item_name;
@property (nonatomic, strong) NSString *pricealert_product_shop_id;
@property (nonatomic, strong) NSString *pricealert_catalog_id;
@property (nonatomic, strong) NSString *pricealert_type_desc;
@property (nonatomic, strong) NSString *pricealert_item_id;
@property (nonatomic, strong) NSString *pricealert_product_catalog_id;
@property (nonatomic, strong) NSString *pricealert_product_department_id;
@property (nonatomic, strong) NSString *pricealert_catalog_department_id;
@property (nonatomic, strong) NSString *pricealert_item_uri;
@property (nonatomic, strong) NSString *pricealert_catalog_name;
@property (nonatomic, strong) NSString *pricealert_catalog_status;

+ (RKObjectMapping*)mapping;

@end
