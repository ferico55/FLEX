//
//  ShopStats.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShopStats : NSObject

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

@end
