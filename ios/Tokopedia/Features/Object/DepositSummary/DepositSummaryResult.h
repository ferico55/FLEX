//
//  DepositSummaryResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Paging;
#import "DepositSummaryList.h"
#import "DepositSummaryDetail.h"

@interface DepositSummaryResult : NSObject

@property (nonatomic, strong, nonnull) Paging *paging;
@property (nonatomic, strong, nonnull) NSArray *list;
@property (nonatomic, strong, nonnull) DepositSummaryDetail *summary;
@property (nonatomic, strong, nonnull) NSString *start_date;
@property (nonatomic, strong, nonnull) NSString *end_date;
@property (nonatomic, strong, nonnull) NSString *error_date;
@property (nonatomic, strong, nonnull) NSString *user_id;

+ (RKObjectMapping *_Nonnull)mapping;

@end
