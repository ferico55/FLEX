//
//  TransactionActionResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LuckyDeal.h"
#import "TxEMoneyData.h"

@interface TransactionActionResult : NSObject <TKPObjectMapping>

@property (nonatomic) NSInteger is_success;
@property (strong, nonatomic, nonnull) NSString *cc_agent;
@property (strong, nonatomic, nonnull) TxEMoneyData *emoney_data;
@property (strong, nonatomic, nonnull) NSDictionary *parameter;
@property (strong, nonatomic, nonnull) NSString *query_string;
@property (strong, nonatomic, nonnull) NSString *redirect_url;
@property (strong, nonatomic, nonnull) NSString *callback_url;

@end
