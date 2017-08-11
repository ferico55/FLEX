//
//  DepositFormInfo.h
//  Tokopedia
//
//  Created by Tokopedia PT on 12/12/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DepositFormResult.h"

@interface DepositForm : NSObject

@property (nonatomic, strong, nonnull) NSArray *message_error;
@property (nonatomic, strong, nonnull) NSString *status;
@property (nonatomic, strong, nonnull) NSString *server_process_time;
@property (nonatomic, strong, nonnull) DepositFormResult *result;
@property (nonatomic, strong, nonnull) DepositFormResult *data;

+ (RKObjectMapping *_Nonnull)mapping;

@end
