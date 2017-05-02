//
//  ShopTransactionStats.h
//  Tokopedia
//
//  Created by Tonito Acen on 11/20/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShopTransactionStats : NSObject

@property (nonatomic, strong) NSString *shop_tx_has_transaction_3_month;
@property (nonatomic, strong) NSString *shop_tx_success_rate_1_month;
@property (nonatomic, strong) NSString *shop_tx_show_percentage_3_month;
@property (nonatomic, strong) NSString *shop_tx_has_transaction;
@property (nonatomic, strong) NSString *shop_tx_success_3_month_fmt;
@property (nonatomic, strong) NSString *shop_tx_show_percentage_1_month;
@property (nonatomic, strong) NSString *shop_tx_success_1_year_fmt;
@property (nonatomic, strong) NSString *shop_tx_has_transaction_1_month;
@property (nonatomic, strong) NSString *shop_tx_success_rate_1_year;
@property (nonatomic, strong) NSString *shop_tx_has_transaction_1_year;
@property (nonatomic, strong) NSString *shop_tx_success_1_month_fmt;
@property (nonatomic, strong) NSString *shop_tx_show_percentage_1_year;
@property (nonatomic, strong) NSString *shop_tx_success_rate_3_month;

+(RKObjectMapping*)mapping;

@end
