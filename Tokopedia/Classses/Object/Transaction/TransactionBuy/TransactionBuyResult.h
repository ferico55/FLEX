//
//  TransactionBuyResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/19/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionSummaryDetail.h"
#import "TransactionSystemBank.h"

@interface TransactionBuyResult : NSObject

@property (nonatomic, strong) TransactionSummaryDetail *transaction;
@property (nonatomic, strong) NSArray *system_bank;
@property (nonatomic) NSInteger is_success;
@property (nonatomic, strong) NSString *link_mandiri;

@end
