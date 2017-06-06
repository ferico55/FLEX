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

@property (nonatomic, strong) CatalogInfo *catalog_info;
@property (nonatomic, strong) NSArray *catalog_specs;
@property (nonatomic, strong) CatalogReview *catalog_review;
@property (nonatomic, strong) CatalogMarketPlace *catalog_market_price;
@property (nonatomic, strong) NSArray *catalog_shops;
@property (nonatomic, strong) NSString *catalog_image;
@property (nonatomic, strong) NSString *catalog_description;
@property (nonatomic, strong) NSArray *catalog_location;
@property (nonatomic, strong) Paging *paging;

@end
