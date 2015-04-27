//
//  ShopInfo.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ShopStats.h"
#import "TransactionCartGateway.h"

@interface ShopInfo : NSObject

@property (nonatomic, strong) NSString *shop_open_since;
@property (nonatomic, strong) NSString *shop_location;
@property (nonatomic, strong) NSString *shop_status;
@property (nonatomic, strong) NSString *shop_id;
@property (nonatomic, strong) NSString *shop_owner_last_login;
@property (nonatomic, strong) NSString *shop_tagline;
@property (nonatomic, strong) NSString *shop_name;
@property (nonatomic, strong) ShopStats *shop_stats;
@property (nonatomic) NSInteger shop_already_favorited;
@property (nonatomic, strong) NSString *shop_description;
@property (nonatomic, strong) NSString *shop_avatar;        //shop_image (cart)
@property (nonatomic, strong) NSString *shop_total_favorit;
@property (nonatomic, strong) NSString *shop_cover;
@property (nonatomic, strong) NSString *shop_domain;
@property (nonatomic, strong) NSString *shop_url;
@property (nonatomic, strong) NSString *shop_is_owner;
@property (nonatomic) NSInteger shop_is_gold;
@property (nonatomic, strong) NSString *shop_is_closed_note;
@property (nonatomic, strong) NSString *shop_is_closed_reason;
@property (nonatomic, strong) NSString *shop_is_closed_until;

@property (nonatomic) NSArray *shop_pay_gateway;

@end
