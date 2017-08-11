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

@interface CatalogInfo : NSObject<TKPObjectMapping>

@property (nonatomic, strong, nonnull) NSString *catalog_description;
@property (nonatomic, strong, nonnull) NSString *catalog_key;
@property (nonatomic, strong, nonnull) NSString *catalog_department_id;
@property (nonatomic, strong, nonnull) NSString *catalog_id;
@property (nonatomic, strong, nonnull) NSString *catalog_name;
@property (nonatomic, strong, nonnull) CatalogPrice *catalog_price;
@property (nonatomic, strong, nonnull) NSArray *catalog_images;
@property (nonatomic, strong, nonnull) NSString *catalog_url;
@property (nonatomic, strong, nonnull) NSString *catalog_pricealert_price;
@end
