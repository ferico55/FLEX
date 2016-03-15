//
//  PromoProduct.h
//  Tokopedia
//
//  Created by Tokopedia on 7/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductModelView.h"

@interface PromoProduct : NSObject

@property (strong, nonatomic) NSString *ad_sem_key;
@property (strong, nonatomic) NSString *shop_gold_status;
@property (strong, nonatomic) NSString *shop_id;
@property (strong, nonatomic) NSString *shop_url;
@property (strong, nonatomic) NSString *product_image_200;
@property (strong, nonatomic) NSString *product_image_100;
@property (strong, nonatomic) NSString *product_id;
@property (strong, nonatomic) NSString *shop_url_topads;
@property (strong, nonatomic) NSString *ad_key;
@property (strong, nonatomic) NSString *shop_rate_speed_desc;
@property (strong, nonatomic) NSString *product_talk_count;
@property (strong, nonatomic) NSString *shop_rate_service_desc;
@property (strong, nonatomic) NSString *product_price;
@property (strong, nonatomic) NSString *shop_location;
@property (strong, nonatomic) NSString *product_wholesale;
@property (strong, nonatomic) NSString *shop_rate_speed;
@property (strong, nonatomic) NSString *product_url_topads;
@property (strong, nonatomic) NSString *product_review_count;
@property (strong, nonatomic) NSString *shop_name;
@property (strong, nonatomic) NSString *ad_r;
@property (strong, nonatomic) NSString *ad_sticker_image;
@property (strong, nonatomic) NSString *shop_rate_accuracy_desc;
@property (strong, nonatomic) NSString *shop_is_owner;
@property (strong, nonatomic) NSString *product_url;
@property (strong, nonatomic) NSString *product_name;
@property (strong, nonatomic) NSString *shop_lucky;

@property (strong, nonatomic) ProductModelView *viewModel;

- (NSDictionary *)productFieldObjects;

+ (RKObjectMapping *)mapping;

@end
