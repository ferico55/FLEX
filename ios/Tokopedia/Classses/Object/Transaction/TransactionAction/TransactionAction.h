//
//  TransactionAction.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionActionResult.h"
@class Errors;

@interface TransactionAction : NSObject <TKPObjectMapping>

@property (nonatomic, strong, nonnull) NSArray *message_error;
@property (nonatomic, strong, nonnull) NSArray *message_status;
@property (nonatomic, strong, nonnull) NSString *status;
@property (nonatomic, strong, nonnull) NSString *server_process_time;
@property (nonatomic, strong, nonnull) NSArray<Errors *> *errors;
@property (nonatomic, strong, nonnull) TransactionActionResult *result;
@property (nonatomic, strong, nonnull) TransactionActionResult *data;

@end
