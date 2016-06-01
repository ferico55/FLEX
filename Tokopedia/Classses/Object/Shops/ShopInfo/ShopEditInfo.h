//
//  ShopEditInfo.h
//  Tokopedia
//
//  Created by Tokopedia on 3/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShopEditInfo : NSObject

@property (strong, nonatomic) NSString *shop_already_favorited;
@property (strong, nonatomic) NSString *shop_avatar;
@property (strong, nonatomic) NSString *shop_cover;
@property (strong, nonatomic) NSString *shop_description;
@property (strong, nonatomic) NSString *shop_domain;
@property (strong, nonatomic) NSString *shop_has_terms;
@property (strong, nonatomic) NSString *shop_id;
@property (strong, nonatomic) NSString *shop_is_closed_note;
@property (strong, nonatomic) NSString *shop_is_closed_reason;
@property (strong, nonatomic) NSString *shop_is_closed_until;
@property BOOL shop_is_gold;
@property (strong, nonatomic) NSString *shop_is_owner;
@property (strong, nonatomic) NSString *shop_location;
@property (strong, nonatomic) NSString *shop_name;
@property (strong, nonatomic) NSString *shop_open_since;
@property (strong, nonatomic) NSString *shop_owner_id;
@property (strong, nonatomic) NSString *shop_owner_last_login;
@property (strong, nonatomic) NSString *shop_status;
@property (strong, nonatomic) NSString *shop_tagline;
@property (strong, nonatomic) NSString *shop_total_favorit;
@property (strong, nonatomic) NSString *shop_url;
@property (strong, nonatomic) NSString *shop_gold_expired_time;

+ (RKObjectMapping *)mapping;

@end
