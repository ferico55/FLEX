//
//  SearchAWSShop.h
//  Tokopedia
//
//  Created by Tonito Acen on 1/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tokopedia-Swift.h"

@interface SearchAWSShop : NSObject

@property (nonatomic, strong) NSString *shop_is_fave_shop;
@property NSInteger shop_gold_status;

@property (nonatomic, strong) NSString *shop_id;
@property (nonatomic, strong) NSString *shop_name;
@property (nonatomic, strong) NSString *shop_domain;
@property (nonatomic, strong) NSString *shop_url;
@property (nonatomic, strong) NSString *shop_is_img;
@property (nonatomic, strong) NSString *shop_image;
@property (nonatomic, strong) NSString *shop_image_300;
@property (nonatomic, strong) NSString *shop_description;
@property (nonatomic, strong) NSString *shop_tag_line;
@property (nonatomic, strong) NSString *shop_location;
@property (nonatomic, strong) NSString *shop_total_transaction;
@property (nonatomic, strong) NSString *shop_total_favorite;
@property (nonatomic, strong) NSString *shop_gold_shop;
@property (nonatomic, strong) NSString *shop_is_owner;
@property (nonatomic, strong) NSString *shop_rate_speed;
@property (nonatomic, strong) NSString *shop_rate_accuracy;
@property (nonatomic, strong) NSString *shop_rate_service;
@property (nonatomic, strong) NSString *shop_status;
@property (nonatomic, strong) NSString *shop_lucky;
@property (nonatomic, strong) NSString *reputation_image_uri;
@property (nonatomic, strong) NSString *reputation_score;

@property (nonatomic, strong) SearchShopModelView* modelView;


@end
