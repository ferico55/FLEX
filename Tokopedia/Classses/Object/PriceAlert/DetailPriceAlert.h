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
@end
