//
//  TransactionSummaryResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionSummaryDetail.h"

@interface TransactionSummaryResult : NSObject

@property (nonatomic, strong) TransactionSummaryDetail *transaction;

@end
