//
//  ShopTransactionStats.m
//  Tokopedia
//
//  Created by Tonito Acen on 11/20/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "ShopTransactionStats.h"

@implementation ShopTransactionStats
+(RKObjectMapping *)mapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[ShopTransactionStats class]];
    [mapping addAttributeMappingsFromArray:@[@"shop_tx_has_transaction_3_month",
                                             @"shop_tx_success_rate_1_month",
                                             @"shop_tx_show_percentage_3_month",
                                             @"shop_tx_has_transaction",
                                             @"shop_tx_success_3_month_fmt",
                                             @"shop_tx_show_percentage_1_month",
                                             @"shop_tx_success_1_year_fmt",
                                             @"shop_tx_has_transaction_1_month",
                                             @"shop_tx_success_rate_1_year",
                                             @"shop_tx_has_transaction_1_year",
                                             @"shop_tx_success_1_month_fmt",
                                             @"shop_tx_show_percentage_1_year",
                                             @"shop_tx_success_rate_3_month"
                                             ]];
    return mapping;
}
@end
