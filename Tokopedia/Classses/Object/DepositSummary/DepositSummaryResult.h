//
//  DepositSummaryResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Paging.h"
#import "DepositSummaryList.h"
#import "DepositSummaryDetail.h"

@interface DepositSummaryResult : NSObject

@property (nonatomic, strong) Paging *paging;
@property (nonatomic, strong) NSArray *list;
@property (nonatomic, strong) DepositSummaryDetail *summary;
@property (nonatomic, strong) NSString *start_date;
@property (nonatomic, strong) NSString *end_date;

@end
