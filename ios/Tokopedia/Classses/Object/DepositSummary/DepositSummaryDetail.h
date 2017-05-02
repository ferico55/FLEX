//
//  DepositSummaryList.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DepositSummaryDetail : NSObject

@property (nonatomic, strong) NSString *summary_hold_deposit_idr;
@property (nonatomic, strong) NSString *summary_total_deposit_idr;
@property (nonatomic, strong) NSString *summary_total_deposit;
@property (nonatomic, strong) NSString *summary_deposit_hold_tx_1_day;
@property (nonatomic, strong) NSString *summary_today_tries;
@property (nonatomic, strong) NSString *summary_useable_deposit_idr;
@property (nonatomic, strong) NSString *summary_useable_deposit;
@property (nonatomic, strong) NSString *summary_deposit_hold_tx_1_day_idr;
@property (nonatomic, strong) NSString *summary_hold_deposit;
@property (nonatomic, strong) NSString *summary_daily_tries;
@property (nonatomic, strong) NSString *summary_deposit_hold_by_cs;
@property (nonatomic, strong) NSString *summary_deposit_hold_by_cs_idr;

+ (RKObjectMapping*)mapping;

@end
