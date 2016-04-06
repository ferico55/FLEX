//
//  TransactionSummaryResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionSummaryDetail.h"
#import "CCData.h"
#import "Veritrans.h"

@interface TransactionSummaryResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong) TransactionSummaryDetail *transaction;
@property (nonatomic, strong) CCData *credit_card_data;
@property (nonatomic, strong) NSString *year_now;
@property (nonatomic, strong) Veritrans *veritrans;

@end
