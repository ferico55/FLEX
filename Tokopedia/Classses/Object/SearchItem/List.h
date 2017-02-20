//
//  SearchItem.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/4/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ProductModelView.h"
#import "CatalogModelView.h"

@interface List : NSObject

/** shop **/
@property (nonatomic, strong) NSString *shop_image;
@property (nonatomic, strong) NSString *shop_id;
@property (nonatomic, strong) NSString *shop_total_transaction;
@property (nonatomic, strong) NSString *shop_total_favorite;
@property (nonatomic, strong) NSString *shop_is_fave_shop;

/** catalog **/
@property (nonatomic, strong) NSString *catalog_id;
@property (nonatomic, strong) NSString *catalog_name;
@property (nonatomic, strong) NSString *catalog_image;
@property (nonatomic, strong) NSString *catalog_image_300;
@property (nonatomic, strong) NSString *catalog_price;
@property (nonatomic, strong) NSString *catalog_count_shop;

/** product **/
@property (nonatomic, strong) NSString *product_price;
@property (nonatomic, strong) NSString *product_id;
@property (nonatomic, strong) NSString *shop_gold_status;
@property (nonatomic, strong) NSString *shop_location;
@property (nonatomic, strong) NSString *shop_name;
@property (nonatomic, strong) NSString *product_image;
@property (nonatomic, strong) NSString *product_image_full;
@property (nonatomic, strong) NSString *product_name;
@property (nonatomic, strong) NSString *product_talk_count;
@property (nonatomic, strong) NSString *product_review_count;
@property (nonatomic) BOOL product_preorder;
@property (nonatomic, strong) NSString *statusInfo;

@property (nonatomic, strong) ProductModelView *viewModel;
@property (nonatomic, strong) CatalogModelView *catalogViewModel;

- (NSDictionary *)productFieldObjects;

@end
