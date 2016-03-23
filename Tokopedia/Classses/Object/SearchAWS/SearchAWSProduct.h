//
//  SearchAWSProduct.h
//  Tokopedia
//
//  Created by Tonito Acen on 8/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TKPObjectMapping.h"
@class ProductModelView;
@class CatalogModelView;

@interface SearchAWSProduct : NSObject <TKPObjectMapping>

//product
@property (nonatomic, strong) NSString *product_url;
@property (nonatomic, strong) NSString *product_name;
@property (nonatomic, strong) NSString *product_id;
@property (nonatomic, strong) NSString *product_image_full;
@property (nonatomic, strong) NSString *product_image;
@property (nonatomic, strong) NSString *product_price;
@property (nonatomic, strong) NSString *product_wholesale;
@property (nonatomic, strong) NSString *shop_location;
@property (nonatomic, strong) NSString *shop_url;
@property (nonatomic, strong) NSString *shop_gold_status;
@property (nonatomic, strong) NSString *shop_name;
@property (nonatomic, strong) NSString *rate;
@property (nonatomic, strong) NSString *product_sold_count;
@property (nonatomic, strong) NSString *product_review_count;
@property (nonatomic, strong) NSString *product_talk_count;
@property (nonatomic, strong) NSString *is_owner;
@property (nonatomic, strong) NSString *shop_lucky;

@property (nonatomic, strong) NSString *shop_id;
@property (nonatomic, strong) NSString *condition;

//catalog
@property (nonatomic, strong) NSString *catalog_id;
@property (nonatomic, strong) NSString *catalog_name;
@property (nonatomic, strong) NSString *catalog_price;
@property (nonatomic, strong) NSString *catalog_uri;
@property (nonatomic, strong) NSString *catalog_image;
@property (nonatomic, strong) NSString *catalog_image_300;
@property (nonatomic, strong) NSString *catalog_description;
@property (nonatomic, strong) NSString *catalog_count_product;

//only used in image search
@property (strong, nonatomic) NSString *similarity_rank;

@property (nonatomic, strong) ProductModelView *viewModel;
@property (nonatomic, strong) CatalogModelView *catalogViewModel;

- (NSDictionary *)productFieldObjects;

@end
