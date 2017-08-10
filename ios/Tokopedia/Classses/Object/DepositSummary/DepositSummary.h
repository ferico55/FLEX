//
//  DepositSummary.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DepositSummaryResult.h"

@interface DepositSummary : NSObject

@property (nonatomic, strong, nonnull) NSArray *message_error;
@property (nonatomic, strong, nonnull) NSString *status;
@property (nonatomic, strong, nonnull) NSString *server_process_time;
@property (nonatomic, strong, nonnull) DepositSummaryResult *result;
@property (nonatomic, strong, nonnull) DepositSummaryResult *data;

+ (RKObjectMapping *_Nonnull)mapping;

@end
