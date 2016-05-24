//
//  DepositSummaryList.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "DepositSummaryList.h"

@implementation DepositSummaryList

+ (RKObjectMapping *)mapping {
    RKObjectMapping *depositSummaryListMapping = [RKObjectMapping mappingForClass:[DepositSummaryList class]];
    
    [depositSummaryListMapping addAttributeMappingsFromArray:@[@"deposit_id",
                                                               @"deposit_saldo_idr",
                                                               @"deposit_date_full",
                                                               @"deposit_amount",
                                                               @"deposit_amount_idr",
                                                               @"deposit_type",
                                                               @"deposit_date",
                                                               @"deposit_withdraw_date",
                                                               @"deposit_withdraw_status",
                                                               @"deposit_notes"]];
    
    return depositSummaryListMapping;
}

@end
