//
//  PriceAlertResult.h
//  Tokopedia
//
//  Created by Tokopedia on 5/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Paging;
#import "Breadcrumb.h"
#import "DetailPriceAlert.h"


@interface PriceAlertResult : NSObject
@property (nonatomic, strong) NSArray *department;
@property (nonatomic, strong) Paging *paging;
@property (nonatomic, strong) NSArray *list;
@property (nonatomic, strong) NSArray *list_catalog_shop;
@property (nonatomic, strong) DetailPriceAlert *price_alert_detail;
@property (nonatomic, strong) NSString *catalog_id;
@property (nonatomic, strong) NSString *total_product;

+ (RKObjectMapping*)mapping;

@end
