//
//  CatalogInfo.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CatalogPrice.h"
#import "CatalogImages.h"
#define CCatalogID @"catalog_id"
#define CCatalogPriceAlertPrice @"catalog_pricealert_price"
@interface CatalogInfo : NSObject<TKPObjectMapping>

@property (nonatomic, strong) NSString *catalog_description;
@property (nonatomic, strong) NSString *catalog_key;
@property (nonatomic, strong) NSString *catalog_department_id;
@property (nonatomic, strong) NSString *catalog_id;
@property (nonatomic, strong) NSString *catalog_name;
@property (nonatomic, strong) CatalogPrice *catalog_price;
@property (nonatomic, strong) NSArray *catalog_images;
@property (nonatomic, strong) NSString *catalog_url;
@property (nonatomic, strong) NSString *catalog_pricealert_price;
@end
