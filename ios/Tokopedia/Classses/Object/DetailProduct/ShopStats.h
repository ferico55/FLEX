//
//  ShopStats.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShopBadgeLevel.h"
#import "CountRatingResult.h"
#import "ShopBadgeLevel.h"


@interface ShopStats : NSObject <TKPObjectMapping>
@property (nonatomic, strong) ShopBadgeLevel *shop_badge_level;
@property (nonatomic) NSInteger shop_service_rate;
@property (nonatomic, strong) NSString *shop_service_description;
@property (nonatomic) NSInteger shop_speed_rate;
@property (nonatomic) NSInteger shop_accuracy_rate;
@property (nonatomic, strong) NSString *shop_accuracy_description;
@property (nonatomic, strong) NSString *shop_speed_description;
@property (nonatomic, strong) NSString *shop_total_transaction;
@property (nonatomic, strong) NSString *shop_total_etalase;
@property (nonatomic, strong) NSString *shop_total_product;
@property (nonatomic, strong) NSString *shop_item_sold;
@property (nonatomic, strong) CountRatingResult *shop_last_one_month;
@property (nonatomic, strong) CountRatingResult *shop_last_six_months;
@property (nonatomic, strong) CountRatingResult *shop_last_twelve_months;

@property (nonatomic, strong) NSString *tx_count_success;
@property (nonatomic, strong) NSString *hide_rate;
@property (nonatomic, strong) NSString *tx_count;
@property (nonatomic, strong) NSString *rate_failure;
@property (nonatomic, strong) NSString *shop_total_transaction_canceled;
@property (nonatomic, strong) NSString *shop_reputation_score;
@property (nonatomic, strong) NSString *rate_success;
@property (nonatomic, strong) NSString *tooltip;

@property (readonly) NSString *pointsText;
@end
