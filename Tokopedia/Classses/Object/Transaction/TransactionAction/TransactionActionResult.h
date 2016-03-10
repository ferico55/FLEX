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
@property (strong, nonatomic) NSString *cc_agent;
@property (strong, nonatomic) LuckyDeal *ld;
@property (nonatomic, strong) TxEMoneyData *emoney_data;
@property (strong, nonatomic) NSDictionary *parameter;
@property (strong, nonatomic) NSString *query_string;
@property (strong, nonatomic) NSString *redirect_url;

@end
