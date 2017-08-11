//
//  DetailCatalogResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CatalogInfo.h"
#import "CatalogSpecs.h"
#import "CatalogReview.h"
#import "CatalogMarketPlace.h"
#import "CatalogShops.h"
#import "CatalogLocation.h"
@class Paging;

@interface DetailCatalogResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong, nonnull) CatalogInfo *catalog_info;
@property (nonatomic, strong, nonnull) NSArray *catalog_specs;
@property (nonatomic, strong, nonnull) CatalogReview *catalog_review;
@property (nonatomic, strong, nonnull) CatalogMarketPlace *catalog_market_price;
@property (nonatomic, strong, nonnull) NSArray *catalog_shops;
@property (nonatomic, strong, nonnull) NSString *catalog_image;
@property (nonatomic, strong, nonnull) NSString *catalog_description;
@property (nonatomic, strong, nonnull) NSArray *catalog_location;
@property (nonatomic, strong, nonnull) Paging *paging;

@end
