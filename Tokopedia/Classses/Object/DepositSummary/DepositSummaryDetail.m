//
//  DepositSummaryDetail.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "DepositSummaryDetail.h"

@implementation DepositSummaryDetail

+ (RKObjectMapping *)mapping {
    RKObjectMapping *depositSummaryDetailMapping = [RKObjectMapping mappingForClass:[DepositSummaryDetail class]];
    
    [depositSummaryDetailMapping addAttributeMappingsFromArray:@[@"summary_hold_deposit_idr",
                                                                 @"summary_total_deposit_idr",
                                                                 @"summary_total_deposit",
                                                                 @"summary_deposit_hold_tx_1_day",
                                                                 @"summary_today_tries",
                                                                 @"summary_useable_deposit_idr",
                                                                 @"summary_useable_deposit",
                                                                 @"summary_deposit_hold_tx_1_day_idr",
                                                                 @"summary_hold_deposit",
                                                                 @"summary_daily_tries",
                                                                 @"summary_deposit_hold_by_cs",
                                                                 @"summary_deposit_hold_by_cs_idr"]];
    
    return depositSummaryDetailMapping;
}

@end
