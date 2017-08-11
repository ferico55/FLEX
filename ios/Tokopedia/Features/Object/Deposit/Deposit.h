//
//  DepositInfo.h
//  Tokopedia
//
//  Created by Tokopedia PT on 12/12/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DepositResult.h"

@interface Deposit : NSObject

@property (nonatomic, strong, nonnull) NSArray *message_error;
@property (nonatomic, strong, nonnull) NSString *status;
@property (nonatomic, strong, nonnull) NSString *server_process_time;
@property (nonatomic, strong, nonnull) DepositResult *result;
@property (nonatomic, strong, nonnull) DepositResult *data;

+ (RKObjectMapping *_Nonnull)mapping;

@end
