//
//  ShopProductPageList.h
//  Tokopedia
//
//  Created by Johanes Effendi on 3/24/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ProductModelView;
@class CatalogModelView;

@interface ShopProductPageList : NSObject
@property(nonatomic, strong) NSString* shop_lucky;
@property(nonatomic, strong) NSString* shop_gold_status;
@property(nonatomic, strong) NSString* shop_id;
@property(nonatomic, strong) NSString* product_rating_point;
@property(nonatomic, strong) NSString* product_department_id;
@property(nonatomic, strong) NSString* product_etalase;
@property(nonatomic, strong) NSString* shop_url;
@property(nonatomic, strong) NSString* shop_featured_shop;
@property(nonatomic, strong) NSString* product_status;
@property(nonatomic, strong) NSString* product_id;
@property(nonatomic, strong) NSString* product_image_full;
@property(nonatomic, strong) NSString* product_currency_id;
@property(nonatomic, strong) NSString* product_rating_desc;
@property(nonatomic, strong) NSString* product_currency;
@property(nonatomic, strong) NSString* product_talk_count;
@property(nonatomic, strong) NSString* product_price_no_idr;
@property(nonatomic, strong) NSString* product_image;
@property(nonatomic, strong) NSString* product_price;
@property(nonatomic, strong) NSString* product_sold_count;
@property(nonatomic, strong) NSString* product_returnable;
@property(nonatomic, strong) NSString* shop_location;
//@property(nonatomic, strong) NSString* product_preorder;
@property(nonatomic, strong) NSString* product_normal_price;
@property(nonatomic, strong) NSString* product_image_300;
@property(nonatomic, strong) NSString* product_image_700;
@property(nonatomic, strong) NSString* shop_name;
@property(nonatomic, strong) NSString* product_review_count;
@property(nonatomic, strong) NSString* shop_is_owner;
@property(nonatomic, strong) NSString* product_url;
@property(nonatomic, strong) NSString* product_name;
@property(nonatomic, strong) NSArray* badges;
@property(nonatomic, strong) NSArray* labels;

@property NSInteger product_wholesale;
@property NSInteger product_preorder;

@property (nonatomic, assign) BOOL is_product_preorder;
@property (nonatomic, assign) BOOL is_product_wholesale;


@property (nonatomic, strong) ProductModelView *viewModel;

+(RKObjectMapping*)mapping;
- (NSDictionary *)productFieldObjects;
@end
